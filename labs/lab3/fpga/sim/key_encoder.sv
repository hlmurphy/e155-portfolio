// -------------------------------------------------------------
// key_encoder.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-12
// Course: HMC E155, Lab 3
// Purpose: Key Encoder module for Lab 3.
// -------------------------------------------------------------
module key_encoder(input  logic [3:0]   row_active,
                   input  logic [3:0]   cols_in,
                   output logic [3:0]   key_value,
                   output logic         key_valid);
                // Column input is 0 when pressed 
                logic [3:0] cols_pressed;
                assign cols_pressed = ~cols_in;

                // Valid keystroke metric
                assign key_valid = (
                cols_pressed == 4'b0001) || (cols_pressed == 4'b0010) 
                || (cols_pressed == 4'b0100) || (cols_pressed == 4'b1000);

                always_comb
                    case ({row_active, cols_pressed})
                    // Row 0 & Columns 0-3 (R0+C3, R0+C2, R0+C1, ...)
                        8'b0001_1000: key_value = 4'hA;
                        8'b0001_0100: key_value = 4'h3;
                        8'b0001_0010: key_value = 4'h2;
                        8'b0001_0001: key_value = 4'h1;
                    // Row 1 & Columns 0-3
                        8'b0010_1000: key_value = 4'hB;
                        8'b0010_0100: key_value = 4'h6;
                        8'b0010_0010: key_value = 4'h5;
                        8'b0010_0001: key_value = 4'h4;
                    // Row 2 & Columns 0-3
                        8'b0100_1000: key_value = 4'hC;
                        8'b0100_0100: key_value = 4'h9;
                        8'b0100_0010: key_value = 4'h8;
                        8'b0100_0001: key_value = 4'h7;
                    // Row 3 & Columns 0-3
                        8'b1000_1000: key_value = 4'hD;
                        8'b1000_0100: key_value = 4'hF;
                        8'b1000_0010: key_value = 4'h0;
                        8'b1000_0001: key_value = 4'hE;
                    default: key_value = 4'h0; // Upon reset, display zeroes
                    endcase

endmodule