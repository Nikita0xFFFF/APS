import csr_pkg::*;

module csr_controller(
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        trap_i,

  input  logic [ 2:0] opcode_i,

  input  logic [11:0] addr_i,
  input  logic [31:0] pc_i,
  input  logic [31:0] mcause_i,
  input  logic [31:0] rs1_data_i,
  input  logic [31:0] imm_data_i,
  input  logic        write_enable_i,

  output logic [31:0] read_data_o,
  output logic [31:0] mie_o,
  output logic [31:0] mepc_o,
  output logic [31:0] mtvec_o
);

  logic [ 4:0] wr_en;
  logic [31:0] data_choice;

  logic [31:0] MSCRATCH_o;
  logic [31:0] MCAUSE_o;

  logic [31:0] mepc_mux_o;
  logic [31:0] mcause_mux_o;


  always_comb begin

    case (opcode_i)
      CSR_RW : data_choice <= rs1_data_i;
      CSR_RS : data_choice <= rs1_data_i | read_data_o;
      CSR_RC : data_choice <= ~rs1_data_i & read_data_o;
      CSR_RWI: data_choice <= imm_data_i;
      CSR_RSI: data_choice <= imm_data_i | read_data_o;
      CSR_RCI: data_choice <= ~imm_data_i & read_data_o;
      default: data_choice <= 32'b0;
    endcase

    case(addr_i)
      MIE_ADDR  : begin
    
        if(write_enable_i)begin
          wr_en <= 5'b00001;
        end
        else begin
          wr_en <= 5'b00000;
        end
      end

      MTVEC_ADDR: begin
        if(write_enable_i)begin
          wr_en <= 5'b00010;
        end
        else begin
          wr_en <= 5'b00000;
        end
      end
      MSCRATCH_ADDR:begin
        if(write_enable_i)begin
          wr_en <= 5'b00100;
        end
        else begin
          wr_en <= 5'b00000;
        end
      end
      MEPC_ADDR:begin
        if(write_enable_i)begin
          wr_en <= 5'b01000;
        end
        else begin
          wr_en <= 5'b00000;
        end
      end
      MCAUSE_ADDR:begin
        if(write_enable_i)begin
          wr_en <= 5'b10000;
        end
        else begin
          wr_en <= 5'b00000;
        end
      end
      default:begin
        wr_en <= 5'b00000;
      end
    endcase

    case(addr_i)
      MIE_ADDR       : read_data_o  <= mie_o;
      MTVEC_ADDR     : read_data_o  <= mtvec_o;
      MSCRATCH_ADDR  : read_data_o  <= MSCRATCH_o;
      MEPC_ADDR      : read_data_o  <= mepc_o;
      MCAUSE_ADDR    : read_data_o  <= MCAUSE_o;
      default        : read_data_o <= 0;
    endcase
  end

  registers MIE_ADDR(
    .clk(clk_i),
    .rst(rst_i),
    .en(wr_en[0]),
    .data_i(data_choice),
    .data_o(mie_o)
  );
  registers MTVEC_ADDR (
    .clk(clk_i),
    .rst(rst_i),
    .en(wr_en[1]),
    .data_i(data_choice),
    .data_o(mtvec_o)
  );

  registers MSCRATCH_ADDR(
    .clk(clk_i),
    .rst(rst_i),
    .en(wr_en[2]),
    .data_i(data_choice),
    .data_o(MSCRATCH_o)
  );

  assign mepc_mux_o = trap_i? pc_i:data_choice;
  assign mcause_mux_o = trap_i? mcause_i:data_choice;

  registers MEPC_ADDR (
    .clk(clk_i),
    .rst(rst_i),
    .en(wr_en[3] | trap_i),
    .data_i(mepc_mux_o),
    .data_o(mepc_o)
  );
  registers MCAUSE_ADDR(
    .clk(clk_i),
    .rst(rst_i),
    .en(wr_en[4] | trap_i),
    .data_i(mcause_mux_o),
    .data_o(MCAUSE_o)
  );
endmodule : csr_controller
