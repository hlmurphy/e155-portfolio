// -------------------------------------------------------------
// cols_sync.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-21
// Course: HMC E155, Lab 3
// Purpose: Syncronizer module for asyncnronous column input (key presses)
// 2 staged D-Flip Flops
// -------------------------------------------------------------
module cols_sync(input logic clk,
                input logic reset,
                input logic [3:0] cols_in, // async input column signlas from toggled keys
                output logic [3:0] cols_synced); //syncronized ouput column signals

                logic [3:0] cols_inter; //intermediary signals between FF's

        always_ff @(posedge clk) begin
             if (reset) begin
                cols_synced <= 4'b0000;
                cols_inter <= 4'b0000;
            end
            else begin
                cols_inter <= cols_in;
                cols_synced <= cols_inter;
            end
        end

endmodule