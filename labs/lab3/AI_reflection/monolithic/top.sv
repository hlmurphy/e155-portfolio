// top.sv
// Keypad -> last-two-keys hex display, Lattice iCE40 UP5K.
//
// Clocking: the UP5K high-frequency oscillator is 48 MHz nominal with a
// /1, /2, /4, /8 divider, so the closest setting to "~20 MHz" is 24 MHz
// (CLKHF_DIV = "0b01"). CLK_HZ below must match whatever you pick.
//
// Board notes:
//   * row_n needs pull-ups (enable the iCE40 internal pull-up in the
//     constraints file, e.g. PULLMODE=UP in Radiant, or external resistors).
//   * Columns are driven open-drain (0 or Z): if two keys in the same row
//     are pressed, a push-pull design would short a high column to a low
//     one through the switches. Open-drain makes that harmless.
module top (
  input  logic       reset_n,  // active-low pushbutton (async, synchronized)
  input  logic [3:0] row_n,    // keypad rows, active-low
  output tri   [3:0] col,      // keypad columns, open-drain active-low
  output logic [6:0] seg,      // shared segment bus {g,f,e,d,c,b,a}
  output logic [1:0] dig       // digit enables: [1] = left, [0] = right
);
  localparam int unsigned CLK_HZ  = 24_000_000;
  localparam int unsigned SCAN_HZ = 200;   // 5 ms per column step

  // ---------------- Clock ----------------
  logic clk;

  // Radiant primitive name. With Yosys/nextpnr use SB_HFOSC instead
  // (same ports, parameter CLKHF_DIV = "0b01").
  HSOSC #(.CLKHF_DIV("0b01")) u_osc (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF  (clk)
  );

  // ---------------- Reset ----------------
  // Synchronized, synchronous reset. iCE40 flops power up at 0, so the
  // synchronizer output starts low -> rst is asserted for the first couple
  // of cycles after configuration: a free power-on reset.
  logic reset_n_s, rst;
  sync2 #(.W(1)) u_rst_sync (.clk(clk), .d(reset_n), .q(reset_n_s));
  assign rst = ~reset_n_s;

  // ---------------- Keypad ----------------
  logic [3:0] row_n_s, col_n, key_code;
  logic       scan_tick, key_valid;

  sync2 #(.W(4)) u_row_sync (.clk(clk), .d(row_n), .q(row_n_s));

  clk_tick #(.CLK_HZ(CLK_HZ), .TICK_HZ(SCAN_HZ)) u_scan_tick (
    .clk(clk), .rst(rst), .tick(scan_tick)
  );

  keypad_scanner #(.RELEASE_TICKS(4)) u_scan (
    .clk      (clk),
    .rst      (rst),
    .tick     (scan_tick),
    .row_n    (row_n_s),
    .col_n    (col_n),
    .key_valid(key_valid),
    .key_code (key_code)
  );

  // Open-drain column drivers (inferred tristate on top-level pins).
  for (genvar i = 0; i < 4; i++) begin : g_col_od
    assign col[i] = col_n[i] ? 1'bz : 1'b0;
  end

  // ---------------- Digit history ----------------
  // Shift in each newly registered key: recent -> older, new -> recent.
  logic [3:0] older, recent;

  always_ff @(posedge clk) begin
    if (rst) begin
      older  <= 4'h0;
      recent <= 4'h0;
    end else if (key_valid) begin
      older  <= recent;
      recent <= key_code;
    end
  end

  // ---------------- Display ----------------
  display_mux #(
    .CNT_W         (15),   // ~732 Hz refresh at 24 MHz
    .BLANK_W       (8),
    .SEG_ACTIVE_LOW(1'b1),
    .DIG_ACTIVE_LOW(1'b1)
  ) u_disp (
    .clk      (clk),
    .rst      (rst),
    .hex_left (older),
    .hex_right(recent),
    .seg      (seg),
    .dig      (dig)
  );
endmodule
