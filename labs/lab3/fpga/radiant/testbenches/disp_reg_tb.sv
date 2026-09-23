// -------------------------------------------------------------
// disp_reg_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-23
// Course: HMC E155, Lab 3
// Purpose: Testbench for Lab 3 Display Register Module
// -------------------------------------------------------------
`timescale 1ns/1ns
`default_nettype none

module display_register_tb;
    logic       clk = 0;
    logic       reset;
    logic [3:0] new_key;
    logic       new_keypress = 0;
    logic [3:0] current_number;
    logic [3:0] previous_number;
    int         errors = 0;

    display_register dut (.clk(clk), .reset(reset), .new_key(new_key), .new_keypress(new_keypress),
                          .current_number(current_number), .previous_number(previous_number));
                          
    always #5 clk = ~clk;

    initial begin
        // reset 
        reset = 1; new_key = 4'h4;
        @(posedge clk); @(posedge clk);
        reset = 0;
        #1;
        assert (current_number == 4'h0 && previous_number == 4'h0)
            $display("[t=%0t] PASS reset defaults", $time);
        else begin
            $error("[t=%0t] FAIL reset: current=%h previous=%h",
                   $time, current_number, previous_number);
            errors++;
        end

        // first load: press key 5
        @(posedge clk); new_key = 4'h5; new_keypress = 1;
        @(posedge clk); new_keypress = 0;
        #1;
        assert (current_number == 4'h5 && previous_number == 4'h0)
            $display("[t=%0t] PASS load '5', current=%h previous=%h",
                     $time, current_number, previous_number);
        else begin
            $error("[t=%0t] FAIL: current =%h previous=%h (expected 5/0)",
                   $time, current_number, previous_number);
            errors++;
        end

        // shift + load: press key A
        @(posedge clk); new_key = 4'hA; new_keypress = 1;
        @(posedge clk); new_keypress = 0;
        #1;
        assert (current_number == 4'hA && previous_number == 4'h5)
            $display("[t=%0t] current=%h previous=%h",
                     $time, current_number, previous_number);
        else begin
            $error("[t=%0t] FAIL shift+load 'A': current=%h previous=%h (expected A/5)",
                   $time, current_number, previous_number);
            errors++;
        end

        // hold check
        @(posedge clk); new_key = 4'h3; new_keypress = 0;   // change new_key but no pulse
        @(posedge clk);
        #1;
        assert (current_number == 4'hA && previous_number == 4'h5)
            $display("[t=%0t] PASS hold (no pulse), current=%h previous=%h",
                     $time, current_number, previous_number);
        else begin
            $error("[t=%0t] FAIL hold: current=%h previous=%h  (expected A/5)",
                   $time, current_number, previous_number);
            errors++;
        end

        if (errors == 0) $display("display_register_tb PASSED");
        else             $display ("FAILED: %0d errors", errors);
        $finish;
    end
endmodule 