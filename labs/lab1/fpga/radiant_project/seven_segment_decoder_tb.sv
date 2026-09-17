// -------------------------------------------------------------
// seven_segment_decoder_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-07
// Course: HMC E155, Lab 1
// Purpose: Testbench for seven_segment_decoder
// -------------------------------------------------------------
`timescale 1ns/1ns
`default_nettype none

module seven_segment_decoder_tb;
    logic [3:0] data;
    logic [6:0] segments;
    int         errors = 0;

    seven_segment_decoder dut (.data(data), .segments(segments));

    initial begin
        // Test cases
        data = 4'b0000;
    #10;                        // wait required time
    assert (segments == 7'b0000001)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    data = 4'b0001;
    #10;
    assert (segments == 7'b1001111)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    data = 4'b0010;
    #10;
    assert (segments == 7'b0010010)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    data = 4'b0011;
    #10;
    assert (segments == 7'b0000110)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    data = 4'b0100;
    #10;
    assert (segments == 7'b1001100)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    data = 4'b0101;
    #10;
    assert (segments == 7'b0100100)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b0110;
    #10;
    assert (segments == 7'b0100000)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b0111;
    #10;
    assert (segments == 7'b0001111)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b1000;
    #10;
    assert (segments == 7'b0000000)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b1001;
    #10;
    assert (segments == 7'b0000100)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    data = 4'b1010;
    #10;
    assert (segments == 7'b0001000)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    
    data = 4'b1011;
    #10;
    assert (segments == 7'b1100000)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b1100;
    #10;
    assert (segments == 7'b0110001)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b1101;
    #10;
    assert (segments == 7'b1000010)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b1110;
    #10;
    assert (segments == 7'b0110000)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    data = 4'b1111;
    #10;
    assert (segments == 7'b0111000)
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    if (errors == 0) $display("decoder PASSED");
    else             $display("lab1_hm FAILED: %0d errors", errors);
    $finish;
    end

endmodule