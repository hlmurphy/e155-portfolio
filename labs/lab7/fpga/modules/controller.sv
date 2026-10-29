// -------------------------------------------------------------
// controller.sv
// Author: Haspard Murphy <hmurphy@g.hmc.edu>
// Date:   2026-10-27
// Course: HMC E155, Lab 7
// Purpose: Control logic for the AES encryption process
// -------------------------------------------------------------
module controller(input logic clk,
                  input logic load,
                  output logic init,
                  output logic advance,
                  output logic final_round,
                  output logic [3:0] cnt,
                  output logic done);

                  // State Encoding
                  logic [2:0] state, nextstate;
                  logic [3:0] cnt_next;

                  localparam logic [2:0] S_IDLE = 3'd0;
                  localparam logic [2:0] S_INIT = 3'd1;
                  localparam logic [2:0] S_WAIT = 3'd2;
                  localparam logic [2:0] S_ROUND = 3'd3;
                  localparam logic [2:0] S_DONE = 3'd4;

                  always_ff @(posedge clk) begin
                    state <= nextstate;
                    cnt <= cnt_next;
                  end

                  //nextstate logic
                  always_comb begin
                    nextstate = state;
                    case (state)
                    S_IDLE: if (load ==0)       nextstate = S_INIT; //IDLE --> INIT
                    S_INIT:                     nextstate = S_WAIT; //INIT --> WAIT
                    S_WAIT:                     nextstate = S_ROUND; //WAIT --> ROUND
                    S_ROUND: if (cnt == 4'd10)  nextstate = S_DONE; //FINAL_ROUND --> DONE
                          else                  nextstate = S_WAIT; //FINAL_ROUND --> WAIT
                    S_DONE: if (load == 1'b1)   nextstate = S_IDLE; //DONE --> IDLE
                    default: nextstate = S_IDLE;
                    endcase
                  end

                  //Output decoder
                  always_comb begin
                    init          = 1'b0;
                    advance       = 1'b0;
                    final_round   = 1'b0;
                    done          = 1'b0;
                    case (state)  
                      S_INIT:     init = 1'b1;
                      S_ROUND: begin 
                                  advance = 1'b1;
                                  final_round = (cnt == 4'd10) ;
                          end
                      S_DONE:     done = 1'b1;
                      default: ;
                    endcase
                  end

                  //Round Counter 
                  always_comb begin
                    cnt_next = cnt;
                    if (state == S_INIT)
                      cnt_next = 4'd1;
                    else if (state == S_ROUND && nextstate == S_WAIT) begin
                      cnt_next = cnt + 4'd1;
                    end
                  end
                
                  //Initial values for state and counter for simulation
                  initial begin
                    state = S_IDLE;
                    cnt = 4'd0;
                  end
endmodule