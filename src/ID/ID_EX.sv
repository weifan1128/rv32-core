module ID_EX (
  input clk,
  input rst,
  input stall,
  input jb_flush,
  input last_jb_flush,
  input [31:0] IF_jb_pc,
  input [31:0] ID_pc,
  input [31:0] ID_rs1_data,
  input [31:0] ID_rs2_data,
  input [31:0] ID_ext_imm,
  output logic [31:0] EX_pc,
  output logic [31:0] EX_rs1_data,
  output logic [31:0] EX_rs2_data,
  output logic [31:0] EX_ext_imm
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin  
      EX_pc <= 32'd0;
      EX_rs1_data <= 32'd0;
      EX_rs2_data <= 32'd0;
      EX_ext_imm <= 32'd0;
    end 
    else if (last_jb_flush) begin
      EX_pc <= 32'd0;
      EX_rs1_data <= 32'd0;
      EX_rs2_data <= 32'd0;
      EX_ext_imm <= 32'd0;
    end 
    else if (jb_flush) begin
      EX_pc <= 32'd0;
      EX_rs1_data <= 32'd0;
      EX_rs2_data <= 32'd0;
      EX_ext_imm <= 32'd0;
    end 
    else if (stall) begin
      EX_pc <= 32'd0;
      EX_rs1_data <= 32'd0;
      EX_rs2_data <= 32'd0;
      EX_ext_imm <= 32'd0;
    end else begin
      EX_pc <= ID_pc;
      EX_rs1_data <= ID_rs1_data;
      EX_rs2_data <= ID_rs2_data;
      EX_ext_imm <= ID_ext_imm;
    end
  end

endmodule
