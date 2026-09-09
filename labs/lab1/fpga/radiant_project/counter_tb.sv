// -------------------------------------------------------------
// counter_tb.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-07
// Course: HMC E155, Lab 1
// Purpose: Testbench for counter module 
// -------------------------------------------------------------

module counter_tb;
    logic       clk = 0;
    logic       reset, enable;
    logic [3:0] count;
    logic       tick;
    int         errors = 0;
    logic       led_blink;

    counter #(.N(4), .MAX(9)) dut (.clk(clk), .reset(reset), .enable(enable), .count(count), .tick(tick), .led_blink(led_blink));

    always begin
     clk = 1; #5;
     clk = 0; #5;
     end

    initial begin 

        // reset clears count
        reset = 1; 
        enable = 0;
        #30
        // disabled — count holds until next clock cycle
        reset = 0;
        @(posedge clk);

        // start counter to run until max count several times
        enable = 1;
        #300;

        // reset clears count and holds it at zero until renabled
        reset = 1;
        #
        
        // reset is shut off to resume the counter for the remainder of the simulation
        reset = 0;
        #800;
        $finish;
    end
endmodule