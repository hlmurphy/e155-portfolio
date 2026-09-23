// -------------------------------------------------------------
// reset_sync.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-21
// Course: HMC E155, Lab 3
// Purpose: 2-FF Synchronizer module for asynchronous external reset input
// -------------------------------------------------------------
module reset_sync(input logic clk,
                input logic reset, // unsynchronized input
                output logic reset_synced); //synchronized output reset (distributed to all FF across the design)

                logic reset_inter; // intermediary (stage-1 output) signal between FF's

        always_ff @(posedge clk) begin 
                reset_inter <= reset;
                reset_synced <= reset_inter;
        end

endmodule