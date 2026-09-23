// -------------------------------------------------------------
// rst_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-22
// Course: HMC E155, Lab 3
// Purpose: Testbench for reset synchronizer
// -------------------------------------------------------------
`timescale 1ns/1ns
`default_nettype none

module rst_tb;
        logic clk;
        logic reset;
        logic reset_synced;

        int errors = 0;

        reset_sync dut (.clk(clk), .reset(reset), .reset_synced(reset_synced));

        always #5 clk = ~clk;

        initial begin
            clk = 0;
            reset = 0;
            
            #20;
            
            // Reset button pressed
            @(posedge clk);
            reset = 1;
            @(posedge clk); @(posedge clk); 
            #1;
            assert (reset_synced == 1'b1)
                $display("PASSED! At time: %0t.", $time);
            else begin
                $error("FAILED! At time: %0t.", $time); 
                errors++;
            end

            #20;
            
            // Reset button released
            @(posedge clk);
            reset = 0;
            @(posedge clk); @(posedge clk); 
            #1;
            assert (reset_synced == 1'b0)
                $display("PASSED! At time: %0t.", $time);
            else begin
                $error("FAILED! At time: %0t.", $time); 
                errors++;
            end

            if (errors == 0) $display("rst_tb PASSED");
            else             $display("rst_tb FAILED: %0d errors", errors);
            $finish;
        end
        initial begin
            $dumpfile("rst_tb.vcd");
            $dumpvars(0, rst_tb);
        end
endmodule