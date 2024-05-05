module registers(
  input  logic        clk,
  input  logic        rst,
  input  logic        en,
  input  logic [31:0] data_i,
  output logic [31:0] data_o
);
  
  always_ff @(posedge clk) begin
    if (rst ) begin
      data_o <= 0;

    end
    else if(en) begin
      data_o <= data_i;

    end
    else
      data_o<=data_o;
  end
endmodule : registers
