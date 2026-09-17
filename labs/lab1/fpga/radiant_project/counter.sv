// -------------------------------------------------------------
// counter.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-07
// Course: HMC E155, Lab 1
// Purpose: Counter with enable and tick output
// -------------------------------------------------------------

module counter #(
    parameter N = 24,
    parameter MAX = 9_999_999)// 48_000_000 / (2 * 2.4) - 1)(
    (input logic clk, // Clock signal dervied from internal HSOSC
    input logic reset,
    input logic enable,
    output logic [N-1:0] count = '0, // Current counter value
    output logic tick,
    output logic led_blink = '0); // High when counter reaches MAX (tick)


    always_ff@(posedge clk)
    begin
        if (reset) count <= 0;
        else if (enable) begin
            if (count == MAX) count <= 0;
            else count <= count + 1;
        end
    end

    // Toggle the blink output on each tick
    always_ff@(posedge clk) begin
        if (reset) led_blink <= 0;
        else if (tick) led_blink <= ~led_blink;
    end
    assign tick = (count == MAX);
endmodule
