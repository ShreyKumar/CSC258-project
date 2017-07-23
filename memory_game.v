module memory_game(SW, KEY, CLOCK_50, LEDR, HEX0);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0;

    wire [3:0] state_display;

    // handles game state and logic
    game_core G0(
        .clk(CLOCK_50),
        .reset(SW[0]),
        .note_inputs(KEY[3:0]),
        .note_outputs(LEDR[3:0]),
        .state_display(state_display)
    );

    // displays the current state
    hex_decoder H0(
        .hex_digit(state_display[3:0]),
        .segments(HEX0)
    );

endmodule

module game_core(
    input clk,
    input reset,
    input [3:0] note_inputs,
    output [3:0] note_outputs,
    output [3:0] state_display
    );

    wire w1, w2, w3, w4, w5, w6;

    // each 4-bit segment represents a note
    reg [15:0] current_level = 16'b0001_0001_0001_0001;

    // the number of notes comprising the current level
    reg [3:0] current_level_length = 4;

    // manages game state
    controller C0(
        .clk(clk),
        .reset(reset),

        .current_state(state_display)

        .done_playback(w1),
        .done_response(w2),
        .made_mistake(w3),
        .load_level(w4),
        .start_playback(w5),
        .start_response(w6)
    );

    playback P0(
        .clk(clk),
        .reset(reset),

        .load_level(w4),
        .level_data(current_level),
        .level_length(current_level_length),
        .start_playback(w5),

        .note_outputs(note_outputs),
        .done_playback(w1)
    );

    //response R0(
    //    .clk(clk),
    //    .reset(reset),

    //    .note_inputs(note_inputs),
    //    .load_level(w4),
    //    .level_data(current_level),
    //    .level_length(current_level_length),
    //    .start_response(w5),

    //    .note_outputs(note_outputs),
    //    .done_response(w1),
    //    .made_mistake(w3)
    //);

endmodule



module controller (
    input clk,
    input reset,

    output reg [3:0] current_state,

    input done_playback,
    input done_response,
    input made_mistake,
    output reg start_playback,
    output start_response,
    output load_level,

    );

    reg [3:0] next_state;

    localparam  START         = 4'd0,
                LOAD          = 4'd1,
                CHALLENGE     = 4'd2,
                RESPONSE      = 4'd3,
                WON           = 4'd4,
                LOST          = 4'd5;

    // state transition logic
    always@(*)
    begin: state_table
            case (current_state)
                START: next_state = LOAD;
                LOAD: next_state = CHALLENGE;
                CHALLENGE: next_state = done_playback ? RESPONSE : CHALLENGE;
                RESPONSE:
                    begin
                        if (made_mistake)
                            next_state = LOST;
                        else if (done_response)
                            next_state = WIN;
                        else
                            next_state = RESPONSE;
                    end
                LOST: next_state = LOST;
                WON: next_state = WON;
            default: next_state = START;
        endcase
    end

    // control signal output logic
    always @(*)
    begin: enable_signals

        // set defaults
        start_playback = 1'b0;
        start_response = 1'b0;
        load_level = 1'b0;

        case (current_state)
            START: begin
                end
            LOAD: begin
                load_level = 1'b1;
                end
            CHALLENGE: begin
                start_playback = 1'b1;
                end
            RESPONSE: begin
                start_response = 1'b1;
                end
            LOST: begin
                end
            WIN: begin
                end
            end
        endcase
    end

    // update state
    always@(posedge clk)
    begin: state_FFs
        if(reset)
            current_state <= START;
        else
            current_state <= next_state;
    end

endmodule



module response (
    input clk,
    input reset,

    input [15:0] level_data,
    input [3:0] level_length,
    input [3:0] note_inputs,
    input load_level,
    input start_response,

    output [3:0] note_outputs,
    output done_response,
    output made_mistake

    );


    reg [3:0] correct_note = 4'b0000; // default
    reg [3:0] response_counter_state;
    reg enable_response_shifter;
    reg enable_response_counter;

    assign enable_response_counter = 1'b0;
    assign enable_response_shifter = 1'b0;

    assign key_pressed = (| note_inputs);
    // assign note_outputs = note_inputs;


    always@(posedge key_pressed)
    begin
        assign note_outputs = note_inputs;
        assign enable_response_shifter = 1'b1;
        assign enable_response_counter = 1'b1;
    end


    shifter RESPONSE_SHIFTER (
        .clock(clk),
        .enable(enable_response_shifter),
        .load(load_level),
        .reset(reset),
        .data(current_level),
        .out(correct_note));


    always@(posedge key_pressed)
    begin
        if(correct_note == note_inputs) // should be prev-inputs? ie before key release?
            made_mistake <= 1'b0;
        else
            made_mistake <= 1'b1;
    end


    counter RESPONSE_COUNTER (
        .clock(clk),
        .reset(load_level),
        .max(current_level_length),
        .enable(enable_response_counter),
        .q(response_counter_state));

    always@(*)
    begin
            if (response_counter_state == 4'b0000)
                done_response <= 1'b1;
            else
                done_response <= 1'b0;
    end


)
endmodule



module playback (
    input clk,
    input reset,

    input [15:0] level_data,
    input [3:0] level_length,
    input load_level,
    input start_playback,

    output [3:0] note_outputs,
    output reg done_playback

    );

    // duration (in clock cycles) of notes during challenge
    wire [31:0] period =  2; // 25000000;
    wire shifter_enable;

    wire [31:0] ratedivider_out;
    wire [3:0] playback_note;
    wire [3:0] playback_counter_state;

    assign shifter_enable = ((ratedivider_out == 0) && start_playback) ? 1 : 0;

    ratedivider A0 (
        .clock(clk),
        .period(period),
        .reset(reset),
        .q(ratedivider_out));

    shifter PLAYBACK_SHIFTER (
        .clock(clk),
        .enable(shifter_enable),
        .load(load_level),
        .reset(reset),
        .data(level_data),
        .out(playback_note));

    assign note_outputs = playback_note;

    counter PLAYBACK_COUNTER (
        .clock(clk),
        .load(load_level),
        .reset(reset),
        .max(level_length),
        .enable(shifter_enable),
        .q(playback_counter_state)
        );

    always@(*)
    begin
        if (playback_counter_state == 4'b0000)
            done_playback <= 1'b1;
        else
            done_playback <= 1'b0;
    end

endmodule



module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;

    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;
            default: segments = 7'h7f;
        endcase
endmodule



module shifter(clock, enable, load, reset, data, out);

    input clock, enable, load, reset;
    input [15:0] data;
    output [3:0] out;
    reg [15:0] state;

    // async load and reset
    always @(posedge clock, posedge load, posedge reset)
    begin
        if (load)
            state = data;
        else if (reset)
            state = 0;
        else if (enable == 1'b1)
            state = state << 4;
    end

    assign out = state[15:12];

endmodule



module ratedivider (clock, period, reset, q);

    input clock;
    input reset;
    input [31:0] period;
    output reg [31:0] q;

    always @(posedge clock, posedge reset)
    begin
        if (reset)
            q <= period - 1;
        else
            begin
                if (q == 0)
                    q <= period - 1;
                else
                    q <= q - 1'b1;
        end
    end

endmodule



module counter (clock, reset, load, max, enable, q);

    input clock;
    input reset;
    input load;
    input [3:0] max;
    input enable;
    output reg [3:0] q;

    always @(posedge clock, posedge load, posedge reset)
    begin
        if (reset)
            q <= 0;
	else if (load)
	    q <= max;
        else if (enable == 1'b1)
            begin
                if (q == 0)
                    q <= max;
                else
                    q <= q - 1'b1;
            end
    end

endmodule
