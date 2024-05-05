module PC(
  input logic clk,
  input logic rst,
  input logic [31:0]ADD,
  input logic en,
  output logic [31:0]addr
);
  always_ff @(posedge clk)begin
    if(rst)begin
      addr<=0;
    end
    else begin
      if (en)
        addr<=ADD;
      else
        addr<=addr;
    end
  end
endmodule