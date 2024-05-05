package my_signals_pkg;
  //                          dop wires
  logic [31:0] wb_data;
  logic [31:0] PC;
  logic [31:0] inc_jalr;
  logic [31:0] sum_instr;
  logic [31:0] mux_PC;
  //                          type const
  logic [31:0] imm_I;
  logic [31:0] imm_U;
  logic [31:0] imm_S;
  logic [31:0] imm_B;
  logic [31:0] imm_J;

  //                          registr file
  logic [4:0]  RA1;
  logic [4:0]  RA2;
  logic [4:0]  WA;
  logic [31:0] RD1;
  logic [31:0] RD2;
  logic WE;
  logic [31:0] WD;

  //                           decoder
  logic [31:0 ] instr;
  logic [ 1:0 ] a_sel;
  logic [ 2:0 ] b_sel;
  logic [ 2:0 ] csr_op_o;
  logic         csr_we_o;
  logic         gpr_we;
  logic [ 1:0 ] wb_sel;
  logic         illegal_instr_o;
  logic         branch;
  logic         jal;
  logic         jalr;
  logic         mret_o;

  //                           log_mux
  logic mux_b;
  logic mux_jal;

  //                          riscv_core
  logic        stall_i;
  logic [31:0] instr_i;
  logic [31:0] mem_rd_i;

  logic [31:0] instr_addr_o;
  logic [31:0] mem_addr_o;
  logic [ 2:0] mem_size_o;
  logic        mem_req_o;
  logic        mem_we_o;
  logic [31:0] mem_wd_o;
  // ================ ALU =============================
  logic [ 4:0 ] alu_op;
  logic         alu_flag;
  logic [31:0 ] alu_result;
  logic [31:0 ] alu_a;
  logic [31:0 ] alu_b;
  // ================ LSU ====
  logic        core_req_i;
  logic        core_we_i;
  logic [ 2:0] core_size_i;
  logic [31:0] core_addr_i;
  logic [31:0] core_wd_i;
  logic [31:0] core_rd_o;
  logic        core_stall_o;


  logic        lsu_mem_req_o;
  logic        lsu_mem_we_o;
  logic [ 3:0] lsu_mem_be_o;
  logic [31:0] lsu_mem_addr_o;
  logic [31:0] lsu_mem_wd_o;
  logic [31:0] lsu_mem_rd_i;
  logic        lsu_mem_ready_i;
endpackage : my_signals_pkg
