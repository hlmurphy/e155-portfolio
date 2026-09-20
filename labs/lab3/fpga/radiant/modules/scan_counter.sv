// -------------------------------------------------------------
// scan_counter.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 2
// Purpose: Counter module for scanning the rows of the keypad matrix
// -------------------------------------------------------------
module scan_counter #(parameter bit_number = 24, 
        parameter max_count = 11_999_999) // 48_000_000 / 2*2 - 1
        (input logic clk, // Clock signal dervied from internal HSOSC
        input logic reset,
        input logic enable,
        output logic [3:0] rows,
        output logic end_of_scan);

        logic [bit_number-1:0] count = 0; // Current counter value
        logic            [1:0] state;

        always_ff@(posedge clk)
        begin
            if (reset) begin
                count <= 0;
                state <= 2'b0;
            end
            else if (enable) begin
                if (count == max_count) begin
                count <= 0;
                state <= state + 1;
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

endmodule