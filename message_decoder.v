module message_decoder(state_number, level_number, segments);
  input [3:0] state_number;
  input [3:0] level_number;
  output reg [41:0] segments;

  wire [6:0] E_msg;
  wire [6:0] S_msg;
  wire [6:0] O_msg;
  wire [6:0] G_msg;
  wire [6:0] C_msg;
  wire [6:0] lvl;
  wire [6:0] blank = 7'b111_1111;
  wire [6:0] A_msg;

  reg [6:0] H_msg = 7'b000_1001;
  reg [6:0] t_msg = 7'b000_0111;
  reg [6:0] n_msg = 7'b100_1000;
  reg [6:0] r_msg = 7'b100_1110;
  reg [6:0] U_msg = 7'b100_0001;
  reg [6:0] L_msg = 7'b100_0111;

  hex_decoder H0 (
      .hex_digit(4'hE),
      .segments(E_msg)
    );

  hex_decoder H1 (
      .hex_digit(4'h0),
      .segments(O_msg)
    );

  hex_decoder H2 (
      .hex_digit(4'h5),
      .segments(S_msg)
    );

  hex_decoder H3 (
      .hex_digit(4'h9),
      .segments(G_msg)
    );

  hex_decoder H4 (
      .hex_digit(level_number),
      .segments(lvl)
    );
  hex_decoder H5 (
      .hex_digit(4'hC),
      .segments(C_msg)
    );
  hex_decoder H6 (
      .hex_digit(4'hA),
      .segments(A_msg)
    );

  always @ (*)
    case (state_number)
      4'h0: segments = {H_msg, E_msg, L_msg, L_msg, O_msg, blank}; //Start stage
      4'h2: segments = {S_msg, t_msg, A_msg, G_msg, E_msg, lvl};
      4'h3: segments = {U_msg, r_msg, t_msg, U_msg, r_msg, n_msg};
      4'h6: segments = {S_msg, C_msg, O_msg, r_msg, E_msg, blank};
      4'h7: segments = {L_msg, O_msg, S_msg, E_msg, blank, blank};
      default: segments = {blank, blank, blank, blank, blank, blank};
    endcase

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
