`timescale 1ns / 1ps
`define __debug__
module fulladder32(
                    input   [31:0] a_i,
                    input   [31:0] b_i,
                    input         carry_i,
                    output  [31:0] sum_o,
                    output        carry_o 
                    );
localparam width = 32;
logic [32:0]carry;
assign  carry[0] = carry_i; 
assign  carry_o = carry[32]; 
genvar i;

generate
        for (i = 0; i < width; i = i + 1) begin: newgen
                    fulladder new_n( 
                    .a_i        (a_i[i]),
                    .b_i        (b_i[i]),
                    .carry_i    (carry[i]),
                    .sum_o      (sum_o[i]),
                    .carry_o    (carry[i+1])
                    );
        end
endgenerate    

endmodule


