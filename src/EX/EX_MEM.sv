module EX_MEM (
  input clk,
  input rst,
  input [31:0] EX_alu_res,
  input [31:0] EX_ld_rs2,
  input [31:0] EX_rs2_data,
  input [31:0] EX_ext_imm,
  input [31:0] EX_csr_res,
  output logic [31:0] MEM_alu_res,
  output logic [31:0] MEM_ld_rs2,
  output logic [31:0] MEM_rs2_data,
  output logic [31:0] MEM_ext_imm,
  output logic [31:0] MEM_csr_res
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      MEM_alu_res <= 32'd0;
      MEM_ld_rs2  <= 32'd0;
      MEM_rs2_data<= 32'd0;
      MEM_ext_imm <= 32'd0;
      MEM_csr_res <= 32'd0;
    end 
    else begin
      MEM_alu_res <= EX_alu_res;
      MEM_ld_rs2  <= EX_ld_rs2;
      MEM_rs2_data<= EX_rs2_data;
      MEM_ext_imm <= EX_ext_imm;
      MEM_csr_res <= EX_csr_res;
    end
  end

endmodule
