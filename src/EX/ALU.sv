/*
* RISC-V Base Integer Arithmetic & Logic Operations:
* -----------------------------------------------------------------------------
* | func3 | Instruction | Operation           | Description                   |
* |-------|-------------|---------------------|-------------------------------|
* | 000   | ADD / SUB   | op1 +/- op2         | Addition or Subtraction       |
* | 001   | SLL         | op1 << op2[4:0]     | Shift Left Logical            |
* | 010   | SLT         | op1 < op2 (S)       | Set Less Than (Signed)        |
* | 011   | SLTU        | op1 < op2 (U)       | Set Less Than (Unsigned)      |
* | 100   | XOR         | op1 ^ op2           | Bitwise XOR                   |
* | 101   | SRL / SRA   | op1 >> op2[4:0]     | Shift Right (Logical/Arith)   |
* | 110   | OR          | op1 | op2           | Bitwise OR                    |
* | 111   | AND         | op1 & op2           | Bitwise AND                   |
* -----------------------------------------------------------------------------
* RISC-V Branch Comparison Operations:
* -----------------------------------------------------------------------------
* | func3 | Instruction | Condition           | ALU Output (1 if True)        |
* |-------|-------------|---------------------|-------------------------------|
* | 000   | BEQ         | op1 == op2          | Equality Check                |
* | 001   | BNE         | op1 != op2          | Inequality Check              |
* | 100   | BLT         | op1 < op2 (S)       | Signed Less Than              |
* | 101   | BGE         | op1 >= op2 (S)      | Signed Greater Than or Equal  |
* | 110   | BLTU        | op1 < op2 (U)       | Unsigned Less Than            |
* | 111   | BGEU        | op1 >= op2 (U)      | Unsigned Greater Than or Equal|
* -----------------------------------------------------------------------------
* RISC-V M-Extension Multiplier Operations:
* -------------------------------------------------------------------------------
* | func3 | Instruction | Description         | Result Part   | Signedness      |
* |-------|-------------|---------------------|---------------|-----------------|
* | 000   | MUL         | Lower 32-bits       | EX_mul_res[31:0] | S * S / U * U   |
* | 001   | MULH        | Upper 32-bits       | EX_mul_res[63:32]| Signed * Signed |
* | 010   | MULHSU      | Upper (Mixed)       | EX_mul_res[63:32]| Signed * Unsig. |
* | 011   | MULHU       | Upper 32-bits       | EX_mul_res[63:32]| Unsig. * Unsig. |
* -------------------------------------------------------------------------------
* RISC-V Memory Address and Immediate Calculations:
* -----------------------------------------------------------------------------
* | Opcode  | Type  | Instruction | Operation       | Description             |
* |---------|-------|-------------|-----------------|-------------------------|
* | 00000   | I     | LB/LH/LW    | op1 + op2 (imm) | Load Address Calc       |
* | 01000   | S     | SB/SH/SW    | op1 + op2 (imm) | Store Address Calc      |
* | 00101   | U     | AUIPC       | PC + imm        | Add Upper Imm to PC     |
* | 01101   | U     | LUI         | 0 + imm         | Load Upper Immediate    |
* | 11011   | J     | JAL         | PC + imm        | Jump and Link Address   |
* | 11001   | I     | JALR        | op1 + imm       | Jump and Link Register  |
* -----------------------------------------------------------------------------
*/
`include "CPU_def.svh"
module ALU (
  input  [ 4:0] EX_opcode,
  input  [ 2:0] EX_func3,
  input  [ 6:0] EX_func7,
  input  [31:0] EX_alu_op1,
  input  [31:0] EX_alu_op2,
  input  [63:0] EX_mul_res,
  input  [31:0] EX_csr_res,
  output logic [31:0] EX_alu_res
);
  logic is_sub;
  logic [31:0] add_sub_res;
  logic [31:0] shift_res;
  logic [31:0] logic_res;
  logic [31:0] EX_alu_op2_or_4;

  // assign is_sub = (EX_opcode == `RTYPE_OPCODE && EX_func7[5]) || (EX_opcode == `BRANCH_OPCODE) || (EX_func3 == 3'b010) || (EX_func3 == 3'b011);
  assign is_sub = EX_opcode == `RTYPE_OPCODE && EX_func3 == 3'b000 && EX_func7[5];

  // add_sub_res
  assign EX_alu_op2_or_4 = (EX_opcode == `JAL_OPCODE || EX_opcode == `JALR_OPCODE) ? 32'd4 : EX_alu_op2;
  assign add_sub_res = is_sub ? (EX_alu_op1 - EX_alu_op2_or_4) : (EX_alu_op1 + EX_alu_op2_or_4);
  // shift_res
  always_comb begin
    case(EX_func3)
      3'b001: shift_res = EX_alu_op1 << EX_alu_op2[4:0]; // SLL
      3'b101: shift_res = (EX_func7[5]) ? $signed($signed(EX_alu_op1) >>> EX_alu_op2[4:0]) : (EX_alu_op1 >> EX_alu_op2[4:0]); // SRA/SRL
      default: shift_res = 32'b0;
    endcase
  end
  // logic_res
  always_comb begin
    case(EX_func3)
      3'b100: logic_res = EX_alu_op1 ^ EX_alu_op2; // XOR
      3'b110: logic_res = EX_alu_op1 | EX_alu_op2; // OR
      3'b111: logic_res = EX_alu_op1 & EX_alu_op2; // AND
      default: logic_res = 32'b0;
    endcase
  end
  // EX_alu_res 
  always_comb begin
    case(EX_opcode)
      `RTYPE_OPCODE: begin // R-type
        if (EX_func7[0]) begin // M-extension
          EX_alu_res = (EX_func3 == 3'b000) ? EX_mul_res[31:0] : EX_mul_res[63:32];
        end else begin
          case(EX_func3)
            3'b000:  EX_alu_res = add_sub_res;
            3'b001, 3'b101: EX_alu_res = shift_res;
            3'b010:  EX_alu_res = {31'b0, $signed(EX_alu_op1) < $signed(EX_alu_op2)};
            3'b011:  EX_alu_res = {31'b0, EX_alu_op1 < EX_alu_op2};
            default: EX_alu_res = logic_res;
          endcase
        end
      end
      
      `ITYPE_OPCODE: begin // I-type
        case(EX_func3)
          3'b000:  EX_alu_res = add_sub_res;
          3'b001, 3'b101: EX_alu_res = shift_res;
          3'b010:  EX_alu_res = {31'b0, $signed(EX_alu_op1) < $signed(EX_alu_op2)};
          3'b011:  EX_alu_res = {31'b0, EX_alu_op1 < EX_alu_op2};
          default: EX_alu_res = logic_res;
        endcase
      end

      `BRANCH_OPCODE: begin // B-type
        case(EX_func3)
          3'b000: EX_alu_res = {31'b0, EX_alu_op1 == EX_alu_op2};
          3'b001: EX_alu_res = {31'b0, EX_alu_op1 != EX_alu_op2};
          3'b100: EX_alu_res = {31'b0, $signed(EX_alu_op1) < $signed(EX_alu_op2)};
          3'b101: EX_alu_res = {31'b0, $signed(EX_alu_op1) >= $signed(EX_alu_op2)};
          3'b110: EX_alu_res = {31'b0, EX_alu_op1 < EX_alu_op2};
          3'b111: EX_alu_res = {31'b0, EX_alu_op1 >= EX_alu_op2};
          default: EX_alu_res = 32'b0;
        endcase
      end

      `LOAD_OPCODE, `STORE_OPCODE, `AUIPC_OPCODE: EX_alu_res = add_sub_res; // Load, Store, AUIPC
      `LUI_OPCODE: EX_alu_res = EX_alu_op2;    // LUI
      `JALR_OPCODE, `JAL_OPCODE: EX_alu_res = add_sub_res; // JAL, JALR
      `SYSTEM_OPCODE: EX_alu_res = EX_csr_res; //csr
      default:  EX_alu_res = 32'b0;
    endcase
  end

endmodule
