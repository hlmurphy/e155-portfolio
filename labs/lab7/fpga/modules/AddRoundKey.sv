// -------------------------------------------------------------
// AddRoundKey.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-10-27
// Course: HMC E155, Lab 7
// Purpose: The AddRoundKey module for the AES encryption algorithm, performing the XOR operation between the state and the round key
// -------------------------------------------------------------
module AddRoundKey(input logic [127:0] state,
                   input logic [127:0] key,
                   output logic [127:0] out);

    assign out = state ^ key;

endmodule