// -------------------------------------------------------------
// scan_tb.sv
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-22
// Course: HMC E155, Lab 3
// Purpose: Scanning module self-checking testbench for Lab 3. 
// -------------------------------------------------------------

module scan_tb;
    logic clk = 0;
    logic reset, enable;
    logic [3:0] rows;
    logic end_of_scan, sample_ok;


    scan_counter #(.bit_number(2), .max_count(3)) dut (.clk(clk), .reset(reset), .enable(enable), .rows(rows), 
        .end_of_scan(end_of_scan), .sample_ok(sample_ok));

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
    assert (sample_ok === 1'b0)
        $display("[t=%0t] PASS sample_ok in state0", $time);
    else
        $error("[t=%0t] FAIL sample_ok in state0 = %b", $time, sample_ok);
    assert (end_of_scan === 1'b0)
        $display("[t=%0t] PASS end_of_scan low in state0", $time);
    else
        $error("[t=%0t] FAIL end_of_scan should be low in state0", $time);
    #20;

    //Phase 2: enable = 0 "freeze"
    reset = 0;
    @(posedge clk); #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] PASS enable = 0 (freeze), rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL freeze, rows=%b, expected 1000", $time, rows);
    assert (sample_ok === 1'b0)
        $display("[t=%0t] PASS sample_ok during freeze", $time);
    else
        $error("[t=%0t] FAIL sample_ok during freeze = %b", $time, sample_ok);
    #20;

    // Phase 3: Cycling through all 4 states (rows)
    enable = 1;

    // state 00
    repeat(3) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] PASS state0, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state0, rows=%b, expected 1000", $time, rows);
    assert (sample_ok === 1'b1)
        $display("[t=%0t] PASS sample_ok in state0", $time);
    else
        $error("[t=%0t] FAIL sample_ok in state0 = %b", $time, sample_ok);
    assert (end_of_scan === 1'b0)
        $display("[t=%0t] PASS end_of_scan low in state0", $time);
    else
        $error("[t=%0t] FAIL end_of_scan should be low in state0", $time);

    // Transition into State 01

    @(posedge clk); 
    #1;
    assert (rows == 4'b0100)
        $display("[t=%0t] PASS state1, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state1, rows=%b, expected 0100", $time, rows);
    assert (sample_ok === 1'b0)
        $display("[t=%0t] PASS sample_ok in state1", $time);
    else
        $error("[t=%0t] FAIL sample_ok in state1 = %b", $time, sample_ok);
    
    // State 01 
    repeat(3) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b0100)
        $display("[t=%0t] PASS state1, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state1, rows=%b, expected 0100", $time, rows);
    assert (sample_ok === 1'b1)
        $display("[t=%0t] PASS sample_ok in state1", $time);
    else
        $error("[t=%0t] FAIL sample_ok in state1 = %b", $time, sample_ok);
    assert (end_of_scan === 1'b0)
        $display("[t=%0t] PASS end_of_scan low in state1", $time);
    else
        $error("[t=%0t] FAIL end_of_scan should be low in state1", $time);

    // Transition into state 10
    @(posedge clk); 
    #1;
    assert (rows == 4'b0010)
        $display("[t=%0t] PASS state2, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state2, rows=%b, expected 0010", $time, rows);

    // State 10 
    repeat(3) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b0010)
        $display("[t=%0t] PASS state2, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state2, rows=%b, expected 0010", $time, rows);
    assert (sample_ok === 1'b1)
        $display("[t=%0t] PASS sample_ok in state2", $time);
    else
        $error("[t=%0t] FAIL sample_ok in state2 = %b", $time, sample_ok);
    assert (end_of_scan === 1'b0)
        $display("[t=%0t] PASS end_of_scan low in state2", $time);
    else
        $error("[t=%0t] FAIL end_of_scan should be low in state2", $time);

    // Transition into state 11
    @(posedge clk); 
    #1;
    assert (rows == 4'b0001)
        $display("[t=%0t] PASS state3, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state3, rows=%b, expected 0001", $time, rows);
    
    // State 11 
    repeat(3) @(posedge clk); // next-state
    #1;
    assert (rows == 4'b0001)
        $display("[t=%0t] PASS state3, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL state3, rows=%b, expected 0001", $time, rows);
    assert (sample_ok === 1'b1)
        $display("[t=%0t] PASS sample_ok in state3", $time);
    else
        $error("[t=%0t] FAIL sample_ok in state3 = %b", $time, sample_ok);
    assert (end_of_scan === 1'b1)
        $display("[t=%0t] PASS end_of_scan pulse in state3", $time);
    else
        $error("[t=%0t] FAIL end_of_scan should assert state3 = %b", $time, end_of_scan);

    // Wrap into state 00
    @(posedge clk); // next-state
    #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] PASS wrap to state0, rows=%b", $time, rows);
    else
        $error("[t=%0t] FAIL wrap, rows=%b, expected 1000", $time, rows);
    assert (end_of_scan === 1'b0)
        $display("[t=%0t] PASS end_of_scan low after wrap", $time);
    else
        $error("[t=%0t] FAIL end_of_scan = %b after wrap", $time, end_of_scan);
    assert (sample_ok === 1'b0)
        $display("[t=%0t] PASS sample_ok after wrap", $time);
    else
        $error("[t=%0t] FAIL sample_ok = %b after wrap", $time, sample_ok);


    // Phase 4:
    repeat(2) @(posedge clk); 
    reset = 1;
    @(posedge clk); #1;
    assert (rows == 4'b1000)
        $display("[t=%0t] Pass mid-cycle reset, rows=%b", $time, rows);
    else
        $error("[t=%0t] Fail mid-cycle reset, rows=%b, expected 4'b1000", $time, rows);
    assert (sample_ok === 1'b0)
        $display("[t=%0t] PASS sample_ok under reset", $time);
    else
        $error("[t=%0t] FAIL sample_ok = %b under reset", $time, sample_ok);
    assert (end_of_scan === 1'b0)
        $display("[t=%0t] PASS end_of_scan low under reset", $time);
    else
        $error("[t=%0t] FAIL end_of_scan = %b under reset", $time, end_of_scan);

    reset = 0;
    #500;
    
    enable = 0;
    #50;

    $display("*** scan_tb complete ***");
    $finish;
    end    
endmodule
