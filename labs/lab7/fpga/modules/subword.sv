// -------------------------------------------------------------
//subword.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-10-27
// Course: HMC E155, Lab 7
// Purpose:
// -------------------------------------------------------------
module subword( input logic [31:0] a,
                output logic [31:0] y);
        sbox sub0(.a(a[31:24]), .y(y[31:24]));
        sbox sub1(.a(a[23:16]), .y(y[23:16]));
        sbox sub2(.a(a[15:8]),  .y(y[15:8]));
        sbox sub3(.a(a[7:0]),   .y(y[7:0]));
endmodule