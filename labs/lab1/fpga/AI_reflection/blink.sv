// blink.sv — 2 Hz LED blinker driven by the iCE40 UP5K internal HF oscillator
//
// The UP5K contains a hard 48 MHz RC oscillator (SB_HFOSC) with a built-in
// power-of-two divider.  No external crystal or PLL is required.
//
//   CLKHF_DIV   output
//   "0b00"      48 MHz
//   "0b01"      24 MHz
//   "0b10"      12 MHz   <-- used here
//   "0b11"       6 MHz
//
// The RC oscillator is only accurate to roughly +/-10% over PVT, so the
// blink rate is nominal, not precise.  Use an external reference or the
// 10 kHz LF oscillator + PLL if you need real accuracy.

`default_nettype none

module blink #(
    parameter int CLK_HZ   = 12_000_000,  // must match CLKHF_DIV below
    parameter int BLINK_HZ = 2            // full on/off cycles per second
) (
    output logic led
);

    // ------------------------------------------------------------------
    // Derived constants
    // ------------------------------------------------------------------
    // One full blink cycle = two toggles, so toggle at 2 * BLINK_HZ.
    localparam int TOGGLE_TICKS = CLK_HZ / (2 * BLINK_HZ);
    localparam int CTR_W        = $clog2(TOGGLE_TICKS);

    localparam logic [CTR_W-1:0] TOGGLE_MAX = CTR_W'(TOGGLE_TICKS - 1);

    // Catch a mis-parameterized instance at elaboration time rather than
    // at 3 a.m. on the bench.
    if (TOGGLE_TICKS < 2)
        $error("BLINK_HZ too fast for CLK_HZ");

    // ------------------------------------------------------------------
    // Internal high-speed oscillator
    // ------------------------------------------------------------------
    logic clk;

    SB_HFOSC #(
        .CLKHF_DIV ("0b10")   // 48 MHz / 4 = 12 MHz
    ) u_hfosc (
        .CLKHFPU (1'b1),      // power up the oscillator bias
        .CLKHFEN (1'b1),      // enable the clock output
        .CLKHF   (clk)
    );

    // ------------------------------------------------------------------
    // Power-on reset
    // ------------------------------------------------------------------
    // iCE40 flops power up to their initial value, so a shift register of
    // zeros walking to ones gives a clean synchronous release a few cycles
    // after the oscillator starts producing edges.
    logic [3:0] por_shift = '0;
    logic       rst_n;

    always_ff @(posedge clk) begin
        por_shift <= {por_shift[2:0], 1'b1};
    end

    assign rst_n = por_shift[3];

    // ------------------------------------------------------------------
    // Divider and output toggle
    // ------------------------------------------------------------------
    logic [CTR_W-1:0] count;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            count <= '0;
            led   <= 1'b0;
        end
        else if (count == TOGGLE_MAX) begin
            count <= '0;
            led   <= ~led;
        end
        else begin
            count <= count + 1'b1;
        end
    end

endmodule

`default_nettype wire