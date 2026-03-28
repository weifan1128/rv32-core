/*
* RISC-V M-Extension Multiplier Operations:
* -------------------------------------------------------------------------
* | func3 | Instruction | Description         | Op1 Type | Op2 Type |
* |-------|-------------|---------------------|----------|----------|
* | 000   | MUL         | Lower 32-bits       | Signed   | Signed   |
* | 001   | MULH        | Upper 32-bits       | Signed   | Signed   |
* | 010   | MULHSU      | Upper (Mixed)       | Signed   | Unsigned |
* | 011   | MULHU       | Upper 32-bits       | Unsigned | Unsigned |
* -------------------------------------------------------------------------
*/
module Multiplier (
  input  [31:0] mul_op1,
  input  [31:0] mul_op2,
  input  [ 2:0] EX_func3,
  output logic [63:0] EX_mul_res
);
  logic        op1_unsigned, op2_unsigned;
  logic [63:0] op1_ext, op2_ext;
  // Define signed/unsigned behavior based on func3
  assign op1_unsigned = (EX_func3 == 3'b011);                    // Only MULHU is unsigned for Op1
  assign op2_unsigned = (EX_func3 == 3'b010 || EX_func3 == 3'b011); // MULHSU and MULHU are unsigned for Op2

  // Sign extension or Zero extension (32-bit to 33-bit)
  // We add 1 extra bit to handle the sign bit during the multiplication process
  assign op1_ext = op1_unsigned ? {32'd0, mul_op1} : {{32{mul_op1[31]}}, mul_op1};
  assign op2_ext = op2_unsigned ? {32'd0, mul_op2} : {{32{mul_op2[31]}}, mul_op2};

  // 33-bit * 33-bit multiplication yields a 66-bit result (truncated to 64-bit here)
  assign EX_mul_res = op1_ext * op2_ext;

endmodule
