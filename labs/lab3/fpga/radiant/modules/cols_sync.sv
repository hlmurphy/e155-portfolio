// -------------------------------------------------------------
// cols_sync.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-21
// Course: HMC E155, Lab 3
// Purpose: Synchronizer module for asynchronous column input (key presses)
// 2 staged D-Flip Flops
// -------------------------------------------------------------
module cols_sync(input logic clk,
                input logic reset,
                input logic [3:0] cols_in,       // async column input from keypad
                output logic [3:0] cols_synced); // synchronized output (used for all logic)

                logic [3:0] cols_inter; // intermediary (stage-1 output) signal between FF's

        always_ff @(posedge clk) begin
             if (reset) begin
                // clear any propagation on power up, after reset 
                cols_synced <= 4'b0000;
                cols_inter <= 4'b0000;
            end
            else begin
                cols_inter <= cols_in;
                cols_synced <= cols_inter;
            end
        end

endmodule