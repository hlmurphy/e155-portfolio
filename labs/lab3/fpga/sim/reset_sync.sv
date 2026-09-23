// -------------------------------------------------------------
// reset_sync.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-21
// Course: HMC E155, Lab 3
// Purpose: 2-FF Syncronizer module for asyncnronous reset input
// -------------------------------------------------------------
module reset_sync(input logic clk,
                input logic reset,
                output logic reset_synced); //syncronized ouput reset signal

                logic reset_inter; //intermediary signals between FF's

        always_ff @(posedge clk) begin
                reset_inter <= reset;
                reset_synced <= reset_inter;
        end

endmodule