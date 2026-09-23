// -------------------------------------------------------------
// debouncer.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 3
// Purpose: Debouncer module for Lab 3.
//
// This module addresses two issues.
// 1: Only one row is active during each state per the one-hot encoding. Thus,
// a valid keypress can occur, and only occur, during any of the four states, but only once during
// one complete scan of the keypad. So, we use both "scan_seen_valid" and "scan_seen_value" respectively
// to represent the corresponding keystroke observed if any during a full keypad scan. 
//
// 2: When a key is pressed, the switch bounces high and low until it eventually stabilizes on its settled state. 
// So, to establish we are reading the correct stable signal of a key being pressed or not pressed, we wait a 
// certain number of consective N_STABLE keypad scans after the initial indication of a key being pressed and assess if the same key is
// showing as pressed through this period indicating a continuous (correct) toggle, and then we assign "key_stable" 
// as our final output key value.
//
// Inputs) "sample_ok": one-cycle-per-state pulse from the scan_counter that indicates the cols_synced inputs are settled 
//                      for the current active row. By measuring captures when "sample_ok" is high, we prevent the any 
//                      ghost/metastable decodings that occur during the state transition.                       
//        "end_of_scan": one cycle pulse from scan_counter that indicates the completion of 1 full scan of the keypad. 
//                       We use this pulse to indicates when we can evaluate the accumulated result (collected across all 4 rows)
//
// Outputs) "key_stable": final accepted, debounced, key hex value
//          "new_keypress": one-cycle pulse that executes on the cycle key_stable is updated so the display_register module loads a 
//                          new value.
// 
// -------------------------------------------------------------
module debouncer #(parameter N_STABLE = 3)(
                input logic        clk,
                input logic        reset,
                input logic [3:0]  key_value,
                input logic        key_valid,
                input logic        sample_ok, // 1 cycle/state to indicated cols_synced are settled
                input logic        end_of_scan, // 1 cycle/full scan to indicate the time to evauluate scanned results
                output logic [3:0] key_stable,
                output logic       new_keypress);

                // Per scan accumulator that check if any valid presses were identity on the most recent full scan
                logic       scan_seen_valid; // only one or no keypresses observed boolean 
                logic [3:0] scan_seen_value; // hex value of the corresponding valid keystroke

                logic       multi_press_seen;
                logic       multi_this_cycle;

                // Scan memory: to check what the previous results was and how many consecutive scans has that been the result
                logic [4:0] prev_scan_result; // both hex value and keystoke validity boolean from the previous scan 
                logic [1:0] match_counter; // sub module counter incremented to delay stability determination (counts up to N_STABLE-1)
                
                // Check if we have already pulsed the most recent change in keypress. Prevents repeat pulses when a key is held down
                logic       stable_present; // identified stable press 

                // Result for the CURRENT cycle (the end_of_scan state). The resulting key_valid and key_value are OR'd and muxed 
                // respectively to the accumulator to ensure a keypress during the end_of_scan state (2'b11) isn't missed.
                logic current_valid;
                logic [3:0] current_value; 
                logic [4:0] current_result; 
                // OR gate
                assign current_valid = scan_seen_valid | key_valid; 
                // 2:1 mux to ensure the same key is being recognized as pressed at all times
                assign current_value = key_valid ? key_value : scan_seen_value;
                // wire bundle of 5 bits (1 + 4)
                assign current_result = {current_valid, current_value}; 

                logic       effective_valid;
                logic [3:0] effective_value;
                logic [4:0] effective_result;

                assign multi_this_cycle = multi_press_seen || (scan_seen_valid && key_valid);
                assign effective_valid  = current_valid && !multi_this_cycle;
                assign effective_value  = effective_valid ? current_value : 4'b0;
                assign effective_result = {effective_valid, effective_value};

                always_ff @(posedge clk) begin
                    if (reset) begin // Upon reset, return to state zero
                        scan_seen_valid     <= 0;
                        scan_seen_value     <= 4'b0;
                        multi_press_seen    <= 0;
                        prev_scan_result    <= 5'b0;
                        match_counter       <= 2'b0;
                        key_stable          <= 4'b0;
                        stable_present      <= 0;
                        new_keypress           <= 0;
                    end
                    else begin
                        // new_keypress is a one cycle pulse so it must be set to 0 everytime 
                        // unless it is reasserted during the evaluation 
                        new_keypress <= 0;
                        if (end_of_scan) begin // Wipe accumulator for the next full scan
                            scan_seen_valid <= 0;
                            scan_seen_value <= 4'b0;
                            multi_press_seen <= 0;
                            if (effective_result == prev_scan_result) begin // Assess current and compare to establish stability
                                if (match_counter != N_STABLE - 1)
                                    match_counter <= match_counter + 1;
                                else begin
                                    if (effective_valid && ~stable_present) begin // Toggle new_keypress and set the output to the stable concluded value (hex)
                                        new_keypress <= 1;
                                        key_stable <= effective_value;
                                    end
                                    stable_present <= effective_valid; // tracks held down state to prevents repeat new_keypress pulses
                                end 
                            end
                            else begin // full scan results did not match, update and reassess by restarting the counter. 
                                prev_scan_result <= effective_result;
                                match_counter <= 2'b0;
                            end 
                        end
                        else if (sample_ok && key_valid) begin // update accumulator for the CURRENT cycle
                            if (scan_seen_valid) 
                                multi_press_seen <= 1;
                            scan_seen_valid <= 1; 
                            scan_seen_value <= key_value;
                        end
                    end 
                end 
endmodule