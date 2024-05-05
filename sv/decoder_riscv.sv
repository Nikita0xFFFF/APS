`timescale 1ns / 1ps

module decoder_riscv (
  input  logic [31:0 ] fetched_instr_i,
  output logic [ 1:0 ] a_sel_o,
  output logic [ 2:0 ] b_sel_o,
  output logic [ 4:0 ] alu_op_o,
  output logic [ 2:0 ] csr_op_o,
  output logic         csr_we_o,
  output logic         mem_req_o,
  output logic         mem_we_o,
  output logic [ 2:0 ] mem_size_o,
  output logic         gpr_we_o,
  output logic [ 1:0 ] wb_sel_o,
  output logic         illegal_instr_o,
  output logic         branch_o,
  output logic         jal_o,
  output logic         jalr_o,
  output logic         mret_o

);

  import  riscv_pkg::*;
  import  csr_pkg::*;

  logic [6:0]opcode;
  logic [6:0]func7;
  logic [2:0]func3;

  assign opcode = fetched_instr_i [6:0];
  assign func7 = fetched_instr_i  [31:25];
  assign func3 = fetched_instr_i  [14:12];



  always_comb
  begin
    illegal_instr_o <= 'b0;

    a_sel_o <= OP_A_RS1;
    b_sel_o <= OP_B_RS2;

    gpr_we_o <= 'b0;
    wb_sel_o <= WB_EX_RESULT;

    mem_req_o <= 'b0;
    mem_we_o  <= 'b0;
    mem_size_o <= LDST_B; // 0

    alu_op_o <= 'b01010; // NOP
    branch_o <= 'b0;

    jalr_o <= 'b0;
    jal_o  <= 'b0;

    csr_op_o <= 'b0;
    csr_we_o <= 'b0;
    mret_o <= 'b0;
    if(opcode[1:0]!='h3)
      illegal_instr_o <= 'b1;
    else
      case(opcode[6:2])
        //=============================LOAD_OPCODE=======================================================     
        LOAD_OPCODE:
        begin
          a_sel_o   <= OP_A_RS1;
          b_sel_o   <= OP_B_IMM_I;
          alu_op_o  <= ALU_ADD;
          gpr_we_o  <= 'b1;
          wb_sel_o  <=  WB_LSU_DATA;
          mem_req_o <= 'b1;
          case(func3)
            'h0:  mem_size_o <= func3;
            'h1:  mem_size_o <= func3;
            'h2:  mem_size_o <= func3;
            'h4:  mem_size_o <= func3;
            'h5:  mem_size_o <= func3;
            default: begin illegal_instr_o <='b1;  mem_req_o <= 'b0; gpr_we_o <= 'b0; end
          endcase
        end
        //============================MISC_MEM_OPCODE====================================================
        MISC_MEM_OPCODE:
        begin
          mem_req_o <= 'b0;
          gpr_we_o <= 'b0;
          illegal_instr_o <= (func3!=0)? 'b1: 'b0;
        end
        //============================OP_IMM_OPCODE======================================================    
        OP_IMM_OPCODE:
        begin
          gpr_we_o <= 'b1;
          a_sel_o <= OP_A_RS1;
          b_sel_o <= OP_B_IMM_I;
          wb_sel_o <= WB_EX_RESULT;
          case(func3)
            3'h0: alu_op_o <= ALU_ADD;
            3'h4: alu_op_o <= ALU_XOR;
            3'h6: alu_op_o <= ALU_OR;
            3'h7: alu_op_o <= ALU_AND;
            3'h1: case(func7)
              7'h00: alu_op_o <= ALU_SLL;
              default: begin illegal_instr_o <= 'b1; gpr_we_o <= 'b0; end
            endcase
            3'h5: case(func7)
              7'h00: alu_op_o <= ALU_SRL;
              7'h20: alu_op_o <= ALU_SRA;
              default: begin illegal_instr_o <= 'b1; gpr_we_o <= 'b0; end
            endcase
            3'h2  :   alu_op_o    <=  ALU_SLTS;
            3'h3  :   alu_op_o    <=  ALU_SLTU;
            default :  begin illegal_instr_o <= 'b1;  gpr_we_o    <=  'b0; end
          endcase
        end
        //============================AUIPC_OPCODE======================================================
        AUIPC_OPCODE:begin
          gpr_we_o <= 'b1;
          a_sel_o <= OP_A_CURR_PC;
          b_sel_o <= OP_B_IMM_U;
          alu_op_o <= ALU_ADD;
          wb_sel_o <= WB_EX_RESULT;
        end
        //============================STORE_OPCODE======================================================
        STORE_OPCODE: begin
          a_sel_o <= OP_A_RS1;
          b_sel_o <= OP_B_IMM_S;
          alu_op_o <= ALU_ADD;
          mem_req_o <= 'b1;
          mem_we_o <=  'b1;
          case(func3)
            3'h0: mem_size_o <= LDST_B;
            3'h1: mem_size_o <= LDST_H;
            3'h2: mem_size_o <= LDST_W;
            default: begin illegal_instr_o <= 'b1; mem_req_o <= 'b0; mem_we_o <= 'b0; end
          endcase
        end
        //============================OP_OPCODE=========================================================
        OP_OPCODE: begin
          a_sel_o <= OP_A_RS1;
          b_sel_o <= OP_B_RS2;
          gpr_we_o <= 'b1;
          wb_sel_o <= WB_EX_RESULT;
          case(func3)
            3'h0: case(func7)
              7'h00: alu_op_o <= ALU_ADD;
              7'h20: alu_op_o <= ALU_SUB;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
            endcase
            3'h4: case(func7)
              7'h00:  alu_op_o <= ALU_XOR;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
            endcase
            3'h6: case(func7)
              7'h00: alu_op_o <= ALU_OR;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
            endcase
            3'h7: case(func7)
              7'h00: alu_op_o <= ALU_AND;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
            endcase
            3'h1: case(func7)
              7'h00: alu_op_o <= ALU_SLL;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
            endcase
            3'h5: case(func7)
              7'h00: alu_op_o <= ALU_SRL;
              7'h20: alu_op_o <= ALU_SRA;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
            endcase
            3'h2:case(func7)
              7'h00: alu_op_o <= ALU_SLTS;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o  <= 'b0; end
            endcase
            3'h3: case(func7)
              7'h00: alu_op_o <= ALU_SLTU;
              default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
            endcase
            default: begin illegal_instr_o <= 'b1;  gpr_we_o <= 'b0; end
          endcase
        end
        //============================LUI_OPCODE========================================================
        LUI_OPCODE:
        begin
          gpr_we_o <= 'b1;
          a_sel_o <= OP_A_ZERO;
          b_sel_o <= OP_B_IMM_U;
          alu_op_o <= ALU_ADD;
          wb_sel_o <= WB_EX_RESULT;
        end
        //============================BRANCH_OPCODE=====================================================
        BRANCH_OPCODE:begin
          a_sel_o <= OP_A_RS1;
          b_sel_o <= OP_B_RS2;
          branch_o <= 'b1;
          case(func3)
            3'h0: alu_op_o <= ALU_EQ;
            3'h1: alu_op_o <= ALU_NE;
            3'h4: alu_op_o <= ALU_LTS;
            3'h5: alu_op_o <= ALU_GES;
            3'h6: alu_op_o <= ALU_LTU;
            3'h7: alu_op_o <= ALU_GEU;
            default: begin branch_o <= 'b0; illegal_instr_o <= 'b1; end
          endcase
        end
        //===========================JALR_OPCODE=========================================================
        JALR_OPCODE:begin
          a_sel_o <= OP_A_CURR_PC;
          b_sel_o <= OP_B_INCR;
          alu_op_o <= ALU_ADD;
          wb_sel_o <= WB_EX_RESULT;
          case(func3)
            3'h0 : begin gpr_we_o <=  'b1; jalr_o <=  'b1; end
            default : illegal_instr_o <= 'b1;
          endcase
        end
        //==========================JAL_OPCODE===========================================================
        JAL_OPCODE:begin
          a_sel_o <= OP_A_CURR_PC;
          b_sel_o <= OP_B_INCR;
          wb_sel_o <= WB_EX_RESULT;
          alu_op_o <= ALU_ADD;
          jal_o <= 'b1;
          gpr_we_o <= 'b1;
        end
        //==========================SYSTEM_OPCODE=========================================================
        SYSTEM_OPCODE:begin
          case(func3)
            3'h0: begin
              illegal_instr_o <= 'b1;
              case(func7)
                7'h00 :  illegal_instr_o <= 'b1;
                7'h01 :  illegal_instr_o <= 'b1;
                7'h18 :  begin mret_o <= 'b1; illegal_instr_o <= 'b0; end
                default: mret_o <= 'b0;
              endcase
            end
            3'h1: begin wb_sel_o <= WB_CSR_DATA; csr_op_o <= CSR_RW;  csr_we_o <= 'b1; gpr_we_o <= 'b1; end
            3'h2: begin wb_sel_o <= WB_CSR_DATA; csr_op_o <= CSR_RS;  csr_we_o <= 'b1; gpr_we_o <= 'b1; end
            3'h3: begin wb_sel_o <= WB_CSR_DATA; csr_op_o <= CSR_RC;  csr_we_o <= 'b1; gpr_we_o <= 'b1; end
            3'h5: begin wb_sel_o <= WB_CSR_DATA; csr_op_o <= CSR_RWI; csr_we_o <= 'b1; gpr_we_o <= 'b1; end
            3'h6: begin wb_sel_o <= WB_CSR_DATA; csr_op_o <= CSR_RSI; csr_we_o <= 'b1; gpr_we_o <= 'b1; end
            3'h7: begin wb_sel_o <= WB_CSR_DATA; csr_op_o <= CSR_RCI; csr_we_o <= 'b1; gpr_we_o <= 'b1; end
            default: illegal_instr_o <= 'b1;
          endcase
        end
        default: begin illegal_instr_o <= 'b1; a_sel_o <= OP_A_RS1; b_sel_o <= OP_B_RS2; gpr_we_o <= 'b0;

          wb_sel_o <= WB_EX_RESULT; mem_req_o <= 'b0; mem_we_o <= 'b0; mem_size_o <= LDST_B;

          alu_op_o <= 'b01010; branch_o <= 'b0; jalr_o <= 'b0; jal_o <= 'b0; csr_op_o <= 'b0;

          csr_we_o <= 'b0; mret_o <= 'b0;
        end
      endcase
  end
endmodule