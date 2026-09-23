// -------------------------------------------------------------
// key_encoder.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 3
// Purpose: Key Encoder module for Lab 3.
//
// Inputs) "row_active": row actively being scanned follwoing a correspoding one-hot encoding from the scan_counter
//         "cols_in": syncronized column readback (active low --> 0 when pressed, 1 otherwise)
//
// Outputs) "key_value": pressed key 4-bit hex value
//          "key_valid": 1-bit signal that toggles high if excatly one column is identify to pressed along the active row
// -------------------------------------------------------------
module key_encoder(input  logic [3:0]   row_active,
                   input  logic [3:0]   cols_in,
                   output logic [3:0]   key_value,
                   output logic         key_valid);
                // Column input is 0 when pressed 
                logic [3:0] cols_pressed;
                assign cols_pressed = ~cols_in;

                // Valid keystroke metric (only one key from one row, and only one row)
                assign key_valid = (
                cols_pressed == 4'b0001) || (cols_pressed == 4'b0010) 
                || (cols_pressed == 4'b0100) || (cols_pressed == 4'b1000);

                always_comb
                    case ({row_active, cols_pressed})
                    // Row 0 (row_active = 4'b0001): keys A, 3, 2, 1
                        8'b0001_1000: key_value = 4'hA;
                        8'b0001_0100: key_value = 4'h3;
                        8'b0001_0010: key_value = 4'h2;
                        8'b0001_0001: key_value = 4'h1;
                    // Row 1 (row_active = 4'b0010): keys B, 6, 5, 4
                        8'b0010_1000: key_value = 4'hB;
                        8'b0010_0100: key_value = 4'h6;
                        8'b0010_0010: key_value = 4'h5;
                        8'b0010_0001: key_value = 4'h4;
                    // Row 2 (row_active = 4'b0100): keys C, 9, 8, 7
                        8'b0100_1000: key_value = 4'hC;
                        8'b0100_0100: key_value = 4'h9;
                        8'b0100_0010: key_value = 4'h8;
                        8'b0100_0001: key_value = 4'h7;
                    // Row 3 (row_active = 4'b1000): keys D, F, 0, E
                        8'b1000_1000: key_value = 4'hD;
                        8'b1000_0100: key_value = 4'hF;
                        8'b1000_0010: key_value = 4'h0;
                        8'b1000_0001: key_value = 4'hE;
                    default: key_value = 4'h0; // Upon reset, display zeroes
                    endcase

endmodule