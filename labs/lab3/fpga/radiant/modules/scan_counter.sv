// -------------------------------------------------------------
// scan_counter.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 3
// Purpose: Drive the 4x4 keypad row scan and create timing signals the 
// design needs to register keystrokes
//
// A counter increments when "enable" is high until it hits "max_count", 
// at which point the state advances (00 -> 01 -> 10 -> 11 -> 00). 
// Each states drives one row of the keypad following a one-hot encoding (1000, 0100, ...).
//
// Each state last a total of 47_999 + 1 clock cycles (1 ms), thus 4 ms to scan the entire pad.
//
// We set each state to last this length because the column lines have an RC settling time that 
// can be range of cycles long, so waiting 48k cycles ensures that "cols_synced" is fully settled 
// before sampling ("sample_ok").
//
// We utilize a "end_of_scan" one cycle pulse to denote the end of a full keypad (4-row) scan. 
// It fires when we are in the final state (11), and the count reaches the max_count (48k cycles) 
// indicating we are about to wrap back to state 00 and start a new scan.
//
// "sample_ok" is another one-cycle pulse that fires at the END of every state to ensure the 
// registered cols_synced inputs are settled. Our debouncer modules assign both key_valid 
// and key_value signals when this toggles. 
// -------------------------------------------------------------
module scan_counter #(parameter bit_number = 24, 
        parameter max_count = 11_999_999) // 48_000_000 / 2*2 - 1
        (input logic clk, // Clock signal dervied from internal HSOSC
        input logic reset,
        input logic enable,
        output logic [3:0] rows, // one-hot row encoding driven to keypad
        output logic end_of_scan, // 1-cycle pulse: full keypad scan complete
        output logic sample_ok); // 1-cycle pulse: cols inputs settled

        logic [bit_number-1:0] count = 0; // Initial counter value
        logic            [1:0] state;

        always_ff@(posedge clk)
        begin
            if (reset) begin
                count <= 0;
                state <= 2'b0;
            end
            else if (enable) begin
                if (count == max_count) begin
                count <= 0;             // wrap counter
                state <= state + 1;     // advance to the next row (state) 
                // wraps from 3 -> 0 (2'b11 -> 2'b00)
                end
                else count <= count + 1;
            end
        end

        always_comb begin
            case (state)
            2'b00: rows = 4'b1000;
            2'b01: rows = 4'b0100;
            2'b10: rows = 4'b0010;
            2'b11: rows = 4'b0001;
            default: rows = 4'b1000;
            endcase
        end
        // One cycle pulse to indicate a full scan of the keypad has completed (at the wrap of states)
        assign end_of_scan = enable && (state == 2'b11) && (count == max_count);
        // One cycle pulse to for debouncer to read once cols are settled
        assign sample_ok = enable && (count == max_count);

endmodule