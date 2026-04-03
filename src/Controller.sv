`include "../include/CPU_def.svh"
`define USES_RS1_AS_ALU_OP1(op) \
  ((op == `BRANCH_OPCODE) || (op == `LOAD_OPCODE)  || \
   (op == `STORE_OPCODE)  || (op == `ITYPE_OPCODE) || \
   (op == `RTYPE_OPCODE))

`define USES_RS2_AS_ALU_OP2(op) \
  ((op == `BRANCH_OPCODE) || (op == `RTYPE_OPCODE) || (op == `SYSTEM_OPCODE))

module Controller (
  input clk,
  input rst,
  //from Decoder
  input [31:0] ID_inst, // help debug
  input [ 4:0] ID_opcode,
  input [ 2:0] ID_func3,
  input [ 6:0] ID_func7,
  input [ 4:0] ID_rd_idx,
  input [ 4:0] ID_rs1_idx,
  input [ 4:0] ID_rs2_idx,
  //from ALU
  input [31:0] EX_alu_res,
  //Hazard
  output logic stall,
  output logic last_stall,
  output logic jb_flush,
  output logic last_jb_flush,
  //To ALU
  output logic [4:0] EX_opcode,
  output logic [2:0] EX_func3,
  output logic [6:0] EX_func7,
  output logic [4:0] EX_rs1_idx,
  output logic [4:0] EX_rs2_idx,
  output logic [4:0] EX_rd_idx,
  //To ST AlignUnit
  output logic [ 2:0] MEM_func3,
  output logic [ 6:0] MEM_func7,
  //To csr
  output logic [ 4:0] MEM_opcode,
  //To Reg File
  output logic WB_wb_en,
  output logic [ 4:0] WB_rd_idx,
  //To LD AlignUnit
  output logic [ 2:0] WB_func3,

  //To Mux 1
  output logic ID_rs1_data_sel,
  //To Mux 2
  output logic ID_rs2_data_sel,
  //To Mux 3
  output logic [1:0] EX_rs1_data_sel,
  //To Mux 4
  output logic [1:0] EX_rs2_data_sel,
  //To Mux 5
  output logic EX_alu_op1_sel,
  //To Mux 6
  output logic EX_alu_op2_sel,
  //To Mux 7
  output logic EX_jb_op1_sel,
  //To mux 8
  output logic WB_wb_data_sel
);
  //EX
  logic [31:0] EX_inst;
  // logic [ 4:0] EX_rd_idx;
  // logic [ 4:0] EX_rs1_idx, EX_rs2_idx;
  //MEM
  logic [31:0] MEM_inst;
  logic [ 4:0] MEM_rd_idx;
  //WB
  logic [ 4:0] WB_opcode;
  //mux sel signal decision
  logic is_ID_use_rs1, is_ID_use_rs2, is_ID_rs1_WB_rd_overlap, is_ID_rs2_WB_rd_overlap;
  logic is_EX_use_rs1, is_EX_use_rs2, is_MEM_use_rd;
  logic is_EX_rs1_WB_rd_overlap, is_EX_rs1_MEM_rd_overlap, is_EX_rs2_WB_rd_overlap, is_EX_rs2_MEM_rd_overlap;
  logic is_ID_rs1_EX_rd_overlap, is_ID_rs2_EX_rd_overlap, is_IDEX_overlap;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      //EX
      EX_opcode  <= 5'd4;
      EX_func3   <= 3'd0;
      EX_func7   <= 7'd0;
      EX_rd_idx  <= 5'd0;
      EX_rs1_idx <= 5'd0;
      EX_rs2_idx <= 5'd0;
    end else begin
      unique if (stall || jb_flush || last_jb_flush) begin
        EX_opcode  <= 5'd4;
        EX_func3   <= 3'd0;
        EX_func7   <= 7'd0;
        EX_rd_idx  <= 5'd0;
        EX_rs1_idx <= 5'd0;
        EX_rs2_idx <= 5'd0;
      end else begin
        EX_opcode  <= ID_opcode;
        EX_func7   <= ID_func7;
        EX_func3   <= ID_func3;
        EX_rd_idx  <= ID_rd_idx;
        EX_rs1_idx <= ID_rs1_idx;
        EX_rs2_idx <= ID_rs2_idx;
      end
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      //MEM
      MEM_opcode <= 5'd4;
      MEM_func3  <= 3'd0;
      MEM_func7  <= 6'd0;
      MEM_rd_idx <= 5'd0;
      //WB
      WB_opcode <= 5'd4;
      WB_func3  <= 3'd0;
      WB_rd_idx <= 5'd0;
    end else begin
      //EX to MEM
      MEM_opcode <= EX_opcode;
      MEM_func3  <= EX_func3;
      MEM_func7  <= EX_func7;
      MEM_rd_idx <= EX_rd_idx;
      //MEM to WB
      WB_opcode  <= MEM_opcode;
      WB_func3   <= MEM_func3;
      WB_rd_idx  <= MEM_rd_idx;
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      EX_inst <= `RV_NOP;
      MEM_inst <= `RV_NOP;
    end else begin
      EX_inst <= (stall)? `RV_NOP : ID_inst;
      MEM_inst <= EX_inst;
    end
  end
//---------------------------------ID stage---------------------------------
  assign is_ID_use_rs1 = `IS_RS1_USED(ID_opcode);
  assign is_ID_use_rs2 = `IS_RS2_USED(ID_opcode);
//---------------------------------EX stage---------------------------------
  // Mux5 & 6
  assign is_EX_use_rs1 = `IS_RS1_USED(EX_opcode);
  assign is_EX_use_rs2 = `IS_RS2_USED(EX_opcode);
  assign EX_alu_op1_sel = `USES_RS1_AS_ALU_OP1(EX_opcode) ? 1'd1 : 1'd0; // 1:rs1, 0:pc
  assign EX_alu_op2_sel = `USES_RS2_AS_ALU_OP2(EX_opcode) ? 1'd1 : 1'd0; // 1:rs2, 0:imm

  always_comb begin
    unique case (EX_opcode)
      `JAL_OPCODE, `JALR_OPCODE: jb_flush = 1'd1; // J jal, I jalr
      `BRANCH_OPCODE: jb_flush = EX_alu_res[0]; // B
      default: jb_flush = 1'd0;
    endcase
  end

//---------------------------------MEM stage---------------------------------
  assign is_MEM_use_rd = `IS_RD_USED(MEM_opcode);
//---------------------------------WB stage---------------------------------
  always_comb begin
    unique case (WB_opcode) //Write rd
      `LUI_OPCODE,                     // U lui
      `AUIPC_OPCODE,                   // U auipc
      `JAL_OPCODE,                     // J jal
      `JALR_OPCODE,                    // I jalr
      `LOAD_OPCODE,                    // I load
      `ITYPE_OPCODE,                   // I 
      `RTYPE_OPCODE,                   // R
      `SYSTEM_OPCODE: WB_wb_en = 1'd1; // CSR
      default:  WB_wb_en = 1'd0; 
    endcase
  end

  // stall: 在ID stage發現前一條指令才剛發load inst，但我等下EX就要用
  assign is_ID_rs1_EX_rd_overlap = is_ID_use_rs1 && (ID_rs1_idx == EX_rd_idx);
  assign is_ID_rs2_EX_rd_overlap = is_ID_use_rs2 && (ID_rs2_idx == EX_rd_idx);
  assign is_IDEX_overlap = is_ID_rs1_EX_rd_overlap || is_ID_rs2_EX_rd_overlap;
  assign stall = (EX_opcode == `LOAD_OPCODE) && is_IDEX_overlap && (EX_rd_idx != 0);
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      last_stall <= 1'b0;
      last_jb_flush <= 1'b0;
    end else begin
      last_stall <= stall;
      last_jb_flush <= jb_flush;
    end
  end
  // Mux1 & 2 (Forward WB data)
  assign is_ID_rs1_WB_rd_overlap = is_ID_use_rs1 && (ID_rs1_idx == WB_rd_idx); 
  assign is_ID_rs2_WB_rd_overlap = is_ID_use_rs2 && (ID_rs2_idx == WB_rd_idx);
  assign ID_rs1_data_sel = is_ID_rs1_WB_rd_overlap && WB_wb_en && (WB_rd_idx != 0);
  assign ID_rs2_data_sel = is_ID_rs2_WB_rd_overlap && WB_wb_en && (WB_rd_idx != 0);
  // Mux3 & 4 (Forward MEM or WB), priority: csr > MEM > WB
  assign is_EX_rs1_WB_rd_overlap = is_EX_use_rs1 && WB_wb_en && (EX_rs1_idx == WB_rd_idx) && (WB_rd_idx != 0);
  assign is_EX_rs1_MEM_rd_overlap = is_EX_use_rs1 && is_MEM_use_rd && (EX_rs1_idx == MEM_rd_idx) && (MEM_rd_idx != 0);
  assign is_EX_rs2_WB_rd_overlap = is_EX_use_rs2 && WB_wb_en && (EX_rs2_idx == WB_rd_idx) && (WB_rd_idx != 0);
  assign is_EX_rs2_MEM_rd_overlap = is_EX_use_rs2 && is_MEM_use_rd && (EX_rs2_idx == MEM_rd_idx) && (MEM_rd_idx != 0);
  assign EX_rs1_data_sel = is_EX_rs1_MEM_rd_overlap ? 2'd0 : 
                           is_EX_rs1_WB_rd_overlap ? 2'd1 : 2'd2;
  assign EX_rs2_data_sel = is_EX_rs2_MEM_rd_overlap ? 2'd0 : 
                           is_EX_rs2_WB_rd_overlap ? 2'd1 : 2'd2;
  //mux 7
  assign EX_jb_op1_sel = (EX_opcode == `JALR_OPCODE);
  //mux 8
  assign WB_wb_data_sel = (WB_opcode == `LOAD_OPCODE);
endmodule
