// -------------------------------------------------------------
// nextkey.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-10-27
// Course: HMC E155, Lab 7
// Purpose:
// -------------------------------------------------------------
module nextkey (input logic [127:0] prev_key,
                input logic [3:0]   cnt,
                output logic [127:0] next_key);

            logic [31:0] word0, word1, word2, word3;
            logic [31:0] nw0, nw1, nw2, nw3;
            logic[31:0] temp;
            logic[31:0] rcon_out;
            logic[31:0] subword_out;
            logic[31:0] rotword_out;

            assign word0 = prev_key[127:96];
            assign word1 = prev_key[95:64];
            assign word2 = prev_key[63:32];
            assign word3 = prev_key[31:0];

            // instantiate the rcon, subword, and rotword modules
            rotword rw(.a(word3), .y(rotword_out));
            subword sw(.a(rotword_out), .y(subword_out));

            always_comb begin
                rcon_out = 32'h00000000;
                case (cnt)
                    4'd1: rcon_out = 32'h01000000;
                    4'd2: rcon_out = 32'h02000000;
                    4'd3: rcon_out = 32'h04000000;
                    4'd4: rcon_out = 32'h08000000;
                    4'd5: rcon_out = 32'h10000000;
                    4'd6: rcon_out = 32'h20000000;
                    4'd7: rcon_out = 32'h40000000;
                    4'd8: rcon_out = 32'h80000000;
                    4'd9: rcon_out = 32'h1B000000;
                    4'd10: rcon_out = 32'h36000000;
                    default: rcon_out = 32'h00000000;
                endcase
            end 

            // Combinational logic to compute the next key
            assign temp = subword_out ^ rcon_out;
            assign nw0 = word0 ^ temp;
            assign nw1 = nw0 ^ word1;
            assign nw2 = nw1 ^ word2;
            assign nw3 = nw2 ^ word3;

            assign next_key = {nw0, nw1, nw2, nw3};
endmodule
            