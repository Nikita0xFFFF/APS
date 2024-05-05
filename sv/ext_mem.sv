`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2023 13:22:49
// Design Name: 
// Module Name: Nikita Sokolov
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ext_mem(
  input   logic         clk_i,
  input   logic         mem_req_i,
  input   logic         write_enable_i,
  input   logic [ 3:0]  byte_enable_i,
  input   logic [31:0]  addr_i,
  input   logic [31:0]  write_data_i,
  output  logic [31:0]  read_data_o,
  output  logic         ready_o
);

  logic [31:0] mem [4095:0];

  assign ready_o    = 1'b1;

  always_ff @(posedge clk_i)
  begin
    if(!mem_req_i)begin
      read_data_o <= 32'hfa11_1eaf;
    end
    else if (write_enable_i) begin
      read_data_o <= 32'hfa11_1eaf;
      case (byte_enable_i)
        4'b0001 : mem[addr_i[31:2]][ 7:0 ] <= write_data_i[ 7:0 ];
        4'b0010 : mem[addr_i[31:2]][15:8 ] <= write_data_i[15:8 ];
        4'b0011 : mem[addr_i[31:2]][15:0 ] <= write_data_i[15:0 ];
        4'b0100 : mem[addr_i[31:2]][23:16] <= write_data_i[23:16];
        4'b0101 : begin
          mem[addr_i[31:2]][23:16] <= write_data_i[23:16];
          mem[addr_i[31:2]][ 7:0 ] <= write_data_i[ 7:0 ]; end /// not 
        4'b0110 : mem[addr_i[31:2]][23:8 ] <= write_data_i[23:8 ]; /// not 
        4'b0111 : mem[addr_i[31:2]][23:0 ] <= write_data_i[23:0 ]; /// not 
        4'b1000 : mem[addr_i[31:2]][31:24] <= write_data_i[31:24];
        4'b1001 : begin
          mem[addr_i[31:2]][31:24] <= write_data_i[31:24];
          mem[addr_i[31:2]][ 7:0 ] <= write_data_i[ 7:0 ]; end /// not 
        4'b1010 : begin
          mem[addr_i[31:2]][31:24] <= write_data_i[31:24];
          mem[addr_i[31:2]][15:8 ] <= write_data_i[15:8 ]; end /// not 
        4'b1011 : begin
          mem[addr_i[31:2]][31:24] <= write_data_i[31:24];
          mem[addr_i[31:2]][15:0 ] <= write_data_i[15:0]; end /// not 
        4'b1100 : mem[addr_i[31:2]][31:16] <= write_data_i[31:16];
        4'b1101 : begin
          mem[addr_i[31:2]][31:16] <= write_data_i[31:16];
          mem[addr_i[31:2]][ 7:0 ] <= write_data_i[ 7:0 ]; end /// not 
        4'b1110 : mem[addr_i[31:2]][31:8] <= write_data_i[31:8]; /// not 
        4'b1111 : mem[addr_i[31:2]]       <= write_data_i;
        default : mem[addr_i[31:2]]       <= mem[addr_i[31:2]];
      endcase
    end
    else if(addr_i>16383) begin
      read_data_o <= 32'hdead_beef;
    end
    else
      begin
        read_data_o <= mem[addr_i[31:2]];
      end
  end
endmodule
