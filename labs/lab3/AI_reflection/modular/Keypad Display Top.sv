// -----------------------------------------------------------------------------
// keypad_display_top.sv
//
// Top level: 4x4 keypad -> last two hex keys on a multiplexed dual 7-segment
// display. Target: Lattice iCE40 UP5K, clocked from the internal HF oscillator.
//
// Data path:
//   HFOSC -> clk
//   keypad_scanner  : drives cols_n, samples rows_n -> key_pressed, key_code
//   keypad_oneshot  : debounce + one-shot -> new_key pulse, key_out
//   shift register  : on new_key, older <= recent, recent <= key_out
//   display mux     : time-multiplexes one sevenSegment decoder across
//                     two digits with equal duty and a blanking gap
//
// Assumed external module (not defined here):
//   sevenSegment(input logic [3:0] <hex>, output logic [6:0] <segments>)
//   It is instantiated positionally so its port names don't matter.
//   Segment polarity is whatever sevenSegment produces.
// -----------------------------------------------------------------------------
module keypad_display_top #(
    parameter int unsigned CLK_HZ           = 12_000_000, // must match HFOSC_DIV
    parameter int unsigned SCAN_HZ          = 1_000,      // keypad column step rate
    parameter int unsigned DEBOUNCE_MS      = 20,         // key debounce window
    parameter int unsigned MUX_HZ           = 1_000,      // digit switch rate
    parameter int unsigned BLANK_CYCLES     = 240,        // dead time per switch (20 us @ 12 MHz)
    parameter bit          DIGIT_ACTIVE_LOW = 1'b1        // 1: digit enable pins are active-low
) (
    input  logic       rst_n_pin,   // external reset button, active-low
    input  logic [3:0] rows_n,      // keypad rows, active-low (pull-ups required)
    output logic [3:0] cols_n,      // keypad columns, active-low
    output logic [6:0] seg,         // shared segment lines
    output logic [1:0] dig_en       // [1] = left digit (older), [0] = right digit (recent)
);

    // -------------------------------------------------------------------------
    // Clock: internal 48 MHz HF oscillator, divided.
    //   CLKHF_DIV: "0b00" = 48 MHz, "0b01" = 24 MHz, "0b10" = 12 MHz, "0b11" = 6 MHz
    // Define RADIANT when building with Lattice Radiant (primitive HSOSC);
    // otherwise the Yosys/nextpnr primitive SB_HFOSC is used.
    // -------------------------------------------------------------------------
    logic clk;

`ifdef RADIANT
    HSOSC #(.CLKHF_DIV("0b10")) u_hfosc (
        .CLKHFPU (1'b1),
        .CLKHFEN (1'b1),
        .CLKHF   (clk)
    );
`else
    SB_HFOSC #(.CLKHF_DIV("0b10")) u_hfosc (
        .CLKHFPU (1'b1),
        .CLKHFEN (1'b1),
        .CLKHF   (clk)
    );
`endif

    // -------------------------------------------------------------------------
    // Reset synchronizer. iCE40 flip-flops power up at 0, so reset is
    // asserted right after configuration. It releases two cycles after
    // rst_n_pin is high.
    // -------------------------------------------------------------------------
    logic [1:0] rst_sync = 2'b00;
    logic       rst_n;

    always_ff @(posedge clk) rst_sync <= {rst_sync[0], rst_n_pin};
    assign rst_n = rst_sync[1];

    // -------------------------------------------------------------------------
    // Keypad scanner and one-shot registration
    // -------------------------------------------------------------------------
    logic       key_pressed;
    logic [3:0] key_code;
    logic       new_key;
    logic [3:0] key_out;

    keypad_scanner #(
        .CLK_HZ  (CLK_HZ),
        .SCAN_HZ (SCAN_HZ)
    ) u_scanner (
        .clk         (clk),
        .rst_n       (rst_n),
        .rows_n      (rows_n),
        .cols_n      (cols_n),
        .key_pressed (key_pressed),
        .key_code    (key_code)
    );

    keypad_oneshot #(
        .CLK_HZ      (CLK_HZ),
        .DEBOUNCE_MS (DEBOUNCE_MS)
    ) u_oneshot (
        .clk         (clk),
        .rst_n       (rst_n),
        .key_pressed (key_pressed),
        .key_code    (key_code),
        .new_key     (new_key),
        .key_out     (key_out)
    );

    // -------------------------------------------------------------------------
    // Two-key history: changes only when a new key is registered
    // -------------------------------------------------------------------------
    logic [3:0] older, recent;

    always_ff @(posedge clk) begin
        if (!rst_n)       {older, recent} <= '0;
        else if (new_key) {older, recent} <= {recent, key_out};
    end

    // -------------------------------------------------------------------------
    // Display multiplexer
    //   * mux_sel toggles every MUX_DIV cycles. Each digit refreshes at
    //     MUX_HZ/2 (500 Hz by default), well above the flicker threshold.
    //   * Both digits get the same on-time (MUX_DIV - BLANK_CYCLES), so their
    //     apparent brightness matches.
    //   * Both digits are blanked for BLANK_CYCLES after each switch. This
    //     hides the segment transition and prevents ghosting. BLANK_CYCLES
    //     must be >= 2 (covers the output register) and < MUX_DIV.
    // -------------------------------------------------------------------------
    localparam int unsigned MUX_DIV = CLK_HZ / MUX_HZ;
    localparam int unsigned MUX_W   = $clog2(MUX_DIV);

    logic [MUX_W-1:0] mux_cnt;
    logic             mux_sel;     // 1 = left (older), 0 = right (recent)
    logic             blank;
    logic [3:0]       disp_nibble;
    logic [6:0]       seg_dec;
    logic [1:0]       dig_on;      // active-high digit enables before polarity

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            mux_cnt <= '0;
            mux_sel <= 1'b0;
        end else if (mux_cnt == MUX_W'(MUX_DIV - 1)) begin
            mux_cnt <= '0;
            mux_sel <= ~mux_sel;
        end else begin
            mux_cnt <= mux_cnt + 1'b1;
        end
    end

    assign blank       = (mux_cnt < MUX_W'(BLANK_CYCLES));
    assign disp_nibble = mux_sel ? older : recent;
    assign dig_on      = blank ? 2'b00 : (mux_sel ? 2'b10 : 2'b01);

    sevenSegment u_seg (disp_nibble, seg_dec);

    // Registered outputs: no combinational glitches reach the pins
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            seg    <= '0;
            dig_en <= DIGIT_ACTIVE_LOW ? 2'b11 : 2'b00;   // both digits off
        end else begin
            seg    <= seg_dec;
            dig_en <= DIGIT_ACTIVE_LOW ? ~dig_on : dig_on;
        end
    end

endmodule
