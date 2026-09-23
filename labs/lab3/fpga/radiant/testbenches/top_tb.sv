// -------------------------------------------------------------
// top_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-022
// Course: HMC E155, Lab 3
// Purpose: Testbench for Lab 3 Top Module
// -------------------------------------------------------------
`timescale 1ns/1ns
`default_nettype none

module top_tb;
        logic reset;
        logic [3:0] cols;
        logic [3:0] rows;
        logic [3:0] col_leds;
        logic [6:0] seg;
        logic       anode0;
        logic       anode1;
        int         errors = 0;

        lab3_hm #(.display_max(3), .display_bit_number(3),.row_scan_max(3), .row_scan_bit_number(3)) 
        dut (.reset(reset), .cols(cols), .rows(rows), .col_leds(col_leds), .seg(seg), .anode_0(anode_0), .anode_1(anode_1));
        
        logic clk = 0;
        always #5 clk = ~clk;
        initial force dut.clk = clk;

        initial begin
            reset = 0;
            cols = 4'b1111;

        end
endmodule