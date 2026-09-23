// sync2.sv
// Two-flop synchronizer for asynchronous inputs (keypad rows, reset button).
// Metastability protection only -- debouncing is handled by the scanner FSM.
module sync2 #(
  parameter int unsigned W = 1
) (
  input  logic         clk,
  input  logic [W-1:0] d,
  output logic [W-1:0] q
);
  logic [W-1:0] meta;

  always_ff @(posedge clk) begin
    meta <= d;
    q    <= meta;
  end
endmodule
