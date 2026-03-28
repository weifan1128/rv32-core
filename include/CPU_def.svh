`ifndef CPU_DEF_SVH
`define CPU_DEF_SVH

// =================================================================
// Constants
// =================================================================
`define RV_NOP        32'h0000_0013
`define ADDR_WIDTH    32
`define DATA_WIDTH    32

// =================================================================
// standard Opcode
// =================================================================
// FIX RISC-V opcode[1:0] = 2'b11
`define LUI_OPCODE      5'b01101
`define AUIPC_OPCODE    5'b00101
`define JAL_OPCODE      5'b11011
`define JALR_OPCODE     5'b11001
`define BRANCH_OPCODE   5'b11000
`define LOAD_OPCODE     5'b00000
`define STORE_OPCODE    5'b01000
`define ITYPE_OPCODE    5'b00100  // I-type arithmetic
`define RTYPE_OPCODE    5'b01100  // R-type arithmetic
`define SYSTEM_OPCODE   5'b11100  // CSR instructions & MRET
// =================================================================
// Instruction Attribute Macros (Decode logic)
// =================================================================

`define IS_RS1_USED(op) \
    ((op == `JALR_OPCODE)   || \
     (op == `BRANCH_OPCODE) || \
     (op == `LOAD_OPCODE)   || \
     (op == `STORE_OPCODE)  || \
     (op == `ITYPE_OPCODE)  || \
     (op == `RTYPE_OPCODE)  || \
     (op == `SYSTEM_OPCODE))

`define IS_RS2_USED(op) \
    ((op == `BRANCH_OPCODE) || \
     (op == `STORE_OPCODE)  || \
     (op == `RTYPE_OPCODE))

`define IS_RD_USED(op) \
    ((op == `LUI_OPCODE)    || \
     (op == `AUIPC_OPCODE)  || \
     (op == `JAL_OPCODE)    || \
     (op == `JALR_OPCODE)   || \
     (op == `LOAD_OPCODE)   || \
     (op == `ITYPE_OPCODE)  || \
     (op == `RTYPE_OPCODE)  || \
     (op == `SYSTEM_OPCODE))
// =================================================================
// CSR Addresses
// =================================================================
`define CSR_MSTATUS     12'h300
`define CSR_MIE         12'h304
`define CSR_MTVEC       12'h305
`define CSR_MEPC        12'h341
`define CSR_MIP         12'h344
`define CSR_MCYCLE      12'hc00
`define CSR_MINSTRET    12'hc02
`define CSR_MCYCLEH     12'hc80
`define CSR_MINSTRETH   12'hc82

// =================================================================
// CSR Func3
// =================================================================
`define CSR_RW          3'b001
`define CSR_RS          3'b010
`define CSR_RC          3'b011
`define CSR_RWI         3'b101
`define CSR_RSI         3'b110
`define CSR_RCI         3'b111

// =================================================================
// Full Instruction Encoding
// =================================================================
// MRET: {funct7, rs2, rs1, funct3, rd, opcode[6:2]}
`define MRET_INST_BITS  30'b0011000_00010_00000_000_00000_11100

`endif // CPU_DEF_SVH