module interrupt_controller(
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        exception_i,
  input  logic        irq_req_i,
  input  logic        mie_i,
  input  logic        mret_i,

  output logic        irq_ret_o,
  output logic [31:0] irq_cause_o,
  output logic        irq_o
);
  logic D_exc_h;
  logic Q_exc_h;

  logic D_irq_h;
  logic Q_irq_h;

  logic wire_1;
  logic wire_2;
  

  assign irq_o = ~(wire_1 | wire_2) &(irq_req_i & mie_i);
  assign irq_ret_o = (~wire_1 & mret_i);
  assign irq_cause_o = 32'h1000_0010;
  
  //================EXC_h==========================
  assign wire_1 = exception_i | Q_exc_h;
  assign D_exc_h = wire_1 & ~mret_i;
  
  always_ff @( posedge clk_i ) begin
    if(rst_i) Q_exc_h = 0;
    else Q_exc_h = D_exc_h;
  end
  
  //================IRQ_H==========================
  assign wire_2 = Q_irq_h;
  assign D_irq_h = ~irq_ret_o & (irq_o| Q_irq_h);

  always_ff @( posedge clk_i ) begin
    if(rst_i) Q_irq_h = 0;
    else Q_irq_h = D_irq_h;
  end
endmodule : interrupt_controller
