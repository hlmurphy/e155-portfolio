// -------------------------------------------------------------
// display_scan.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 2
// Purpose: Counter module for muxing the two 7-segment displays.
// -------------------------------------------------------------
module display_scan #(parameter bit_number = 15, parameter max_count = 23_999) // 48_000_000 / (2 * 1_000) - 1)(
    (input logic clk, // Clock signal dervied from internal HSOSC
    input logic reset, 
    output logic select = 0); // High when counter reaches the max_count, used to select which display to show
    logic [bit_number-1:0] count = 0; // Current counter value

    always_ff@(posedge clk)
    begin
        if (reset) begin
            count <= 0; 
            select <= 0;
        end
        else if (count == max_count) begin
                count <= 0;
                select <= ~select;
        end 
        else count <= count + 1;
    end
endmodule 