
//import my_signals_pkg ::*;

module riscv_core(

  input  logic        clk_i,
  input  logic        rst_i,

  input  logic        stall_i,
  input  logic [31:0] instr_i,
  input  logic [31:0] mem_rd_i,

  input  logic        irq_req_i,
  output logic        irq_ret_o,

  output logic [31:0] instr_addr_o,
  output logic [31:0] mem_addr_o,
  output logic [ 2:0] mem_size_o,
  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [31:0] mem_wd_o
);

  // ================ Programm Counter ================
  logic [31:0] PC;

  logic         sel_jair_total; // select increment (jalr or (instr + inc_const_jb)); result = inc_total
  logic         sel_const_jb; // select increment (const or inc_jb); reuslt = inc_const_jb
  logic         sel_jal_branch; // select increment (jal or branch); result = inc_jb
  logic [31:0] inc_total;
  logic [31:0] inc_jalr;
  logic [31:0] inc_const_jb;
  logic [31:0] inc_const_jb_instr;
  logic [31:0] inc_jb;
  logic [31:0] inc_trap;
  logic [31:0] inc_mret;

  // ================ Sign 
  logic [31:0] imm_I;
  logic [31:0] imm_U;
  logic [31:0] imm_S;
  logic [31:0] imm_B;
  logic [31:0] imm_J;
  logic [31:0] imm_Z;
  //================== Registr file 
  logic         write_en;
  logic [4:0 ]  write_addr;
  logic [31:0]  write_data;
  logic [4:0]   read_addr1;
  logic [4:0]   read_addr2;
  logic [31:0]  read_data1;
  logic [31:0]  read_data2;

  //==========csr_contr======================
  logic        trap;

  logic [31:0] mcause;

  logic [31:0] read_data;
  logic [31:0] mie;
  logic [31:0] mepc;
  logic [31:0] mtvec;

  //=================inr_contr===============
  logic        exception;


  logic [31:0] irq_cause;
  logic        irq;
  
  //================decoder
  logic         illegal_instr;

  logic         gpr_we;
  logic [1:0]   wb_sel;
  logic [ 2:0 ] b_sel;
  logic [ 1:0 ] a_sel;
  logic         mem_req;
  logic         mem_we;
  logic         branch;
  logic         jal;
  logic         jalr;

  logic         mret;

  logic         csr_we;
  logic [2:0]   csr_op;

  // ================ ALU 
  logic [ 4:0 ] alu_op;
  logic         alu_flag;
  logic [31:0 ] alu_result;
  logic [31:0 ] alu_a;
  logic [31:0 ] alu_b;

  //PC
  assign sel_jair_total      = jalr;
  assign sel_jal_branch = branch;
  assign sel_const_jb   = jal || (alu_flag && branch);

  assign inc_jb             = (sel_jal_branch)? imm_B    : imm_J;
  assign inc_const_jb       = (sel_const_jb)  ? inc_jb   : 4;
  assign inc_total          = (sel_jair_total)     ? inc_jalr : inc_const_jb_instr;
  assign inc_trap = trap? mtvec:inc_total;
  assign inc_mret = mret? mepc:inc_trap;

  //sign
  assign imm_I = {{20{instr_i[31]}},instr_i[31:20]};
  assign imm_U = {instr_i[31:12],12'h000};
  assign imm_S = {{20{instr_i[31]}},instr_i[31:25],instr_i[11:7]};
  assign imm_B = {{20{instr_i[31]}},instr_i[7],instr_i[30:25],instr_i[11:8],1'b0};
  assign imm_J = {{11{instr_i[31]}},instr_i[19:12],instr_i[20],instr_i[30:21],1'b0};
  assign imm_Z = {{27{1'b0}},instr_i[19:15]};

  //registr_file
  assign read_addr1 = instr_i[19:15];
  assign read_addr2 = instr_i[24:20];
  assign write_addr = instr_i[11:7];
  assign write_en   = !(stall_i | trap) &&  gpr_we;

  // Other
  assign mem_addr_o   = alu_result;
  assign mem_wd_o     = read_data2;
  assign instr_addr_o = PC;

  assign mem_req_o = ~trap & mem_req;
  assign mem_we_o = ~trap & mem_we;

  assign trap = irq | illegal_instr;
  
  assign mcause = illegal_instr? 32'h0000_0002: irq_cause;
  
 
  
  always_comb begin
    case(a_sel)
      0: alu_a <= read_data1;
      1: alu_a <= PC;
      default: alu_a <= 0;

    endcase
    case(b_sel)
      0: alu_b <= read_data2;
      1: alu_b <= imm_I;
      2: alu_b <= imm_U;
      3: alu_b <= imm_S;
      default : alu_b <= 4;
    endcase

    case(wb_sel)
      0: write_data <= alu_result;
      1: write_data <= mem_rd_i;
      2: write_data <= read_data;
      default: write_data <= 0;
    endcase
  end

  decoder_riscv decoder_riscv_instance(
    .fetched_instr_i(instr_i),
    .a_sel_o(a_sel),
    .b_sel_o(b_sel),
    .alu_op_o(alu_op),
    .csr_op_o(csr_op),
    .csr_we_o(csr_we),
    .mem_req_o(mem_req),
    .mem_we_o(mem_we),
    .mem_size_o(mem_size_o),
    .gpr_we_o(gpr_we),
    .wb_sel_o(wb_sel),
    .illegal_instr_o(illegal_instr),
    .branch_o(branch),
    .jal_o(jal),
    .jalr_o(jalr),
    .mret_o(mret)
  );

  rf_riscv rf_riscv_instance(
    .clk_i(clk_i),
    .write_enable_i(write_en),
    .read_addr1_i(read_addr1),
    .read_addr2_i(read_addr2),
    .write_addr_i(write_addr),
    .write_data_i(write_data),
    .read_data1_o(read_data1),
    .read_data2_o(read_data2)
  );
  interrupt_controller interrupt_controller_instance(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .exception_i(illegal_instr),
    .irq_req_i(irq_req_i),
    .mie_i(mie[0]),
    .mret_i(mret),
    .irq_ret_o(irq_ret_o),
    .irq_cause_o(irq_cause),
    .irq_o(irq)
  );
  csr_controller csr_controller_instance(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .trap_i(trap),
    .opcode_i(csr_op),
    .addr_i(instr_i[31:20]),
    .pc_i(PC),
    .mcause_i(mcause),
    .rs1_data_i(read_data1),
    .imm_data_i(imm_Z),
    .write_enable_i(csr_we),
    .read_data_o(read_data),
    .mie_o(mie),
    .mepc_o(mepc),
    .mtvec_o(mtvec)
  );
  alu_riscv alu_riscv_instance(
    .a_i(alu_a),
    .b_i(alu_b),
    .alu_op_i(alu_op),
    .flag_o(alu_flag),
    .result_o(alu_result)
  );
  PC PC_instance(
    .clk(clk_i),
    .rst(rst_i),
    .ADD(inc_mret),
    .en(~stall_i | trap),
    .addr(PC)
  );
  fulladder32 instance_tot(
    .a_i(read_data1),
    .b_i(imm_I),
    .carry_i('b0),
    .sum_o(inc_jalr)
  ),
  _instance_jb_const(
    .a_i(PC),
    .b_i(inc_const_jb ),
    .carry_i('b0),
    .sum_o(inc_const_jb_instr)
  );




















































endmodule : riscv_core
