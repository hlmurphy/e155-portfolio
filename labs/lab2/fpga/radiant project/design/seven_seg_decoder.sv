// -------------------------------------------------------------
// seven_segment_decoder.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-09-07
// Course: HMC E155, Lab 1
// Purpose: 4-bit hex -> active-low 7-segment display pattern
// -------------------------------------------------------------

module seven_segment_decoder(
    input  logic [3:0] data,
    output logic [6:0] segments);

    always_comb
        case (data)
        // abc_defg
        4'h0: segments = 7'b0000001; // 0
        4'h1: segments = 7'b1001111; // 1
        4'h2: segments = 7'b0010010; // 2
        4'h3: segments = 7'b0000110; // 3
        4'h4: segments = 7'b1001100; // 4
        4'h5: segments = 7'b0100100; // 5
        4'h6: segments = 7'b0100000; // 6
        4'h7: segments = 7'b0001111; // 7
        4'h8: segments = 7'b0000000; // 8
        4'h9: segments = 7'b0000100; // 9
        4'hA: segments = 7'b0001000; // A
        4'hB: segments = 7'b1100000; // B
        4'hC: segments = 7'b0110001; // C
        4'hD: segments = 7'b1000010; // D
        4'hE: segments = 7'b0110000; // E
        4'hF: segments = 7'b0111000; // F
        default: segments = 7'b1111111; // Blank
        endcase

endmodule