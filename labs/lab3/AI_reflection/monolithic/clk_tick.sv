// clk_tick.sv
// Clock divider that produces a one-cycle-wide enable pulse ("tick") at
// TICK_HZ instead of a new derived clock. Everything downstream stays on the
// single oscillator clock domain: no gated/ripple clocks, no extra global
// buffers, and no clock-domain crossings for the tools to worry about.
module clk_tick #(
  parameter int unsigned CLK_HZ  = 24_000_000,
  parameter int unsigned TICK_HZ = 200
) (
  input  logic clk,
  input  logic rst,   // synchronous, active-high
  output logic tick   // 1-cycle pulse every CLK_HZ/TICK_HZ cycles
);
  localparam int unsigned DIV = CLK_HZ / TICK_HZ;
  localparam int unsigned W   = (DIV > 1) ? $clog2(DIV) : 1;
  localparam logic [W-1:0] LAST = W'(DIV - 1);

  logic [W-1:0] cnt;

  always_ff @(posedge clk) begin
    if (rst) begin
      cnt  <= '0;
      tick <= 1'b0;
    end else if (cnt == LAST) begin
      cnt  <= '0;
      tick <= 1'b1;
    end else begin
      cnt  <= cnt + 1'b1;
      tick <= 1'b0;
    end
  end
endmodule
