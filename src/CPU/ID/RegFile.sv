module RegFile (
  input  clk,
  input  rst,
  input  WB_wb_en,
  input  [31:0] WB_data,
  input  [ 4:0] WB_rd_idx,
  input  [ 4:0] ID_rs1_idx,
  input  [ 4:0] ID_rs2_idx,
  output logic [31:0] ID_rs1_data,
  output logic [31:0] ID_rs2_data
);

  integer i;
  logic [31:0] registers [0:31];

  assign ID_rs1_data = registers[ID_rs1_idx];
  assign ID_rs2_data = registers[ID_rs2_idx];

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 32; i++) begin
        registers[i] <= 32'd0;
      end
    end else begin
      registers[WB_rd_idx] <= (WB_rd_idx == 5'd0) ? registers[WB_rd_idx] :
                              (WB_wb_en)? WB_data : registers[WB_rd_idx];
    end
  end

endmodule
