// keypad_scanner.sv
// 4x4 matrix keypad scanner with debounce-by-design.
//
// Operation (all state advances only on `tick`, e.g. 200 Hz = 5 ms):
//   S_SCAN : drive one column low, wait a full tick for lines to settle, then
//            sample the rows. If any row is low, register exactly one key
//            (lowest-numbered row wins) and go to S_HELD. Otherwise advance
//            to the next column. Full-keypad scan period = 4 ticks = 20 ms.
//   S_HELD : drive ALL columns low, so any key anywhere pulls some row low.
//            That makes the FSM ignore every additional press while anything
//            is held, and it only returns to S_SCAN after the rows read
//            all-high for RELEASE_TICKS consecutive samples (20 ms default).
//
// Why this debounces:
//   * Press bounce: the first low sample registers the key; any bounce after
//     that happens while in S_HELD, where only a sustained release matters.
//   * Release bounce: a momentary "open" during bounce resets rel_cnt, so a
//     release must be stable for RELEASE_TICKS * tick period before a new key
//     can be accepted. Sampling at 5 ms also low-pass-filters sub-ms chatter.
module keypad_scanner #(
  parameter int unsigned RELEASE_TICKS = 4
) (
  input  logic       clk,
  input  logic       rst,        // synchronous, active-high
  input  logic       tick,       // scan-rate enable
  input  logic [3:0] row_n,      // synchronized rows, active-low (pulled up)
  output logic [3:0] col_n,      // column drive, active-low (0 = driven)
  output logic       key_valid,  // one-clk pulse when a new key registers
  output logic [3:0] key_code    // hex value of the registered key
);
  typedef enum logic [0:0] {S_SCAN, S_HELD} state_t;

  localparam int unsigned CW = $clog2(RELEASE_TICKS + 1);

  state_t        state;
  logic [1:0]    col_idx;
  logic [CW-1:0] rel_cnt;
  logic          any_low;

  assign any_low = ~&row_n;

  // Column drive is decoded from registered state. Transitions only occur on
  // a tick and rows are not sampled until the next tick, so any decode glitch
  // has long settled before it matters.
  always_comb begin
    if (state == S_HELD) col_n = 4'b0000;
    else                 col_n = ~(4'b0001 << col_idx);
  end

  // Lowest active row wins if several rows are low in the same column.
  function automatic logic [1:0] first_low(input logic [3:0] r);
    if      (!r[0]) return 2'd0;
    else if (!r[1]) return 2'd1;
    else if (!r[2]) return 2'd2;
    else            return 2'd3;
  endfunction

  // Physical layout -> hex value. Edit to match your keypad's legend.
  //   row0: 1 2 3 A
  //   row1: 4 5 6 B
  //   row2: 7 8 9 C
  //   row3: E 0 F D     (* -> E, # -> F)
  function automatic logic [3:0] keymap(input logic [1:0] r, input logic [1:0] c);
    unique case ({r, c})
      4'b00_00: return 4'h1;  4'b00_01: return 4'h2;
      4'b00_10: return 4'h3;  4'b00_11: return 4'hA;
      4'b01_00: return 4'h4;  4'b01_01: return 4'h5;
      4'b01_10: return 4'h6;  4'b01_11: return 4'hB;
      4'b10_00: return 4'h7;  4'b10_01: return 4'h8;
      4'b10_10: return 4'h9;  4'b10_11: return 4'hC;
      4'b11_00: return 4'hE;  4'b11_01: return 4'h0;
      4'b11_10: return 4'hF;  4'b11_11: return 4'hD;
    endcase
  endfunction

  always_ff @(posedge clk) begin
    if (rst) begin
      state     <= S_SCAN;
      col_idx   <= '0;
      rel_cnt   <= '0;
      key_valid <= 1'b0;
      key_code  <= '0;
    end else begin
      key_valid <= 1'b0;  // default: pulse is one clock wide

      if (tick) begin
        unique case (state)
          S_SCAN: begin
            if (any_low) begin
              key_code  <= keymap(first_low(row_n), col_idx);
              key_valid <= 1'b1;
              rel_cnt   <= '0;
              state     <= S_HELD;
            end else begin
              col_idx <= col_idx + 1'b1;
            end
          end

          S_HELD: begin
            if (any_low) begin
              rel_cnt <= '0;                     // still held (or bouncing)
            end else if (rel_cnt == CW'(RELEASE_TICKS - 1)) begin
              rel_cnt <= '0;
              state   <= S_SCAN;                 // stable release confirmed
            end else begin
              rel_cnt <= rel_cnt + 1'b1;
            end
          end
        endcase
      end
    end
  end
endmodule
