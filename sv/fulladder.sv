`timescale 1ns / 1ps

module fulladder(
                input   a_i,
                input   b_i,
                input   carry_i,
                output  sum_o,
                output  carry_o
    );
assign sum_o = a_i ^ b_i ^ carry_i;
assign carry_o = (a_i & b_i) | ( carry_i & a_i) | (carry_i & b_i);  
endmodule


