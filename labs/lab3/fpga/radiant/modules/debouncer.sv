// -------------------------------------------------------------
// debouncer.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 3
// Purpose: Debouncer module for Lab 3.
// -------------------------------------------------------------
module debouncer #(parameter N_STABLE = 3)(
                input logic        clk,
                input logic        reset,
                input logic [3:0]  key_value,
                input logic        key_valid,
                input logic        sample_ok,
                input logic        end_of_scan,
                output logic [3:0] key_stable,
                output logic       new_keypress);

                logic       scan_seen_valid; // only one or no keypresses observed boolean 
                logic [3:0] scan_seen_value; // hex value of the correpsonding valid keystroke
                logic [4:0] prev_scan_result; // both hex value and keystoke boolean from the previous scan 
                logic [1:0] match_counter; // sub module counter incremnted to delay stability determination
                logic       stable_present; // identified stable press boolean

                logic this_valid;
                logic [3:0] this_value; 
                logic [4:0] this_result; 

                // OR gate
                assign this_valid = scan_seen_valid | key_valid; 
                // 2:1 mux to ensure the same key is being recognized as pressed at all times
                assign this_value = key_valid ? key_value : scan_seen_value;
                // wire bundle of 5 bits (1 + 4)
                assign this_result = {this_valid, this_value}; 

                always_ff @(posedge clk) begin
                    if (reset) begin // Upon reset, return to state zero
                        scan_seen_valid     <= 0;
                        scan_seen_value     <= 4'b0;
                        prev_scan_result    <= 5'b0;
                        match_counter       <= 2'b0;
                        key_stable          <= 4'b0;
                        stable_present      <= 0;
                        new_keypress           <= 0;
                    end
                    else begin
                        new_keypress <= 0;
                        if (end_of_scan) begin
                            scan_seen_valid <= 0;
                            scan_seen_value <= 4'b0;
                            if (this_result == prev_scan_result) begin
                                if (match_counter != N_STABLE - 1)
                                    match_counter <= match_counter + 1;
                                else begin
                                    if (this_valid && ~stable_present) begin
                                        new_keypress <= 1;
                                        key_stable <= this_value;
                                    end
                                    stable_present <= this_valid;
                                end 
                            end
                            else begin
                                prev_scan_result <= this_result;
                                match_counter <= 2'b0;
                            end 
                        end
                        else if (sample_ok && key_valid) begin
                            scan_seen_valid <= 1;
                            scan_seen_value <= key_value;
                        end
                    end 
                end 
endmodule