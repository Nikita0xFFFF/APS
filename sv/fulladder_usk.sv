module fulladder_usk(
  input  logic [31:0] a_i,
  input  logic [31:0] b_i,
  input logic         carry_i,
  output logic [31:0] sum_o,
  output logic        carry_o
);

  genvar i;
  logic [7:0] carry_signals;

  generate
    for (i = 0; i < 8; i = i + 1) begin : newgen
      fulladder4 f (
        .a_i(a_i[4*i +: 4]),
        .b_i(b_i[4*i +: 4]),
        .carry_i(i == 0 ? carry_i : carry_signals[i-1]),
        .sum_o(sum_o[4*i +: 4]),
        .carry_o(carry_signals[i])
      );
    end
  endgenerate

  assign carry_o = carry_signals[7];

endmodule