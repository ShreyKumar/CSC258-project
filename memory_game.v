

module memory_game(SW, KEY, CLOCK_50, LEDR, HEX0);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0;

    wire resetn;
    wire go;

    wire [3:0] state_display;
    assign go = SW[1];
    assign resetn = SW[0];

    game_core u0(
        .clk(CLOCK_50),
        .resetn(resetn),
        .go(go),
        .data_in(SW[7:0]),
        .data_result(state_display)
    );

    assign LEDR[9:0] = {2'b00, data_result};

    hex_decoder H0(
        .hex_digit(state_display[3:0]),
        .segments(HEX0)
        );

endmodule

module game_core(
    input clk,
    input resetn,
    input go,
    input [7:0] data_in,
    output [7:0] data_result
    );

    // wires

    controller C0(
        .clk(clk),
        .resetn(resetn),

        .done_playback(),
        .done_response(),

        .load_level(),
        .start_playback(),
        .start_response(),
        .state_out()
    );

    datapath D0(
        .clk(clk),
        .resetn(resetn),

        .load_level(),
        .start_playback(),
        .start_response(),
        .state_in()

        .done_playback(),
        .done_response(),
    );

 endmodule


module controller(
    input clk,
    input resetn,
    input done_playback, done_response,

    output reg start_playback,
    output start_response,
    output load_level
    );

    reg [3:0] current_state, next_state;

    localparam  START         = 4'd0,
                LOAD          = 4'd1,
                CHALLENGE     = 4'd2,
                RESPONSE      = 4'd3;

    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
                START: next_state = go ? LOAD : START;
                LOAD: next_state = CHALLENGE;
                CHALLENGE: next_state = done_playback ? RESPONSE : CHALLENGE;
                RESPONSE: next_state = done_response ? START : RESPONSE;
            default:     next_state = START;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
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
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= START;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(
    input clk,
    input resetn,
    input load_level,
    input start_playback,
    input start_response,
    input state_in,

    output done_playback,
    output done_response
    );

    wire [31:0] period;
    assign period = 25000000; // should be 25000000

    shifter PLAYBACK (
        .clock(clk),
        .enable(),
        .load(),
        .reset(resetn),
        .data(),
        .out());

    shifter CHECK (
        .clock(clk),
        .enable(),
        .load(),
        .reset(resetn),
        .data(),
        .out());

    ratedivider A0 (
        .clock(clk),
        .period(period),
        .reset_n(resetn),
        .q());

    display_encoder A1 (
    );

    input_encoder A2 (
    );


)
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
    output out;
    reg [15:0] state;

    // async load and reset
    always @(posedge clock, posedge load, posedge reset)
    begin
        if (load)
            state = data;
        else if (reset)
            state = 0;
        else if (enable == 1'b1)
            state = state << 1;
    end

    assign out = state[15];

endmodule


module ratedivider (clock, period, reset_n, q);

    input clock;
    input reset_n;
    input [31:0] period;
    output reg [31:0] q;

    always @(posedge clock, posedge reset_n)
    begin
        if (reset_n == 1'b0)
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
