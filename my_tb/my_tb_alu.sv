`timescale 1ns / 1ps


module my_tb_alu();

import alu_opcodes_pkg::*;

logic   [31:0]    A;
logic   [31:0]    B;
logic   [4:0]     ALUop;
logic             Flag;
logic   [31:0]    Result;

alu_riscv ALU(A,B,ALUop,Flag,Result);

reg [8*9:1] op_type;
assign flag_o = Flag;
initial begin

A=765;
B=456;

test(ALU_ADD);
test(ALU_SUB);
test(ALU_SLL);
test(ALU_SRL);
test(ALU_AND);
$display("----------------------------------------------------------------------------------------------------------------------------------------------------");

A=40;
B=80;
test(ALU_ADD);
test(ALU_SUB);
test(ALU_SLTS);
test(ALU_LTS);
test(ALU_SLTU);
test(ALU_LTU);
$stop;
end

task test;
input [4:0] alu_op;

begin
assign ALUop = alu_op;
#5
$display("Result  operation %s: a_i: %d or %b     b_i: %d or %b   Result:%d or %b  Flag: %h ", 
            op_type, A, A, B, B, $signed(Result), Result, Flag);
end

endtask
always @(*) begin
 case(ALUop)
   ALU_ADD  : op_type = "ALU_ADD  ";
   ALU_SUB  : op_type = "ALU_SUB  ";
   ALU_XOR  : op_type = "ALU_XOR  ";
   ALU_OR   : op_type = "ALU_OR   ";
   ALU_AND  : op_type = "ALU_AND  ";
   ALU_SRA  : op_type = "ALU_SRA  ";
   ALU_SRL  : op_type = "ALU_SRL  ";
   ALU_SLL  : op_type = "ALU_SLL  ";
   ALU_LTS  : op_type = "ALU_LTS  ";
   ALU_LTU  : op_type = "ALU_LTU  ";
   ALU_GES  : op_type = "ALU_GES  ";
   ALU_GEU  : op_type = "ALU_GEU  ";
   ALU_EQ   : op_type = "ALU_EQ   ";
   ALU_NE   : op_type = "ALU_NE   ";
   ALU_SLTS : op_type = "ALU_SLTS ";
   ALU_SLTU : op_type = "ALU_SLTU ";
   default  : op_type = "NOP      ";
 endcase
end

endmodule
