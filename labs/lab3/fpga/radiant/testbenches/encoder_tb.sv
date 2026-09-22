// -------------------------------------------------------------
// encoder_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-07
// Course: HMC E155, Lab 3
// Purpose: Testbench for key encoder module
// -------------------------------------------------------------
`timescale 1ns/1ns
`default_nettype none

module encoder_tb;
    logic [3:0] row_active;
    logic [3:0] cols_in;
    logic [3:0] key_value;
    logic       key_valid;
    int errors = 0;

    key_encoder dut (.row_active(row_active), .cols_in(cols_in), .key_value(key_value), 
    .key_valid(key_valid));

    initial begin
        // Test cases
    {row_active, cols_in} = 8'b0001_1110;
    #10;                        // wait required time
    assert (key_value == 4'h1)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0001_1101;
    #10;                        // wait required time
    assert (key_value == 4'h2)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0001_1011;
    #10;                        // wait required time
    assert (key_value == 4'h3)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0001_0111;
    #10;                        // wait required time
    assert (key_value == 4'hA)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end





    {row_active, cols_in} = 8'b0010_1110;
    #10;                        // wait required time
    assert (key_value == 4'h4)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0010_1101;
    #10;                        // wait required time
    assert (key_value == 4'h5)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0010_1011;
    #10;                        // wait required time
    assert (key_value == 4'h6)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0010_0111;
    #10;                        // wait required time
    assert (key_value == 4'hB)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end





    {row_active, cols_in} = 8'b0100_1110;
    #10;                        // wait required time
    assert (key_value == 4'h7)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0100_1101;
    #10;                        // wait required time
    assert (key_value == 4'h8)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0100_1011;
    #10;                        // wait required time
    assert (key_value == 4'h9)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0100_0111;
    #10;                        // wait required time
    assert (key_value == 4'hC)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end





    {row_active, cols_in} = 8'b1000_1110;
    #10;                        // wait required time
    assert (key_value == 4'hE)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b1000_1101;
    #10;                        // wait required time
    assert (key_value == 4'h0)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b1000_1011;
    #10;                        // wait required time
    assert (key_value == 4'hF)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b1000_0111;
    #10;                        // wait required time
    assert (key_value == 4'hD)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end

    


    {row_active, cols_in} = 8'b0001_1111;
    #10;                        // wait required time
    assert (key_valid == 4'h0)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0001_1100;
    #10;                        // wait required time
    assert (key_valid == 4'h0)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
    {row_active, cols_in} = 8'b0001_1000;
    #10;                        // wait required time
    assert (key_valid == 4'h0)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end
     {row_active, cols_in} = 8'b1000_0111;
    #10;                        // wait required time
    assert (key_valid == 4'h1)       // check outputs
        $display("PASSED! At time: %0t.", $time);
    else begin
        $error("FAILED! At time: %0t.", $time); 
        errors++;
    end


    if (errors == 0) $display("key_encoder PASSED");
    else             $display("key_encoder FAILED: %0d errors", errors);
    $finish;
    end


endmodule