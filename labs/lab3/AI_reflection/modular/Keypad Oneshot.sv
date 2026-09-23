// -----------------------------------------------------------------------------
// keypad_oneshot.sv
//
// One-shot key registration + debounce for a 4x4 matrix keypad system.
// Target: Lattice iCE40 UP5K (synthesizable, single clock domain).
//
// Behavior:
//   * A press must be stable (key_pressed high, same key_code) for
//     DEBOUNCE_MS before it is accepted.
//   * On acceptance, key_out is updated and new_key pulses high for exactly
//     one clock cycle.
//   * While any key remains pressed, further keys are ignored.
//   * key_pressed must be stably low for DEBOUNCE_MS before a new press
//     can be recognized.
//
// Interface assumptions (from the scanner):
//   * key_pressed is a level that stays high while a key is held
//     (i.e., the scanner stops/freezes on a detected key).
//   * key_code is valid whenever key_pressed is high.
//
// Outputs are driven directly from flip-flops, so they are glitch-free.
// -----------------------------------------------------------------------------
module keypad_oneshot #(
    parameter int unsigned CLK_HZ      = 48_000_000, // system clock frequency
    parameter int unsigned DEBOUNCE_MS = 20          // required stable time
) (
    input  logic       clk,
    input  logic       rst_n,        // synchronous, active-low reset
    input  logic       key_pressed,  // from scanner: some key is down
    input  logic [3:0] key_code,     // from scanner: hex code of that key
    output logic       new_key,      // 1-cycle pulse when a key is accepted
    output logic [3:0] key_out       // most recently accepted key code
);

    // -------------------------------------------------------------------------
    // Debounce counter sizing
    // -------------------------------------------------------------------------
    localparam int unsigned DB_CYCLES_RAW = (CLK_HZ / 1000) * DEBOUNCE_MS;
    localparam int unsigned DB_CYCLES     = (DB_CYCLES_RAW < 1) ? 1 : DB_CYCLES_RAW;
    localparam int unsigned CNT_W         = (DB_CYCLES > 1) ? $clog2(DB_CYCLES) : 1;

    // -------------------------------------------------------------------------
    // Input synchronizers (2-FF). Harmless extra latency if the scanner is
    // already registered on clk; required if key_pressed comes from pins.
    // -------------------------------------------------------------------------
    logic       pressed_s1, pressed_s;
    logic [3:0] code_s1,    code_s;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            pressed_s1 <= 1'b0;
            pressed_s  <= 1'b0;
            code_s1    <= 4'h0;
            code_s     <= 4'h0;
        end else begin
            pressed_s1 <= key_pressed;
            pressed_s  <= pressed_s1;
            code_s1    <= key_code;
            code_s     <= code_s1;
        end
    end

    // -------------------------------------------------------------------------
    // FSM
    // -------------------------------------------------------------------------
    typedef enum logic [2:0] {
        S_IDLE,        // waiting for a press
        S_PRESS_DB,    // press seen, confirming it is stable
        S_REGISTER,    // accept key (exactly one cycle)
        S_HELD,        // key held; ignore all other keys
        S_RELEASE_DB   // release seen, confirming it is stable
    } state_t;

    state_t           state, next_state;
    logic [CNT_W-1:0] cnt;
    logic             cnt_done;
    logic [3:0]       cand_code;   // candidate code being debounced

    assign cnt_done = (cnt == CNT_W'(DB_CYCLES - 1));

    // Next-state logic
    always_comb begin
        next_state = state;
        unique case (state)
            S_IDLE:
                if (pressed_s) next_state = S_PRESS_DB;

            S_PRESS_DB:
                if (!pressed_s || (code_s != cand_code)) next_state = S_IDLE;
                else if (cnt_done)                       next_state = S_REGISTER;

            S_REGISTER:
                next_state = S_HELD;

            S_HELD:
                if (!pressed_s) next_state = S_RELEASE_DB;

            S_RELEASE_DB:
                if (pressed_s)     next_state = S_HELD;   // release bounce
                else if (cnt_done) next_state = S_IDLE;

            default:
                next_state = S_IDLE;
        endcase
    end

    // State register
    always_ff @(posedge clk) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    // Debounce counter: clears on any state change, counts while in a
    // debounce state, saturates at DB_CYCLES-1.
    always_ff @(posedge clk) begin
        if (!rst_n || (state != next_state)) begin
            cnt <= '0;
        end else if ((state == S_PRESS_DB || state == S_RELEASE_DB) && !cnt_done) begin
            cnt <= cnt + 1'b1;
        end
    end

    // Candidate capture: latch the code at the start of a press
    always_ff @(posedge clk) begin
        if (!rst_n)                              cand_code <= 4'h0;
        else if (state == S_IDLE && pressed_s)   cand_code <= code_s;
    end

    // -------------------------------------------------------------------------
    // Registered (glitch-free) outputs, decoded from next_state so the
    // pulse lines up with the cycle the FSM is in S_REGISTER.
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            new_key <= 1'b0;
            key_out <= 4'h0;
        end else begin
            new_key <= (next_state == S_REGISTER);
            if (next_state == S_REGISTER) key_out <= cand_code;
        end
    end

endmodule
