// -------------------------------------------------------------
// top_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-023
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
        logic       anode_0;
        logic       anode_1;
        int         errors = 0;

        logic [1:0] pressed_row;
        logic [1:0] pressed_col;
        logic key_down;

        lab3_hm #(.display_max(3), .display_bit_number(3),.row_scan_max(3), .row_scan_bit_number(3)) 
        dut (.reset(reset), .cols(cols), .rows(rows), .col_leds(col_leds), .seg(seg), .anode_0(anode_0), .anode_1(anode_1));
        
        logic clk = 0;
        always #5 clk = ~clk;
        initial force dut.clk = clk;

        always_comb begin
            cols = 4'b1111;
            if (key_down && rows[pressed_row])
                cols[pressed_col] = 1'b0;
        end 
        

        initial begin
            key_down = 1'b0;
            pressed_row = 2'b00;
            pressed_col = 1'b0;
            reset = 0;
            @(posedge clk); @(posedge clk);
            reset = 1;
            
            #10;
            key_down = 1'b1;
            repeat(20)@(posedge clk);

            assert (dut.current_number == 4'h1)
                $display("PASSED! current_number=%h at time: %0t.", dut.current_number,  $time);
            else begin
                $error("FAILED! current number=%h, expected 1 at time: %0t.", dut.current_number, $time); 
                errors++;
            end

            if (errors == 0) $display("top_tb PASSED");
            else             $display("top_tb FAILED: %0d errors", errors);
            $finish;
        end
endmodule