// keyexpansion.sv
// AES-128 KeyExpansion (FIPS-197, Sec. 5.2, Alg. 2), one round at a time.
// Purely combinational: given round key (round-1) and the round number,
// produces round key (round).
//
// Byte ordering follows FIPS-197 Sec. 3.3: byte 0 of the key is in
// prevkey[127:120], so word w[l] = prevkey[127:96], ..., w[l+3] = prevkey[31:0].
//
// Assumed existing modules:
//   rotword(input logic [31:0] a, output logic [31:0] y)  // [a0,a1,a2,a3] -> [a1,a2,a3,a0]
//   subword(input logic [31:0] a, output logic [31:0] y)  // SBOX applied to each byte

module keyexpansion(
  input  logic [127:0] prevkey,  // round key for round-1 (round 0 = cipher key)
  input  logic [3:0]   round,    // round being generated, 1..10
  output logic [127:0] nextkey   // round key for 'round'
);

  logic [31:0] w0, w1, w2, w3;     // previous round key words w[l..l+3]
  logic [31:0] rotw, subw, temp;
  logic [31:0] n0, n1, n2, n3;     // new round key words w[l+4..l+7]
  logic [7:0]  rcon;

  assign {w0, w1, w2, w3} = prevkey;

  // temp = SubWord(RotWord(w[i-1])) xor Rcon[i/Nk]   (i mod Nk == 0 case)
  rotword rw(.a(w3),   .y(rotw));
  subword sw(.a(rotw), .y(subw));

  // Round constants, Table 5: left-most byte is x^(round-1) in GF(2^8)
  always_comb begin
    case (round)
      4'd1:    rcon = 8'h01;
      4'd2:    rcon = 8'h02;
      4'd3:    rcon = 8'h04;
      4'd4:    rcon = 8'h08;
      4'd5:    rcon = 8'h10;
      4'd6:    rcon = 8'h20;
      4'd7:    rcon = 8'h40;
      4'd8:    rcon = 8'h80;
      4'd9:    rcon = 8'h1b;
      4'd10:   rcon = 8'h36;
      default: rcon = 8'h00;
    endcase
  end

  assign temp = subw ^ {rcon, 24'h000000};

  // w[i] = w[i-Nk] xor temp, then w[i] = w[i-Nk] xor w[i-1] for the rest
  assign n0 = w0 ^ temp;
  assign n1 = w1 ^ n0;
  assign n2 = w2 ^ n1;
  assign n3 = w3 ^ n2;

  assign nextkey = {n0, n1, n2, n3};

endmodule
