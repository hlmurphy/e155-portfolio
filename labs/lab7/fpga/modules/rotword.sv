// -------------------------------------------------------------
// rotword.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-21
// Course: HMC E155, Lab 3
// Purpose: Rotate 32 bit word module for shifting one byte
// -------------------------------------------------------------

module rotword(input logic [31:0] a,
               output logic [31:0] y);

    assign y = {a[23:0], a[31:24]}; // rotate left by 8 bits (1 byte)
endmodule