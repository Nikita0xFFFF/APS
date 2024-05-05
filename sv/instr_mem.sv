module instr_mem(
  input   logic   [31:0]  addr_i,
  output  logic   [31:0]  read_data_o
);
  logic [31:0] RAM [1023:0];
  initial $readmemh("program.txt", RAM);
  always_comb
  begin
    if(addr_i > 4095)
      begin
        read_data_o <= 'd0;
      end
    else
      begin
        read_data_o <= RAM[addr_i[31:2]];
      end
  end
endmodule
