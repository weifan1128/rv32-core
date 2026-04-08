`include "CPU_def.svh"
// IF stage
`include "./CPU/IF/IF_ID.sv"
`include "./CPU/IF/Reg_PC.sv"
// ID stage
`include "./CPU/ID/ID_EX.sv"
`include "./CPU/ID/RegFile.sv"
`include "./CPU/ID/Decoder.sv"
`include "./CPU/ID/Imm_Ext.sv"
// EX stage
`include "./CPU/EX/EX_MEM.sv"
`include "./CPU/EX/ALU.sv"
`include "./CPU/EX/JB_Unit.sv"
`include "./CPU/EX/Multiplier.sv"
// MEM stage
`include "./CPU/MEM/MEM_WB.sv"
`include "./CPU/MEM/csr_unit.sv"
`include "./CPU/MEM/ST_align_unit.sv"
// WB stage
`include "./CPU/WB/LD_align_unit.sv"
// others
`include "./CPU/Controller.sv"
`include "./CPU/rst_buff.sv"
`include "./Mux.sv"

module CPU (
  input clk,
  input rst,
  input [31:0] ID_inst,
  input [31:0] dm_ld_data,
  output logic [31:0] IF_pc,
  output logic [ 3:0] MEM_dm_w_en,
  output logic [31:0] MEM_alu_mul_res,
  output logic [31:0] MEM_dm_st_data
);

//pc
logic [31:0] ID_pc, EX_pc;
logic [31:0] next_pc;
logic [31:0] IF_jb_pc;
//inst
logic [31:0] ID_ext_imm, EX_ext_imm, MEM_ext_imm; // ext_imm
logic [31:0] ID_rs1_data, EX_rs1_data; // rs1_data
logic [31:0] ID_rs2_data, EX_rs2_data, MEM_rs2_data; // rs2_data
logic [31:0] ID_new_rs1_data, ID_new_rs2_data, EX_new_rs1_data, EX_new_rs2_data;  //mux 1-4 output
logic [ 4:0] ID_rs1_idx, ID_rs2_idx, EX_rs1_idx, EX_rs2_idx;
logic [ 4:0] ID_rd_idx, EX_rd_idx, WB_rd_idx;
logic [ 4:0] ID_opcode, EX_opcode, MEM_opcode;
logic [ 2:0] ID_func3, EX_func3, MEM_func3, WB_func3;
logic [ 6:0] ID_func7, EX_func7, MEM_func7;
logic [31:0] ID_true_inst;
//csr
logic [31:0] EX_csr_res, MEM_csr_res, WB_csr_res;
logic [31:0] MEM_rs1_data;
logic [ 4:0] MEM_rs1_idx;
//alu
logic [31:0] EX_alu_res, MEM_alu_res, WB_alu_res;
logic [31:0] EX_alu_op1, EX_alu_op2, MEM_alu_op1, MEM_alu_op2;
logic [31:0] MEM_mul_res;
logic [31:0] EX_ld_rs2, MEM_ld_rs2;
//JB
logic [31:0] jb_op1;
//pipeline signal
logic jb_flush, last_jb_flush;
logic stall, last_stall;
//mux
logic ID_rs1_data_sel, ID_rs2_data_sel;         //mux 1&2 ctrl
logic [1:0] EX_rs1_data_sel, EX_rs2_data_sel;   //mux 3&4 ctrl
logic EX_alu_op1_sel, EX_alu_op2_sel, EX_jb_op1_sel;//mux 5 & 6 & 7 ctrl
logic WB_wb_data_sel;                     //mux 9 ctrl
//others
logic rst_buff;
logic [31:0] WB_dm_data_out;   //mux8 input
logic [31:0] WB_data;       //mux8 output
logic        MEM_dm_w_en_i;
logic WB_wb_en;

// IF stage
IF_ID IF_ID(
  .clk(clk),
  .rst(rst),
  .stall(stall),
  .last_stall(last_stall),
  .jb_flush(jb_flush),
  .IF_jb_pc(IF_jb_pc),
  .IF_pc(IF_pc),
  .ID_inst(ID_inst),
  .ID_pc(ID_pc),
  .ID_true_inst(ID_true_inst)
);

Reg_PC Reg_PC(
  .clk(clk),
  .rst(rst_buff),
  .stall(stall),
  .next_pc(next_pc),
  .IF_pc(IF_pc)
);

// ID stage
ID_EX ID_EX(
  .clk(clk),
  .rst(rst_buff),
  .stall(stall),
  .jb_flush(jb_flush),
  .last_jb_flush(last_jb_flush),
  .IF_jb_pc(IF_jb_pc),
  .ID_pc(ID_pc),
  .ID_rs1_data(ID_new_rs1_data),
  .ID_rs2_data(ID_new_rs2_data),
  .ID_ext_imm(ID_ext_imm),
  .EX_pc(EX_pc),
  .EX_rs1_data(EX_rs1_data),
  .EX_rs2_data(EX_rs2_data),
  .EX_ext_imm(EX_ext_imm)
);

Decoder Decoder(
  .ID_inst(ID_true_inst),
  .ID_opcode(ID_opcode),
  .ID_func3(ID_func3),
  .ID_func7(ID_func7),
  .ID_rs1_idx(ID_rs1_idx),
  .ID_rs2_idx(ID_rs2_idx),
  .ID_rd_idx(ID_rd_idx)
);

Imm_Ext Imm_Ext(
  .ID_inst(ID_true_inst),
  .ID_ext_imm(ID_ext_imm)
);

RegFile RegFile(
  .clk(clk),
  .rst(rst_buff),
  .WB_wb_en(WB_wb_en),
  .WB_data(WB_data),
  .WB_rd_idx(WB_rd_idx),
  .ID_rs1_idx(ID_rs1_idx),
  .ID_rs2_idx(ID_rs2_idx),

  .ID_rs1_data(ID_rs1_data),
  .ID_rs2_data(ID_rs2_data)
);

// EX stage
EX_MEM EX_MEM(
  .clk(clk),
  .rst(rst_buff),
  .EX_alu_op1(EX_alu_op1),
  .EX_alu_op2(EX_alu_op2),
  .EX_alu_res(EX_alu_res),
  .EX_ld_rs2(EX_ld_rs2),
  .EX_rs2_data(EX_new_rs2_data),
  .EX_ext_imm(EX_ext_imm),
  .EX_csr_res(EX_csr_res),

  .MEM_alu_op1(MEM_alu_op1),
  .MEM_alu_op2(MEM_alu_op2),
  .MEM_alu_res(MEM_alu_res),
  .MEM_ld_rs2(MEM_ld_rs2),
  .MEM_rs2_data(MEM_rs2_data),
  .MEM_ext_imm(MEM_ext_imm),
  .MEM_csr_res(MEM_csr_res)
);

ALU ALU(
  .EX_opcode(EX_opcode),
  .EX_func3(EX_func3),
  .EX_func7(EX_func7),
  .EX_alu_op1(EX_alu_op1),
  .EX_alu_op2(EX_alu_op2),
  .EX_csr_res(EX_csr_res),
  .EX_alu_res(EX_alu_res)
);

JB_Unit JB_Unit(
  .jb_op1(jb_op1),
  .jb_op2(EX_ext_imm),
  .jb_flush(jb_flush),
  .IF_jb_pc(IF_jb_pc)
);

Multiplier Multiplier(
  .mul_op1(MEM_alu_op1),
  .mul_op2(MEM_alu_op2),
  .MEM_func3(MEM_func3),
  .MEM_mul_res_o(MEM_mul_res)
);

// MEM stage
MEM_WB MEM_WB(
  .clk(clk),
  .rst(rst_buff),
  .MEM_csr_res(MEM_csr_res),
  .MEM_alu_res(MEM_alu_mul_res),
  .WB_csr_res(WB_csr_res),
  .WB_alu_res(WB_alu_res)
);

CSR_unit csr_unit(
  .clk(clk),
  .rst(rst_buff),
  .EX_opcode(EX_opcode),
  .EX_func3(EX_func3),
  .EX_func7(EX_func7),
  .EX_rs1_idx(EX_rs1_idx),
  .EX_rs2_idx(EX_rs2_idx),
  .EX_rd_idx(EX_rd_idx),
  .EX_csr_addr(EX_ext_imm[11:0]),
  .EX_csr_res(EX_csr_res)
);

ST_align_unit ST_align_unit(
  .MEM_opcode(MEM_opcode),
  .MEM_func3(MEM_func3),
  .MEM_addr_offset(MEM_alu_mul_res[1:0]),
  .MEM_rs2_data(MEM_rs2_data),
  .MEM_dm_w_en(MEM_dm_w_en),
  .MEM_dm_st_data(MEM_dm_st_data)
);

// WB
LD_align_unit LD_align_unit(
  .WB_dm_data_in(dm_ld_data),
  .WB_ld_addr_l2b(WB_alu_res[1:0]),
  .WB_func3(WB_func3),
  .WB_dm_data_out(WB_dm_data_out)
);

// others
Controller Controller(
  .clk(clk),
  .rst(rst_buff),
  .ID_inst(ID_true_inst),
  .ID_opcode(ID_opcode),
  .ID_func3(ID_func3),
  .ID_func7(ID_func7),
  .ID_rd_idx(ID_rd_idx),
  .ID_rs1_idx(ID_rs1_idx),
  .ID_rs2_idx(ID_rs2_idx),
  //from ALU
  .EX_alu_res(EX_alu_res),
  //Hazard
  .stall(stall),
  .last_stall(last_stall),
  .jb_flush(jb_flush),
  .last_jb_flush(last_jb_flush),
  //To ALU
  .EX_opcode(EX_opcode),
  .EX_func3(EX_func3),
  .EX_func7(EX_func7),
  .EX_rs1_idx(EX_rs1_idx),
  .EX_rs2_idx(EX_rs2_idx),
  .EX_rd_idx(EX_rd_idx),
  //To ST AlignUnit
  .MEM_func3(MEM_func3),
  .MEM_func7(MEM_func7),
  //To csr
  .MEM_opcode(MEM_opcode),
  //To Reg File
  .WB_wb_en(WB_wb_en),
  .WB_rd_idx(WB_rd_idx),
  //To LD AlignUnit
  .WB_func3(WB_func3),
  // Mux
  .ID_rs1_data_sel(ID_rs1_data_sel),
  .ID_rs2_data_sel(ID_rs2_data_sel),
  .EX_rs1_data_sel(EX_rs1_data_sel),
  .EX_rs2_data_sel(EX_rs2_data_sel),
  .EX_alu_op1_sel(EX_alu_op1_sel),
  .EX_alu_op2_sel(EX_alu_op2_sel),
  .EX_jb_op1_sel(EX_jb_op1_sel),
  .WB_wb_data_sel(WB_wb_data_sel)
);

rst_buff rst_buf(
	.clk(clk),
	.rst(rst),
	.rst_buff(rst_buff)
);

logic [31:0] IF_pc_plus4;
assign IF_pc_plus4 = IF_pc + 32'd4;

// mux 0 - next PC: PC+4 or jump/branch target
Mux_2to1 next_pc_mux (.sel(jb_flush),       .in1(IF_pc_plus4),    .in2(IF_jb_pc),        .out(next_pc));
// mux 1 - ID rs1: regfile or WB forwarding
Mux_2to1 id_rs1_mux  (.sel(ID_rs1_data_sel),.in1(ID_rs1_data),    .in2(WB_data),         .out(ID_new_rs1_data));
// mux 2 - ID rs2: regfile or WB forwarding
Mux_2to1 id_rs2_mux  (.sel(ID_rs2_data_sel),.in1(ID_rs2_data),    .in2(WB_data),         .out(ID_new_rs2_data));
// mux 3 - EX rs1: MEM→EX / WB→EX / no forward
Mux_3to1 ex_rs1_mux  (.sel(EX_rs1_data_sel),.in1(MEM_alu_mul_res),.in2(WB_data),         .in3(EX_rs1_data),    .out(EX_new_rs1_data));
// mux 4 - EX rs2: MEM→EX / WB→EX / no forward
Mux_3to1 ex_rs2_mux  (.sel(EX_rs2_data_sel),.in1(MEM_alu_mul_res),.in2(WB_data),         .in3(EX_rs2_data),    .out(EX_new_rs2_data));
// mux 5 - ALU op1: rs1 or PC (for AUIPC/JAL)
Mux_2to1 alp_op1_mux (.sel(EX_alu_op1_sel), .in1(EX_pc),          .in2(EX_new_rs1_data), .out(EX_alu_op1));
// mux 6 - ALU op2: imm or rs2
Mux_2to1 alp_op2_mux (.sel(EX_alu_op2_sel), .in1(EX_ext_imm),     .in2(EX_new_rs2_data), .out(EX_alu_op2));
// mux 7 - JB unit sel op1
Mux_2to1 jb_sel_mux  (.sel(EX_jb_op1_sel),  .in1(EX_pc),          .in2(EX_new_rs1_data), .out(jb_op1));
// mux 8 - MEM alu or mul
Mux_2to1 alu_mul_mux (.sel(MEM_func7[0] && MEM_opcode == `RTYPE_OPCODE),   .in1(MEM_alu_res),    .in2(MEM_mul_res),     .out(MEM_alu_mul_res));
// mux 9 - WB data: load / CSR / ALU result
Mux_2to1 wb_data_mux (.sel(WB_wb_data_sel), .in1(WB_alu_res),     .in2(WB_dm_data_out),  .out(WB_data));

endmodule
