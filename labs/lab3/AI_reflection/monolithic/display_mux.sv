// display_mux.sv
// Time-multiplexes two hex digits onto one shared segment bus.
//
// Design choices:
//   * A free-running counter's MSB selects the digit, so each digit gets
//     exactly 50% of the time -> balanced brightness by construction.
//   * At 24 MHz with CNT_W = 15, the full refresh is 24e6/2^15 ~= 732 Hz
//     (each digit lit ~683 us per frame): far above flicker perception.
//   * A short blanking window (2^BLANK_W clocks, ~10.7 us) at the start of
//     each phase turns everything off while the digit driver transistors
//     switch, preventing ghosting of one digit's pattern onto the other.
//     The window is identical for both digits, so balance is preserved.
//   * One shared decoder instance, and registered outputs so the pins never
//     glitch on the combinational mux/decoder paths.
module display_mux #(
  parameter int unsigned CNT_W          = 15,
  parameter int unsigned BLANK_W        = 8,
  parameter bit          SEG_ACTIVE_LOW = 1'b1,  // e.g. common-anode display
  parameter bit          DIG_ACTIVE_LOW = 1'b1   // e.g. PNP high-side drivers
) (
  input  logic       clk,
  input  logic       rst,
  input  logic [3:0] hex_left,   // older key
  input  logic [3:0] hex_right,  // most recent key
  output logic [6:0] seg,        // {g,f,e,d,c,b,a}
  output logic [1:0] dig         // dig[1] = left, dig[0] = right
);
  logic [CNT_W-1:0] cnt;
  logic             sel, blank;
  logic [3:0]       hex_cur;
  logic [6:0]       seg_raw;
  logic [1:0]       dig_raw;

  always_ff @(posedge clk) begin
    if (rst) cnt <= '0;
    else     cnt <= cnt + 1'b1;
  end

  assign sel     = cnt[CNT_W-1];                     // 0 = right, 1 = left
  assign blank   = (cnt[CNT_W-2:BLANK_W] == '0);     // first slice of each phase
  assign hex_cur = sel ? hex_left : hex_right;

  seg7_decoder u_dec (.hex(hex_cur), .seg(seg_raw));

  assign dig_raw = blank ? 2'b00 : (sel ? 2'b10 : 2'b01);

  always_ff @(posedge clk) begin
    if (rst) begin
      seg <= SEG_ACTIVE_LOW ? 7'h7F : 7'h00;         // all off
      dig <= DIG_ACTIVE_LOW ? 2'b11 : 2'b00;         // all off
    end else begin
      seg <= SEG_ACTIVE_LOW ? ~seg_raw : seg_raw;
      dig <= DIG_ACTIVE_LOW ? ~dig_raw : dig_raw;
    end
  end
endmodule
