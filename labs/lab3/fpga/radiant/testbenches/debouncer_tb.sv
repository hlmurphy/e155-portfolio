// -------------------------------------------------------------
// debouncer_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-022
// Course: HMC E155, Lab 3
// Purpose: Testbench for debouncer module
// -------------------------------------------------------------
`timescale 1ns/1ns
`default_nettype none

module debouncer_tb;
        logic        clk = 0;
        logic        reset;
        logic [3:0]  key_value;
        logic        key_valid;
        logic        sample_ok; 
        logic        end_of_scan; 
        logic [3:0] key_stable;
        logic       new_keypress;
        int         errors = 0;

        debouncer #(.N_STABLE(3)) dut (.clk(clk), .reset(reset), .key_value(key_value),
        .key_valid(key_valid), .sample_ok(sample_ok), .end_of_scan(end_of_scan), .key_stable(key_stable),
        .new_keypress(new_keypress));

        always #5 clk = ~clk;


        initial begin
            // reset test
            reset = 1;
            @(posedge clk); #1;
            assert (key_stable == 0 && new_keypress == 0)
                $display("[t=%0t] PASS cold-start reset", $time);
            else begin
                $error("[t=%0t] FAIL reset", $time);
                errors++;
            end

            @(posedge clk);
            @(posedge clk);
            reset = 0;

            // Stable key press for 4 scans
            @(posedge clk); 
            sample_ok = 1; key_valid = 1; key_value = 4'h5;
            @(posedge clk); 
            sample_ok = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            // scan 2
            @(posedge clk);
             sample_ok = 1; key_valid = 1; key_value = 4'h5;
            @(posedge clk); 
            sample_ok = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            // scan 3
            @(posedge clk); 
            sample_ok = 1; key_valid = 1; key_value = 4'h5;
            @(posedge clk); 
            sample_ok = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            // scan 4 → latch fires on this end_of_scan
            @(posedge clk); sample_ok = 1; key_valid = 1; key_value = 4'h5;
            @(posedge clk); sample_ok = 0;
            @(posedge clk); end_of_scan = 1;
            @(posedge clk); end_of_scan = 0;
            #1;
            assert (key_stable === 4'h5 && new_keypress === 1'b1)
                $display("[t=%0t] PASS block 2: stable press latched to 5", $time);
            else begin
                $error("[t=%0t] FAIL block 2: key_stable=%h new_keypress=%b (expected 5/1)",
                    $time, key_stable, new_keypress);
                errors++;
            end

            // Bounced key press rejection test
            reset = 1; key_valid = 0; key_value = 0; sample_ok = 0; end_of_scan = 0;
            @(posedge clk); @(posedge clk);
            reset = 0;
            // bounce scan 1
            @(posedge clk); 
            sample_ok = 1; key_valid = 1; key_value = 4'h5;
            @(posedge clk); 
            sample_ok = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            // bounce scan 2 
            @(posedge clk); 
            sample_ok = 1; key_valid = 0; key_value = 4'h0;
            @(posedge clk); 
            sample_ok = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            // bounce scan 3
            @(posedge clk); 
            sample_ok = 1; key_valid = 1; key_value = 4'h5;
            @(posedge clk); 
            sample_ok = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            // bounce scan 4
            @(posedge clk); 
            sample_ok = 1; key_valid = 0; key_value = 4'h0;
            @(posedge clk); 
            sample_ok = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            #1;
            assert (key_stable === 4'h0 && new_keypress === 1'b0)
                $display("[t=%0t] PASS block 6: bounce filtered out", $time);
            else begin
                $error("[t=%0t] FAIL block 6: key_stable=%h new_keypress=%b (expected 0/0)",
                    $time, key_stable, new_keypress);
                errors++;
            end

            reset = 1; key_valid = 0; key_value = 0; sample_ok = 0; end_of_scan = 0;
            @(posedge clk); @(posedge clk); 
            reset = 0;

            // One "scan" with two mid-sweep valid captures (row A key, row B key), then end_of_scan idle
            repeat (4) begin
            // row-A sample: capture key '5'
            @(posedge clk); 
            sample_ok = 1; key_valid = 1; key_value = 4'h5;
            @(posedge clk); 
            sample_ok = 0;
            // row-B sample: capture key 'A' → multi_press_seen sets
            @(posedge clk); 
            sample_ok = 1; key_valid = 1; key_value = 4'hA;
            @(posedge clk); 
            sample_ok = 0;
            // idle intermediate + end_of_scan
            @(posedge clk); 
            key_valid = 0;
            @(posedge clk); 
            end_of_scan = 1;
            @(posedge clk); 
            end_of_scan = 0;
            end
            #1;
            assert (key_stable === 4'h0 && new_keypress === 1'b0)
                $display("PASS multi-row multi-press rejected");
            else begin
                $error("FAIL multi-row multi-press latched: key_stable=%h new_keypress=%b", key_stable, new_keypress);
                errors++;
            end
            if (errors == 0) $display("debouncer_tb PASSED");
            else             $display("debouncer_tb FAILED: %0d errors", errors);
            $finish;
        end
endmodule
        