// AES-128 KeyExpansion, one round step (FIPS-197 Sec. 5.2) -- purely combinational.
//
// Computes round key i from round key i-1:
//   w[4i]   = w[4i-4] ^ SubWord(RotWord(w[4i-1])) ^ Rcon[i]
//   w[4i+1] = w[4i-3] ^ w[4i]
//   w[4i+2] = w[4i-2] ^ w[4i+1]
//   w[4i+3] = w[4i-1] ^ w[4i+2]
//
// Byte ordering follows FIPS-197: byte 0 of the key is key[127:120], so
// word w0 = key[127:96] and the first byte of each word is its MSB.
//
// round: 1..10 (the index i of the round key being produced).
// round = 0 or 11..15 give Rcon = 0 (outside the AES-128 schedule).

module key_expansion (
    input  logic [127:0] prev_key,   // round key i-1
    input  logic [3:0]   round,      // i, 1..10
    output logic [127:0] next_key    // round key i
);

    // Split the previous round key into words w0..w3
    logic [31:0] w0, w1, w2, w3;
    assign {w0, w1, w2, w3} = prev_key;

    // Rcon[i] = {rc_i, 8'h00, 8'h00, 8'h00}
    logic [7:0] rc;
    always_comb begin
        unique case (round)
            4'd1:    rc = 8'h01;
            4'd2:    rc = 8'h02;
            4'd3:    rc = 8'h04;
            4'd4:    rc = 8'h08;
            4'd5:    rc = 8'h10;
            4'd6:    rc = 8'h20;
            4'd7:    rc = 8'h40;
            4'd8:    rc = 8'h80;
            4'd9:    rc = 8'h1B;
            4'd10:   rc = 8'h36;
            default: rc = 8'h00;
        endcase
    end

    logic [31:0] rcon;
    assign rcon = {rc, 24'h000000};

    // temp = SubWord(RotWord(w3))
    logic [31:0] rot_w3, sub_rot_w3;

    // Ports assumed to be (input [31:0], output [31:0]); rename if yours differ.
    RotWord u_rotword (.in(w3),     .out(rot_w3));
    SubWord u_subword (.in(rot_w3), .out(sub_rot_w3));

    // Next round key words
    logic [31:0] n0, n1, n2, n3;
    assign n0 = w0 ^ sub_rot_w3 ^ rcon;
    assign n1 = w1 ^ n0;
    assign n2 = w2 ^ n1;
    assign n3 = w3 ^ n2;

    assign next_key = {n0, n1, n2, n3};

endmodule
