`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MIET
// Engineer: Nikita Sokolov
// 
// Create Date: 26.11.2023 13:22:49
// Design Name: 
// Module Name: tb_ext_mem
// Project Name: RISCV_practicum
// Target Devices: Nexys A7-100T
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

module my_tb_ext_mem();
  logic         clk;
  logic         mem_req;
  logic         write_enable;

  logic [ 3:0]  byte_enable;
  logic [31:0]  addr;
  logic [31:0]  write_data;
  logic [31:0]  read_data;
  logic         ready;

  ext_mem ext_mem(
    .clk_i(clk),
    .write_enable_i(write_enable),
    .mem_req_i(mem_req),
    .byte_enable_i(byte_enable),
    .addr_i(addr),
    .write_data_i(write_data),
    .read_data_o(read_data),
    .ready_o(ready)
  );

  initial begin
    clk = 0;
    mem_req = 0;
    write_enable = 0;
    byte_enable = 0;
    addr = 0;
    write_data = 0;
    #10
    // Test Case 1: Write and read back
    $display("Test Case 1: Write and read back");

    mem_req = 1;
    write_enable = 1;
    byte_enable = 4'b1111;
    addr = 2048;
    write_data = 32'h2829_2854;

    #100 mem_req = 1;
    write_enable = 0;
    #50
    if (read_data !== 32'h2829_2854) begin
      $display("ERROR: Read data does not match write data");
    end else begin
      $display("SUCCESS: Read data matches write data");
    end

    #100
    // Test Case 2: Write and read back byte by byte
    $display("Test Case2: Write and read back byte by byte");

    mem_req = 1;
    write_enable = 1;
    byte_enable = 4'b0011;
    addr = 2048;
    write_data = 32'h8765_4321;

    #100 mem_req = 1;
    write_enable = 0;
    #100
    if (read_data[7:0] !== 8'h21) begin
      $display("ERROR: Read data does not match write data");
    end else begin
      $display("SUCCESS: Read data matches write data");
    end

    if (read_data[15:8] !== 8'h43) begin
      $display("ERROR: Read data does not match write data");
    end else begin
      $display("SUCCESS: Read data matches write data");
    end
    $display("---------------------------SUCCESS-------------------------");
    if (read_data[23:16] !== 8'h65) begin
      $display("ERROR: Read data does not match write data (read_data[23:16] !== 8'h65)");
    end else begin
      $display("SUCCESS: Read data matches write data");
    end

    if (read_data[31:24] !== 8'h87) begin
      $display("ERROR: Read data does not match write data (read_data[31:24] !== 8'h87)");
    end else begin
      $display("SUCCESS: Read data matches write data");
    end
    $display("----------------------------------------------------------");
  end

  always #5 clk = ~clk;

endmodule
