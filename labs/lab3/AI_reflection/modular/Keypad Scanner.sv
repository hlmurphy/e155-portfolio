// -----------------------------------------------------------------------------
// keypad_scanner.sv
//
// 4x4 matrix keypad scanner.
// Target: Lattice iCE40 UP5K (synthesizable, single clock domain).
//
// Operation:
//   * Drives one column low at a time (cols_n, active-low), stepping at
//     SCAN_HZ. Each column dwells for CLK_HZ/SCAN_HZ cycles.
//   * Rows (rows_n, active-low, pulled up) pass through a 2-FF synchronizer
//     and are sampled at the end of each column's dwell, just before the
//     column advances. This leaves the full dwell time for the lines to settle.
//   * When a row reads low, the scanner freezes on that column (S_HOLD).
//     It latches key_code and asserts key_pressed. Both stay constant while
//     that key is held.
//   * When the held key's row goes high again, key_pressed drops and
//     scanning resumes from the next column.
//   * If several rows in a column are low at once, the lowest-numbered row
//     wins. Only one key is reported at a time.
//
// Keypad layout (row, col) -> hex code:
//            col0 col1 col2 col3
//     row0:   1    2    3    A
//     row1:   4    5    6    B
//     row2:   7    8    9    C
//     row3:   E(*) 0    F(#) D
//
// All outputs are driven directly from flip-flops.
// -----------------------------------------------------------------------------
module keypad_scanner #(
    parameter int unsigned CLK_HZ  = 48_000_000, // system clock frequency
    parameter int unsigned SCAN_HZ = 1_000       // column step rate (per column)
) (
    input  logic       clk,
    input  logic       rst_n,        // synchronous, active-low reset
    input  logic [3:0] rows_n,       // keypad rows, active-low (need pull-ups)
    output logic [3:0] cols_n,       // keypad columns, active-low, one-cold
    output logic       key_pressed,  // a key is currently detected/held
    output logic [3:0] key_code      // hex code of detected key
);

    // -------------------------------------------------------------------------
    // Scan tick: one-cycle enable every DIV clocks.
    // DIV must exceed the synchronizer latency so that a sample always
    // reflects the current column.
    // -------------------------------------------------------------------------
    localparam int unsigned DIV_RAW = CLK_HZ / SCAN_HZ;
    localparam int unsigned DIV     = (DIV_RAW < 4) ? 4 : DIV_RAW;
    localparam int unsigned DIV_W   = $clog2(DIV);

    logic [DIV_W-1:0] div_cnt;
    logic             tick;

    assign tick = (div_cnt == DIV_W'(DIV - 1));

    always_ff @(posedge clk) begin
        if (!rst_n || tick) div_cnt <= '0;
        else                div_cnt <= div_cnt + 1'b1;
    end

    // -------------------------------------------------------------------------
    // Row synchronizer (rows are asynchronous pin inputs)
    // -------------------------------------------------------------------------
    logic [3:0] rows_s1, rows_s;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            rows_s1 <= 4'hF;
            rows_s  <= 4'hF;
        end else begin
            rows_s1 <= rows_n;
            rows_s  <= rows_s1;
        end
    end

    // Active-high row hits and a priority encoder (lowest row wins)
    logic [3:0] row_hit;
    logic       any_hit;
    logic [1:0] hit_row;

    assign row_hit = ~rows_s;
    assign any_hit = |row_hit;

    always_comb begin
        if      (row_hit[0]) hit_row = 2'd0;
        else if (row_hit[1]) hit_row = 2'd1;
        else if (row_hit[2]) hit_row = 2'd2;
        else                 hit_row = 2'd3;
    end

    // -------------------------------------------------------------------------
    // Key decode: standard 4x4 layout
    // -------------------------------------------------------------------------
    function automatic logic [3:0] decode_key(input logic [1:0] row,
                                              input logic [1:0] col);
        unique case ({row, col})
            4'b00_00: decode_key = 4'h1;
            4'b00_01: decode_key = 4'h2;
            4'b00_10: decode_key = 4'h3;
            4'b00_11: decode_key = 4'hA;
            4'b01_00: decode_key = 4'h4;
            4'b01_01: decode_key = 4'h5;
            4'b01_10: decode_key = 4'h6;
            4'b01_11: decode_key = 4'hB;
            4'b10_00: decode_key = 4'h7;
            4'b10_01: decode_key = 4'h8;
            4'b10_10: decode_key = 4'h9;
            4'b10_11: decode_key = 4'hC;
            4'b11_00: decode_key = 4'hE;  // '*'
            4'b11_01: decode_key = 4'h0;
            4'b11_10: decode_key = 4'hF;  // '#'
            4'b11_11: decode_key = 4'hD;
            default:  decode_key = 4'h0;
        endcase
    endfunction

    // -------------------------------------------------------------------------
    // Scan FSM
    // -------------------------------------------------------------------------
    typedef enum logic {
        S_SCAN,   // stepping through columns
        S_HOLD    // key found; column frozen until that key releases
    } state_t;

    state_t     state;
    logic [1:0] col_idx;
    logic [1:0] held_row;
    logic [1:0] next_col;

    assign next_col = col_idx + 2'd1;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state       <= S_SCAN;
            col_idx     <= 2'd0;
            cols_n      <= 4'b1110;
            held_row    <= 2'd0;
            key_code    <= 4'h0;
            key_pressed <= 1'b0;
        end else if (tick) begin
            unique case (state)
                S_SCAN: begin
                    if (any_hit) begin
                        // Key found in the current column: freeze here
                        state       <= S_HOLD;
                        held_row    <= hit_row;
                        key_code    <= decode_key(hit_row, col_idx);
                        key_pressed <= 1'b1;
                    end else begin
                        col_idx <= next_col;
                        cols_n  <= ~(4'b0001 << next_col);
                    end
                end

                S_HOLD: begin
                    // Watch only the held key; other keys in this column
                    // do not change the reported code.
                    if (!row_hit[held_row]) begin
                        state       <= S_SCAN;
                        key_pressed <= 1'b0;
                        col_idx     <= next_col;
                        cols_n      <= ~(4'b0001 << next_col);
                    end
                end

                default: begin
                    state       <= S_SCAN;
                    key_pressed <= 1'b0;
                end
            endcase
        end
    end

endmodule
