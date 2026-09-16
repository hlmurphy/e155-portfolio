// -------------------------------------------------------------
// lab2_tb.sv
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-16
// Course: HMC E155, Lab 2
// Purpose: Top-level self-checking testbench for lab2_hm. 
// -------------------------------------------------------------
module scan_tb;
    logic clk = 0;
    logic reset, enable;
    logic [3:0] rows ;

    scan_counter #(.bit_number(2), .max_count(3)) dut (.clk(clk), .reset(reset), .enable(enable), .rows(rows));

    always begin
        clk = 1; #5;
        clk = 0; #5;
        end

    initial begin
    // Phase 1: Check Reset
    reset = 1; enable = 0;
    @(posedge clk); #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] PASS cold-start reset, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL reset, rows=%b, expected 1000", $time, rows);
    #20;

    //Phase 2: enable = 0 "freeze"
    reset = 0;
    @(posedge clk); #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] PASS enable = 0 (freeze), rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL freeze, rows=%b, expected 1000", $time, rows);
    #20;

    // Phase 3: Cycling through all 4 states (rows)
    enable = 1;
    repeat(4) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b0100)
        $display("[t=%0t] PASS state1, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state1, rows=%b, expected 0100", $time, rows);

    repeat(4) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b0010)
        $display("[t=%0t] PASS state2, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state2, rows=%b, expected 0010", $time, rows);

    repeat(4) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b0001)
        $display("[t=%0t] PASS state3, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state3, rows=%b, expected 0001", $time, rows);

    repeat(4) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] PASS wrap (state0), rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL wrap (state0), rows=%b, expected 1000", $time, rows);

    // Phase 4:
    repeat(2) @(posedge clk); 
    reset = 1;
    @(posedge clk); #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] Pass mid-cycle reset, rows=%b", $time, rows);
    else
        $error("[t=%0t] Fail mid-cycle reset, rows=%b, expected 4'b1000", $time, rows);

    reset = 0;
    #500;

    enable = 0;
    #50;

    $display("*** scan_tb complete ***");
    $finish;
    end    
endmodule
