
import riscv_pkg ::*;

module riscv_lsu(
  input logic clk_i,
  input logic rst_i,

  // Интерфейс с ядром
  input  logic        core_req_i,
  input  logic        core_we_i,
  input  logic [ 2:0] core_size_i,
  input  logic [31:0] core_addr_i,
  input  logic [31:0] core_wd_i,
  output logic [31:0] core_rd_o,
  output logic        core_stall_o,

  // Интерфейс с памятью
  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [ 3:0] mem_be_o,
  output logic [31:0] mem_addr_o,
  output logic [31:0] mem_wd_o,
  input  logic [31:0] mem_rd_i,
  input  logic        mem_ready_i
);

  logic         stall;
  logic         stall_flag;
  logic [ 1:0 ] byte_n;
  logic         half_word;

  assign mem_req_o = core_req_i  ;
  assign mem_we_o  = core_we_i   ;
  assign mem_addr_o  = core_addr_i   ;

  assign stall_flag = !(stall && mem_ready_i) && core_req_i;
  assign core_stall_o  = stall_flag;

  assign byte_n  = core_addr_i[1:0];
  assign half_word   = core_addr_i[1];

  //======================STALL=================================
  always_ff @(posedge clk_i) begin
    if(rst_i)begin
      stall<=0;
    end
    else
      stall <= stall_flag;
  end
  
  always_comb begin

    //======================Write_DATA=================================
    case(core_size_i)
      LDST_B  : mem_wd_o <= {4{core_wd_i[7:0 ]}} ;
      LDST_H  : mem_wd_o <= {2{core_wd_i[15:0]}} ;
      LDST_W  : mem_wd_o <= core_wd_i;
      default : mem_wd_o <= core_wd_i;
    endcase

    //======================READ_DATA===================================
    case(core_size_i)

      //*********************LDST_B********************************
      LDST_B:
      case(byte_n)
        0: core_rd_o <= {{24{mem_rd_i[7]}},{mem_rd_i [ 7:0  ]}};
        1: core_rd_o <= {{24{mem_rd_i[15]}},{mem_rd_i[15:8  ]}};
        2: core_rd_o <= {{24{mem_rd_i[23]}},{mem_rd_i[23:16 ]}};
        3: core_rd_o <= {{24{mem_rd_i[31]}},{mem_rd_i[31:24 ]}};
      endcase

      //*********************LDST_H********************************
      LDST_H:
      case(half_word)
        0: core_rd_o <= {{16{mem_rd_i[15]}},{mem_rd_i [ 15:0 ]}};
        1: core_rd_o <= {{16{mem_rd_i[31]}},{mem_rd_i [ 31:16]}};
      endcase

      //*********************LDST_W********************************
      LDST_W: core_rd_o <= mem_rd_i;
      //*********************LDST_H********************************
      LDST_BU:
      case(byte_n)
        0: core_rd_o <= {{24{1'b0}},{mem_rd_i [ 7:0 ]}};
        1: core_rd_o <= {{24{1'b0}},{mem_rd_i[15:8  ]}};
        2: core_rd_o <= {{24{1'b0}},{mem_rd_i[23:16 ]}};
        3: core_rd_o <= {{24{1'b0}},{mem_rd_i[31:24 ]}};
      endcase

      //*********************LDST_H********************************
      LDST_HU:
      case(half_word)
        0: core_rd_o <= {{16{1'b0}},{mem_rd_i [ 15:0 ]}};
        1: core_rd_o <= {{16{1'b0}},{mem_rd_i [ 31:16]}};
      endcase
      default: core_rd_o <= mem_rd_i;
    endcase

    //======================B H W=================================
    case(core_size_i)
      LDST_B  : mem_be_o <= (4'b0001 << byte_n);
      LDST_H  : mem_be_o <= half_word ? 4'b1100 : 4'b0011;
      LDST_W  : mem_be_o <= 4'b1111;
      default : mem_be_o <= 4'b1111;
    endcase
  end
endmodule






















