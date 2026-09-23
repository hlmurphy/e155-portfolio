// seg7_decoder.sv
// Hex -> 7-segment, active-high segments, seg[6:0] = {g,f,e,d,c,b,a}.
// Polarity for the actual board is applied in display_mux.
module seg7_decoder (
  input  logic [3:0] hex,
  output logic [6:0] seg
);
  always_comb begin
    unique case (hex)
      4'h0: seg = 7'h3F;  4'h1: seg = 7'h06;
      4'h2: seg = 7'h5B;  4'h3: seg = 7'h4F;
      4'h4: seg = 7'h66;  4'h5: seg = 7'h6D;
      4'h6: seg = 7'h7D;  4'h7: seg = 7'h07;
      4'h8: seg = 7'h7F;  4'h9: seg = 7'h6F;
      4'hA: seg = 7'h77;  4'hB: seg = 7'h7C;  // b
      4'hC: seg = 7'h39;  4'hD: seg = 7'h5E;  // d
      4'hE: seg = 7'h79;  4'hF: seg = 7'h71;
    endcase
  end
endmodule
