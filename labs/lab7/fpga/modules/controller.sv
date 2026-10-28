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
                  output logic [3:0] cnt = 4'd0,
                  output logic done);

                  logic [2:0] state = 3'd0;
                  logic [2:0] nextstate;
                  logic [3:0] cnt_next;

                  always_ff @(posedge clk) begin
                    state <= nextstate;
                    cnt <= cnt_next;
                  end

                  //nextstate logic
                  always_comb begin
                    nextstate = state;
                    case (state)
                    3'd0: if (load == 1'b0) nextstate = 3'd1; //IDLE --> INIT
                    3'd1: nextstate = 3'd2; //INIT --> WAIT
                    3'd2: nextstate = 3'd3; //WAIT --> ROUND
                    3'd3: if (cnt == 4'd10) nextstate = 3'd4; //FINAL_ROUND --> DONE
                          else nextstate = 3'd2; //FINAL_ROUND --> WAIT
                    3'd4: if (load == 1'b1) nextstate = 3'd0; //DONE --> IDLE
                    endcase
                  end

                  //Output decoder
                  always_comb begin
                    init = 1'b0;
                    advance = 1'b0;
                    final_round = 1'b0;
                    done = 1'b0;
                    case (state)
                      3'd1: init = 1'b1;
                      3'd3: begin advance = 1'b1;
                            if (cnt == 4'd10) final_round = 1'b1;
                          end
                      3'd4: done = 1'b1;
                      default: ;
                    endcase
                  end

                  //Round Counter 
                  always_comb begin
                    cnt_next = cnt;
                    if (state == 3'd1)
                      cnt_next = 4'd1;
                    else if (state == 3'd3 && nextstate == 3'd2) begin
                      cnt_next = cnt + 4'd1;
                    end
                  end
endmodule