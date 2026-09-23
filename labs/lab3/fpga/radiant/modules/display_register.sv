// -------------------------------------------------------------
// display_register.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 3
// Purpose: display register module for Lab 3 - display the most recent and 
// penultimate keypress on the seven-seg display.
//
// On each "new_keypress" pulse (a one cycle pulse from the debouncer that indicates 
// a fresh stable key stroke has been accepted): shift the "current number" to the 
// "previous number", and load "new_key" into the "current number"
// -------------------------------------------------------------
module display_register(input logic         clk,
                        input logic         reset,
                        input logic [3:0]   new_key, // stable key value 
                        input logic         new_keypress, // 1 cycle enable (to load new value)
                        output logic [3:0]  current_number,
                        output logic [3:0]  previous_number);

                        always_ff @(posedge clk) begin
                            if (reset) begin // defualt display values
                                current_number <= 4'h0;
                                previous_number <= 4'h0;
                            end
                            else if (new_keypress) begin
                                previous_number <= current_number; // shift older one out
                                current_number <= new_key; // load newest value in
                            end
                        end
                    
endmodule