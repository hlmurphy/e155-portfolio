// -------------------------------------------------------------
// datapath.sv  
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-10-27
// Course: HMC E155, Lab 7
// Purpose:
// -------------------------------------------------------------
module datapath(input logic clk,
                input logic init,
                input logic advance,
                input logic final_round,
                input logic [127:0] key, 
                input logic [127:0] plaintext,
                input logic [3:0] cnt,
                output logic [127:0] cyphertext);

        logic [127:0] initial_state;
        logic [127:0] state_next;

        logic [127:0] state_stored;
        logic [127:0] sub;
        logic [127:0] shifted;
        logic [127:0] mixed;
        logic [127:0] premix;
        logic [127:0] round_out;

        logic [127:0] key_next;
        logic [127:0] key_stored;
        logic [127:0] next_key;

        //instantiate nextkey, mixcolumns, and sbox_sync submodules
        nextkey nk(.prev_key(key_stored), .cnt (cnt), .next_key(next_key));

        sbox_sync sbox00(.clk(clk), .a(state_stored[127:120]), .y(sub[127:120]));
        sbox_sync sbox01(.clk(clk), .a(state_stored[119:112]), .y(sub[119:112]));
        sbox_sync sbox02(.clk(clk), .a(state_stored[111:104]), .y(sub[111:104]));
        sbox_sync sbox03(.clk(clk), .a(state_stored[103:96]),  .y(sub[103:96]));
        sbox_sync sbox04(.clk(clk), .a(state_stored[95:88]),   .y(sub[95:88]));
        sbox_sync sbox05(.clk(clk), .a(state_stored[87:80]),   .y(sub[87:80]));
        sbox_sync sbox06(.clk(clk), .a(state_stored[79:72]),   .y(sub[79:72]));
        sbox_sync sbox07(.clk(clk), .a(state_stored[71:64]),   .y(sub[71:64]));
        sbox_sync sbox08(.clk(clk), .a(state_stored[63:56]),   .y(sub[63:56]));
        sbox_sync sbox09(.clk(clk), .a(state_stored[55:48]),   .y(sub[55:48]));
        sbox_sync sbox10(.clk(clk), .a(state_stored[47:40]),   .y(sub[47:40]));
        sbox_sync sbox11(.clk(clk), .a(state_stored[39:32]),   .y(sub[39:32]));
        sbox_sync sbox12(.clk(clk), .a(state_stored[31:24]),   .y(sub[31:24]));
        sbox_sync sbox13(.clk(clk), .a(state_stored[23:16]),   .y(sub[23:16]));
        sbox_sync sbox14(.clk(clk), .a(state_stored[15:8]),    .y(sub[15:8]));
        sbox_sync sbox15(.clk(clk), .a(state_stored[7:0]),     .y(sub[7:0]));

        //shiftrows
        assign shifted = {sub[127:120], sub[87:80], sub[47:40], sub[7:0],
                          sub[95:88], sub[55:48], sub[15:8], sub[103:96],
                          sub[63:56], sub[23:16], sub[111:104], sub[71:64],
                          sub[31:24], sub[119:112], sub[79:72], sub[39:32]};

        mixcolumns mc(.a(shifted), .y(mixed));

        assign initial_state = key ^ plaintext;
        assign state_next = init ? initial_state : round_out;

        always_ff @(posedge clk) begin
            if (init | advance) begin
                state_stored <= state_next;
                key_stored <= key_next;
            end
        end

        assign key_next =  init ? key : next_key;

        assign premix = final_round ? shifted : mixed;
        assign round_out = premix ^ next_key;

        assign cyphertext = state_stored;
endmodule