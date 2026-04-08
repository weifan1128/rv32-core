module Reg_PC (
  input  clk,
  input  rst,
  input  stall,
  input  [31:0] next_pc,
  output logic [31:0] IF_pc
);
  logic [31:0] last_pc;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      IF_pc <= 32'd0;
    end 
    else begin
      IF_pc <= (stall)? IF_pc : next_pc;
    end
  end

endmodule
