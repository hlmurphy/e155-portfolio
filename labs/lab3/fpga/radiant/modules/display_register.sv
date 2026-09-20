// -------------------------------------------------------------
// display_register.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 3
// Purpose: display register module for Lab 3 - display the most recent and 
// penultimate keypress on the seven-seg display.
// -------------------------------------------------------------
module display_register(input logic         clk,
                        input logic         reset,
                        input logic [3:0]   new_key,
                        input logic         new_keypress,
                        output logic [3:0]  current_number,
                        output logic [3:0]  previous_number);

                        always_ff @(posedge clk) begin
                            if (reset) begin
                                current_number <= 4'h0;
                                previous_number <= 4'h0;
                            end
                            else if (new_keypress) begin
                                previous_number <= current_number;
                                current_number <= new_key;
                            end
                        end
                    
endmodule