module CYBERcobra(
  input  logic         clk_i,
  input  logic         rst_i,
  input  logic [15:0]  sw_i,
  output  logic [31:0]  out_o
);
  logic [31:0] sum ; logic [31:0] addr_i; //Program Counter
  logic [31:0] instruction;
  //logic ALU
  logic [4:0]  ALU_op;
  logic [31:0] alu_res;
  logic  alu_flag;
  //logic reg_file
  logic [4:0]  RA1;
  logic [4:0]  RA2;
  logic [4:0]  WA;
  logic [31:0] RD1;
  logic [31:0] RD2;
  logic WE;
  logic [31:0] WD;
  ////////MUX
  logic [1:0]WS;
  logic mux_add;
  logic [31:0] b_i;

  /////INITIALIZATION
  assign ALU_op = instruction[27:23];
  assign WE = !(instruction[30]|instruction[31]);
  assign RA1 = instruction[22:18];
  assign RA2 = instruction[17:13];
  assign WA =  instruction[4:0];
  assign WS =  instruction[29:28];

  assign mux_add = ( alu_flag & instruction[30]) | instruction[31] ;
  assign b_i = ( mux_add==1 )? {{22{instruction[12]}},instruction[12:5],2'b0} : 32'd4;
  assign out_o = RD1;


  always_comb begin
    case(WS)
      0: WD={{9{instruction[27]}},instruction[27:5]};
      1: WD= alu_res;
      2: WD={{16{instruction[sw_i[15]]}},sw_i};
      default: WD= 32'd0;
    endcase

  end



  PC PC_instance(
    .clk(clk_i),
    .rst(rst_i),
    .ADD(sum),
    .addr(addr_i)
  );
  fulladder32 fulladder32_instance(
    .a_i(addr_i),
    .b_i(b_i),
    .carry_i(1'b0),
    .sum_o(sum)
  );
  instr_mem instr_mem_instance(
    .addr_i(addr_i),
    .read_data_o(instruction)
  );
  rf_riscv rf_riscv_instance(
    .clk_i(clk_i),
    .write_enable_i(WE),
    .read_addr1_i(RA1),
    .read_addr2_i(RA2),
    .write_addr_i(WA),
    .write_data_i(WD),
    .read_data1_o(RD1),
    .read_data2_o(RD2)
  );
  alu_riscv alu_riscv_instance(
    .a_i(RD1),
    .b_i(RD2),
    .alu_op_i(ALU_op),
    .flag_o(alu_flag),
    .result_o(alu_res)
  );
endmodule 
