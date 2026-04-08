`include "CPU_def.svh"
module Imm_Ext (
  input  [31:0] ID_inst,
  output logic [31:0] ID_ext_imm
);

always_comb begin
  unique case (ID_inst[6:2])
    `ITYPE_OPCODE, `LOAD_OPCODE, `JALR_OPCODE: ID_ext_imm = {{20{ID_inst[31]}}, ID_inst[31:20]};  //I-type
    `STORE_OPCODE: ID_ext_imm = {{20{ID_inst[31]}}, ID_inst[31:25], ID_inst[11:7]};  //S-type
    `BRANCH_OPCODE: ID_ext_imm = {{20{ID_inst[31]}}, ID_inst[7], ID_inst[30:25], ID_inst[11:8], 1'b0};  //B-type
    `AUIPC_OPCODE, `LUI_OPCODE: ID_ext_imm = {ID_inst[31:12], 12'd0};  //U-type
    `JAL_OPCODE: ID_ext_imm = {{12{ID_inst[31]}}, ID_inst[19:12], ID_inst[20], ID_inst[30:21], 1'b0};  // J-type
    `SYSTEM_OPCODE: ID_ext_imm = {{20{ID_inst[31]}}, ID_inst[31:20]}; // csr
    default: ID_ext_imm = 32'd0; //R-type
  endcase
end
endmodule
