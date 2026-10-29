// -----------------------------------------------------------------------------
// key_expansion.sv
//
// Fully unrolled, combinational implementation of:
//
//   i = 0
//   while i < Nk:            w[i] <- key[4*i .. 4*i+3]
//   while i <= 4*Nr + 3:
//       temp <- w[i-1]
//       if   i mod Nk == 0:                 temp <- module1(module2(temp)) ^ Rcon[i/Nk]
//       elif Nk > 6 and i mod Nk == 4:      temp <- module1(temp)
//       w[i] <- w[i-Nk] ^ temp
//
// Each generated stage i takes the outputs of the earlier stages (w[i-1] and
// w[i-Nk]) as inputs, so the loop becomes a chain of hardware stages. The
// branch conditions depend only on i and Nk, which are known at elaboration
// time. This means each stage instantiates only the hardware for its own branch.
//
// Assumptions:
//   * key is a byte array. A word is 4 bytes, with key[4*i] as the MSB.
//   * module1 and module2 each have a 32-bit input port `in` and a 32-bit
//     output port `out`. Rename the ports if your modules use different names.
//   * Rcon is supplied as an input array of 32-bit words indexed by i/Nk.
//     Index 0 is never used.
// -----------------------------------------------------------------------------
module key_expansion #(
    parameter int Nk = 4,
    parameter int Nr = 10,
    localparam int NW   = 4*Nr + 4,          // total words: w[0 .. 4*Nr+3]
    localparam int NRC  = (4*Nr + 3) / Nk    // largest Rcon index used
) (
    input  logic [7:0]  key  [0:4*Nk-1],
    input  logic [31:0] Rcon [0:NRC],
    output logic [31:0] w    [0:NW-1]
);

    // Internal word array. Each element is a separate stage output. The
    // split_var hint lets Verilator see that no word depends on a later one.
    logic [31:0] wk [0:NW-1] /* verilator split_var */;
    assign w = wk;

    genvar i;
    generate
        // First loop: load the key words directly
        for (i = 0; i < Nk; i++) begin : g_init
            assign wk[i] = {key[4*i], key[4*i+1], key[4*i+2], key[4*i+3]};
        end

        // Second loop: each stage builds on the outputs of earlier stages
        for (i = Nk; i < NW; i++) begin : g_expand
            logic [31:0] temp;

            if (i % Nk == 0) begin : g_mod0
                // temp <- module1(module2(wk[i-1])) ^ Rcon[i/Nk]
                logic [31:0] m2_out, m1_out;
                module2 u_module2 (.in(wk[i-1]), .out(m2_out));
                module1 u_module1 (.in(m2_out), .out(m1_out));
                assign temp = m1_out ^ Rcon[i/Nk];
            end
            else if (Nk > 6 && (i % Nk == 4)) begin : g_mod4
                // temp <- module1(wk[i-1])
                module1 u_module1 (.in(wk[i-1]), .out(temp));
            end
            else begin : g_pass
                // temp <- wk[i-1]
                assign temp = wk[i-1];
            end

            assign wk[i] = wk[i-Nk] ^ temp;
        end
    endgenerate

endmodule
