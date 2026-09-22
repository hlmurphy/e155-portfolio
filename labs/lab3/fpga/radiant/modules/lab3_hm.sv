// -------------------------------------------------------------
// lab3_hm.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-20
// Course: HMC E155, Lab 3
// Purpose: Top-level module for Lab 3
// -------------------------------------------------------------
module lab3_hm #(parameter display_max = 23_999,
                parameter display_bit_number = 15,
                parameter row_scan_max = 47_999,
                parameter row_scan_bit_number = 16,
                parameter settle_time = 500)(
                input logic         reset,
                input logic [3:0]   cols,
                output logic [3:0]  rows,
                output logic [3:0]  col_leds,
                output logic [6:0]  seg,
                output logic        anode_0, 
                output logic        anode_1);
        
        // Internal wire declarations
        logic reset_inv; // inverted reset
        logic reset_synced;

        logic [3:0] rows_one_hot;
        logic       end_of_scan;

        logic [3:0] cols_synced;

        logic [3:0] key_value;
        logic       key_valid;

        logic [3:0] key_stable;
        logic       new_keypress;

        logic [3:0] current_number;
        logic [3:0] previous_number;
        logic       select;
        logic [3:0] hex_current;

        // Internal clock signal from 48MHz oscillator
        logic clk;
        HSOSC hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

        scan_counter #(.bit_number(row_scan_bit_number), .max_count(row_scan_max), .settle_time(settle_time))
        u_scan_counter (.clk(clk), .reset(reset_synced), .enable(1'b1), .rows(rows_one_hot), 
        .end_of_scan(end_of_scan));


        cols_sync u_cols_sync (.clk(clk), .reset(reset_synced), .cols_in(cols), 
        .cols_synced(cols_synced));

        reset_sync u_reset_sync (.clk(clk), .reset(reset_inv), .reset_synced(reset_synced));

        key_encoder u_key_encoder(.row_active(rows_one_hot), .cols_in(cols_synced), 
        .key_value(key_value), .key_valid(key_valid));

        debouncer #(.N_STABLE(3))
        u_debouncer (.clk(clk), .reset(reset_synced), .key_value(key_value),
        .key_valid(key_valid), .end_of_scan(end_of_scan), .key_stable(key_stable),
        .new_keypress(new_keypress));

        display_register u_display_register (.clk(clk), .reset(reset_synced), .new_key(key_stable), 
        .new_keypress(new_keypress), .current_number(current_number), .previous_number(previous_number));

        display_scan #(.bit_number(display_bit_number), .max_count(display_max))
        u_display_scan (.clk(clk), .reset(reset_synced), .enable(1'b1), .select(select));

        // Instantiate seven_segment_decoder module
        seven_segment_decoder u_dec (.data(hex_current), .segments(seg));



        // 2:1 mux for hex digit shown on each display
        assign hex_current = select ? previous_number : current_number;

        // Establishing seven segment displays
        assign anode_0 = ~select;
        assign anode_1 = select;

        assign rows = rows_one_hot;

        assign reset_inv = ~reset;

        // Connecting columns to corresponding LED's
        assign col_leds = ~cols_synced;



endmodule