module Decoder (
  input  [31:0] ID_inst,
  output logic [ 4:0] ID_opcode,
  output logic [ 2:0] ID_func3,
  output logic [ 6:0] ID_func7,
  output logic [ 4:0] ID_rs1_idx,
  output logic [ 4:0] ID_rs2_idx,
  output logic [ 4:0] ID_rd_idx
);

  assign ID_opcode  = ID_inst[ 6: 2];
  assign ID_func3   = ID_inst[14:12];
  assign ID_func7   = ID_inst[31:25];
  assign ID_rs1_idx = ID_inst[19:15];
  assign ID_rs2_idx = ID_inst[24:20];
  assign ID_rd_idx  = ID_inst[11: 7];

endmodule
