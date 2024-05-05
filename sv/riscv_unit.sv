
import my_signals_pkg ::*;

module riscv_unit(
  input clk_i,
  input rst_i
);
  logic        irq_req ;
  logic        irq_ret ;
  riscv_core core(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .stall_i(core_stall_o),
    .instr_i(instr_i),
    .mem_rd_i(core_rd_o),
    .instr_addr_o(instr_addr_o),
    .mem_addr_o(core_addr_i),
    .mem_size_o(core_size_i),
    .mem_req_o(core_req_i),
    .mem_we_o(core_we_i),
    .mem_wd_o(core_wd_i),
    .irq_req_i(irq_req),
    .irq_ret_o(irq_ret)
  );
  instr_mem instr_mem_instance(
    .addr_i(instr_addr_o),
    .read_data_o(instr_i)
  );

  riscv_lsu riscv_lsu_instance(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .core_req_i(core_req_i),
    .core_we_i(core_we_i),
    .core_size_i(core_size_i),
    .core_addr_i(core_addr_i),
    .core_wd_i(core_wd_i),
    .core_rd_o(core_rd_o),
    .core_stall_o(core_stall_o),
    .mem_req_o(lsu_mem_req_o),
    .mem_we_o(lsu_mem_we_o),
    .mem_be_o(lsu_mem_be_o),
    .mem_addr_o(lsu_mem_addr_o),
    .mem_wd_o(lsu_mem_wd_o),
    .mem_rd_i(lsu_mem_rd_i),
    .mem_ready_i(lsu_mem_ready_i)
  );

  ext_mem ext_mem_instance(
    .clk_i(clk_i),
    .mem_req_i(lsu_mem_req_o),
    .write_enable_i(lsu_mem_we_o),
    .byte_enable_i(lsu_mem_be_o),
    .addr_i(lsu_mem_addr_o),
    .write_data_i(lsu_mem_wd_o),
    .read_data_o(lsu_mem_rd_i),
    .ready_o(lsu_mem_ready_i)
  );
endmodule : riscv_unit

