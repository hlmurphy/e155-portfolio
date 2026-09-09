// -------------------------------------------------------------
// lab1_hm.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-07
// Course: HMC E155, Lab 1
// Purpose: Top-level module for Lab 1
// -------------------------------------------------------------
module lab1_hm  #(parameter int blink_max = 9_999_999)(
    input   logic [3:0] s,
    output  logic [2:0] led,
    output  logic [6:0] seg);

    // Internal clock signal from 48MHz oscillator
    logic clk;
    HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

    // Combinational logic for LED 0 & 1
    assign led[0] = s[0] ^ s[1];
    assign led[1] = s[2] & s[3];

    // Seven-segment display decoder
    seven_segment_decoder u_dec (.data(s), .segments(seg));

    // Counter for blinking LED
    logic tick;
    counter #(.MAX(blink_max))
    u_counter (.clk(clk), .reset(1'b0), .enable(1'b1), .count(), .tick(tick), .led_blink(led[2]));
endmodule
