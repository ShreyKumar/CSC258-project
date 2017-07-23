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
