module MEM_WB (
  input clk,
  input rst,
  input [31:0] MEM_csr_res,
  input [31:0] MEM_alu_res,
  output logic [31:0] WB_csr_res,
  output logic [31:0] WB_alu_res
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      WB_csr_res <= 32'd0;
      WB_alu_res <= 32'd0;
    end 
    else begin
      WB_csr_res <= MEM_csr_res;
      WB_alu_res <= MEM_alu_res;
    end
  end

endmodule
