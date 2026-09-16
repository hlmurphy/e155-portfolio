// -------------------------------------------------------------
// lab2_hm.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 2
// Purpose: Top-level module for Lab 2 instatiating the seven_segment_decoder module 
// (output logic for the two 7-segment displays) and the counter module (scanning the inputs from the keypad matrix).
// -------------------------------------------------------------
module lab2_hm #(parameter display_max = 23_999,
                 parameter display_bit_number = 15,
                 parameter scan_max = 11_999_999,
                 parameter scan_bit_number = 24)
                (input logic reset,
                // Hex data sources for two seven segment displays
                input logic [3:0] s0,
                input logic [3:0] s1,
                // Display outputs 
                output logic [6:0] seg,
                output logic anode_0, 
                output logic anode_1,
                // Keypad 
                input logic [3:0] cols, // read from the 4 column lines
                output logic [3:0] rows, // to the NPN transitors bases
                output logic [3:0] col_leds); // LED's echocing column reads
                
        logic reset_inv;
        assign reset_inv = ~reset;
        
        // Internal clock signal from 48MHz oscillator
        logic clk;
        HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

        // Internal Signals
        logic select;
        logic [3:0] hex_current;

        // Instantiate both counter modules for muxing displays and scanning keypad inputs
        display_scan #(.bit_number(display_bit_number), .max_count(display_max))
        u_display_scan (.clk(clk), .reset(reset_inv), .enable(1'b1), .select(select));

        scan_counter #(.bit_number(scan_bit_number), .max_count(scan_max)) 
        u_scan_counter (.clk(clk), .reset(reset_inv), .enable(1'b1), .rows(rows));

        // 2:1 mux for hex digit shown on each display
        assign hex_current = select ? s0 : s1;

        // Establishing seven segment displays
        assign anode_0 = ~select;
        assign anode_1 = select;

        // Connecting columns to corresponding LED's
        assign col_leds = ~cols;

        // Instantiate seven_segment_decoder module
        seven_segment_decoder u_dec (.data(hex_current), .segments(seg));
endmodule