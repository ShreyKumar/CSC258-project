module memory_game_3(SW, KEY, CLOCK_50, LEDR, HEX0);
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
    output reg [3:0] note_outputs,
    output [3:0] state_display
    );

    wire w_done_playback, w_done_response, w_made_mistake, w_load_level, w_start_playback,
    w_input_ready, w_enable_check, w_enable_advance, w_start_delay, w_done_delay;

    // each 4-bit segment represents a note
    reg [15:0] current_level = 16'b0001_0010_0100_1000;

    // the number of notes comprising the current level
    reg [3:0] current_level_length = 4;

    wire [3:0] playback_out;
    wire [3:0] response_out;

    // manages game state
    controller C0(
        .clk(clk),
        .reset(reset),

        .current_state(state_display),

    	.enable_check(w_enable_check),
        .done_playback(w_done_playback),
        .done_response(w_done_response),
        .made_mistake(w_made_mistake),
    	.input_ready(w_input_ready),
        .load_level(w_load_level),
        .start_playback(w_start_playback),
    	.enable_advance(w_enable_advance),
        .start_delay(w_start_delay),
        .done_delay(w_done_delay)
    );

    playback P0(
        .clk(clk),
        .reset(reset),

        .note_outputs(playback_out),
        .level_data(current_level),
        .level_length(current_level_length),

        .load_level(w_load_level),
        .start_playback(w_start_playback),
        .done_playback(w_done_playback)
    );

    response R0(
        .clk(clk),
        .reset(reset),

        .note_inputs(note_inputs),
        .level_data(current_level),
        .level_length(current_level_length),

        .load_level(w_load_level),
    	.input_ready(w_input_ready),
        .enable_check(w_enable_check),
        .done_response(w_done_response),
        .made_mistake(w_made_mistake),
    	.enable_advance(w_enable_advance)
    );

    delay D0(
        .clk(clk),
        .reset(reset),

        .start_delay(w_start_delay),
        .done_delay(w_done_delay)
    )



    // output key state to display, unless in challenge state
    always@(*)
    begin
        case (state_display)
		4'd2: note_outputs = playback_out;
		default: note_outputs = note_inputs;
	endcase
    end

endmodule



module controller (
    input clk,
    input reset,

    output reg [3:0] current_state,

    input done_playback,
    input done_response,
    input made_mistake,
    input input_ready,
    input start_delay,
    output done_delay,
    output reg start_playback,
    output reg load_level,
    output reg enable_check,
    output reg enable_advance

    );

    reg [3:0] next_state;

    localparam  START         = 4'd0,
                LOAD          = 4'd1,
                CHALLENGE     = 4'd2,
                WAIT_RESPONSE = 4'd3,
		        RCV_RESPONSE  = 4'd4,
		        ADV_RESPONSE  = 4'd5,
                WON           = 4'd6,
                LOST          = 4'd7;

    // state transition logic
    always@(*)
    begin: state_table
            case (current_state)
                START: next_state = LOAD;
                LOAD: next_state = CHALLENGE;
                CHALLENGE: next_state = done_playback ? WAIT_RESPONSE : CHALLENGE;
		WAIT_RESPONSE:
		   begin
			if (done_response)
                            next_state = WON;
			else if (input_ready)
			    next_state = RCV_RESPONSE;
			else
			    next_state = WAIT_RESPONSE;
		   end
			//next_state = input_ready ? RCV_RESPONSE : WAIT_RESPONSE;
                RCV_RESPONSE:
                    begin
			if (made_mistake)
                            next_state = LOST;
                        else
                            next_state = ADV_RESPONSE;
                    end
		ADV_RESPONSE: next_state = WAIT_RESPONSE;
                LOST: next_state = LOST;
                WON: done_delay ? next_state = LOAD ? next_state = WON;
            default: next_state = START;
        endcase
    end

    // control signal output logic
    always @(*)
    begin: enable_signals

        // set defaults
        start_playback = 1'b0;
        load_level = 1'b0;
	    enable_check = 1'b0;
	    enable_advance = 1'b0;
        start_delay = 1'b0;

        case (current_state)
            START: begin
                end
            LOAD: begin
                load_level = 1'b1;
                end
            CHALLENGE: begin
                start_playback = 1'b1;
                end
            WAIT_RESPONSE: begin
                end
	    RCV_RESPONSE: begin
		enable_check = 1'b1;
		end
	    ADV_RESPONSE: begin
		enable_advance = 1'b1;
		end
            LOST: begin
                end
            WON: begin
                start_delay = 1'b1;
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


module delay(
    input clk,
    input reset,

    input start_delay,
    output reg done_delay
    );

    reg [31:0] ratedivider_out;

    assign done_delay = (start_delay && (ratedivider_out == 0)) ? 1 : 0;

    ratedivider A0 (
        .clock(clk),
        .period(3),
        .reset(reset || start_delay),
        .q(ratedivider_out));

endmodule




module response (
    input clk,
    input reset,

    input [15:0] level_data,
    input [3:0] level_length,
    input [3:0] note_inputs,
    input load_level,
    input enable_check,
    input enable_advance,

    output reg done_response,
    output reg made_mistake,
    output reg input_ready

    );

    wire [3:0] correct_note;
    wire [3:0] response_counter_state;

    // if we want multiple notes, maybe set this to negedge
    // but also retain previous inputs to check against
    always@(posedge note_inputs[0], posedge note_inputs[1], posedge note_inputs[2], posedge note_inputs[3])
    begin
    	input_ready <= 1'b1;
    end

    always@(enable_check)
    begin
	input_ready <= 1'b0;
        if(correct_note == note_inputs)
            made_mistake <= 1'b0;
        else
            made_mistake <= 1'b1;
    end

    always@(posedge clk)
    begin
            if (response_counter_state == 4'b0000)
                done_response <= 1'b1;
            else
                done_response <= 1'b0;
    end


    shifter RESPONSE_SHIFTER (
        .clock(clk),
        .enable(enable_advance),
        .load(load_level),
        .reset(reset),
        .data(level_data),
        .out(correct_note));

    counter RESPONSE_COUNTER (
        .clock(clk),
        .reset(reset),
	.load(load_level),
        .max(level_length),
        .enable(enable_advance),
        .q(response_counter_state));

endmodule





module playback (
    input clk,
    input reset,

    input [15:0] level_data,
    input [3:0] level_length,
    input load_level,
    input start_playback,

    output wire [3:0] note_outputs,
    output reg done_playback
    );

    // duration (in clock cycles) of notes during challenge
    wire [31:0] period =  2; // 25000000;

    wire enable_playback;
    wire [31:0] ratedivider_out;
    wire [3:0] playback_count;

    assign enable_playback = ((ratedivider_out == 0) && start_playback) ? 1 : 0;

    always@(posedge clk)
    begin
        if (playback_count == 4'b0000)
            done_playback <= 1'b1;
        else
            done_playback <= 1'b0;
    end

    ratedivider A0 (
        .clock(clk),
        .period(period),
        .reset(reset),
        .q(ratedivider_out));

    shifter PLAYBACK_SHIFTER (
        .clock(clk),
        .enable(enable_playback),
        .load(load_level),
        .reset(reset),
        .data(level_data),
        .out(note_outputs));

    counter PLAYBACK_COUNTER (
        .clock(clk),
        .load(load_level),
        .reset(reset),
        .max(level_length),
        .enable(enable_playback),
        .q(playback_count));

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
            q <= 4'b1111;
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
