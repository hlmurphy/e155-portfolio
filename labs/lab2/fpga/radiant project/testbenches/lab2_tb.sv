// -------------------------------------------------------------
// lab2_tb.sv
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-16
// Course: HMC E155, Lab 2
// Purpose: Top-level self-checking testbench for lab2_hm. 
// -------------------------------------------------------------
`timescale 1ns/1ps

module lab2_tb;
    logic reset;
    logic [3:0] s0, s1;
    logic [6:0] seg;
    logic anode_0, anode_1;
    logic [3:0] rows, cols;
    logic [3:0] col_leds;

    // ---- DUT ----
    lab2_hm #(.display_bit_number(3), .display_max(3), .scan_bit_number(3), .scan_max(3)) 
    dut (.reset(reset), .s0(s0), .s1(s1), .seg(seg), .anode_0(anode_0), .anode_1(anode_1),
                 .cols(cols), .rows(rows), .col_leds(col_leds));

    logic clk = 0;
    always #5 clk = ~clk;
    initial force dut.clk = clk;

    initial begin
        s0    = 4'hF;
        s1    = 4'h2;
        cols  = 4'b1111;
        reset = 1'b0;    // active-low external: 0 = asserted

        // ---- Phase 1: reset propagation ----
        repeat (4) @(posedge clk); #1;
        assert (anode_0 === 1'b1 && anode_1 === 1'b0)
            $display("[t=%0t] PASS phase1 anodes: %b/%b", $time, anode_0, anode_1);
        else
            $error  ("[t=%0t] FAIL phase1 anodes: %b/%b exp 1/0",
                     $time, anode_0, anode_1);
        assert (seg === 7'b0010010)
            $display("[t=%0t] PASS phase1 seg=s1(2): %b", $time, seg);
        else
            $error  ("[t=%0t] FAIL phase1 seg: %b exp %b", $time, seg, 7'b0010010);
        assert (rows === 4'b1000)
            $display("[t=%0t] PASS phase1 rows: %b", $time, rows);
        else
            $error  ("[t=%0t] FAIL phase1 rows: %b exp 1000", $time, rows);

        // Release reset (external active-low)
        reset = 1'b1;

        // ---- Phase 2a: mux flips to select=1, digit 0 shows s0=A ----
        repeat (4) @(posedge clk); #1;
        assert (anode_0 === 1'b0 && anode_1 === 1'b1)
            $display("[t=%0t] PASS phase2a anodes: %b/%b", $time, anode_0, anode_1);
        else
            $error  ("[t=%0t] FAIL phase2a anodes: %b/%b exp 0/1",
                     $time, anode_0, anode_1);
        assert (seg === 7'b0111000)
            $display("[t=%0t] PASS phase2a seg=s0(F): %b", $time, seg);
        else
            $error  ("[t=%0t] FAIL phase2a seg: %b exp %b", $time, seg, 7'b0111000);

        // ---- Phase 2b: mux flips back to select=0, digit 1 shows s1=5 ----
        repeat (4) @(posedge clk); #1;
        assert (anode_0 === 1'b1 && anode_1 === 1'b0)
            $display("[t=%0t] PASS phase2b anodes: %b/%b", $time, anode_0, anode_1);
        else
            $error  ("[t=%0t] FAIL phase2b anodes: %b/%b exp 1/0",
                     $time, anode_0, anode_1);
        assert (seg === 7'b0010010)
            $display("[t=%0t] PASS phase2b seg=s1(2): %b", $time, seg);
        else
            $error  ("[t=%0t] FAIL phase2b seg: %b exp %b", $time, seg, 7'b0010010);

        // ---- Phase 4: col_leds = ~cols ----
        cols = 4'b1000;
        @(posedge clk); #1;
        assert (col_leds === 4'b0111)
            $display("[t=%0t] PASS phase4a col_leds: cols=%b leds=%b",
                     $time, cols, col_leds);
        else
            $error  ("[t=%0t] FAIL phase4a col_leds: %b exp 0111",
                     $time, col_leds);

        cols = 4'b0010;
        @(posedge clk); #1;
        assert (col_leds === 4'b1101)
            $display("[t=%0t] PASS phase4b col_leds: cols=%b leds=%b",
                     $time, cols, col_leds);
        else
            $error  ("[t=%0t] FAIL phase4b col_leds: %b exp 1101",
                     $time, col_leds);

        cols = 4'b1001;
        @(posedge clk); #1;
        assert (col_leds === 4'b0110)
            $display("[t=%0t] PASS phase4c col_leds (idle): cols=%b leds=%b",
                     $time, cols, col_leds);
        else
            $error  ("[t=%0t] FAIL phase4c col_leds: %b exp 0110",
                     $time, col_leds);

        $display("*** lab2_tb complete -- see assertion summary above ***");
        #500;
        $finish;
    end
endmodule
