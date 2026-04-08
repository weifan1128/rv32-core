`include "CPU_def.svh"
module CSR_unit (
  input clk,
  input rst,
  input [ 4:0] EX_opcode,
  input [ 2:0] EX_func3,
  input [ 6:0] EX_func7,
  input [ 4:0] EX_rs1_idx,
  input [ 4:0] EX_rs2_idx,
  input [ 4:0] EX_rd_idx,
  input [11:0] EX_csr_addr,
  output logic [31:0] EX_csr_res
);
  logic [63:0] cycle;
  logic [63:0] instret;
  logic nop;
  assign nop = EX_opcode == 5'd4 && EX_func3 == 3'd0 && EX_func7 == 7'd0 && EX_rs1_idx == 5'd0 && EX_rs2_idx == 5'd0 && EX_rd_idx == 5'd0;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle <= 64'd0;
    end else begin
      cycle <= cycle + 64'b1;
    end
  end

  always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
        instret <= 64'hffff_ffff_ffff_ffff;
      end else if(!nop) begin
        instret <= instret + 64'd1;
      end
  end

  always_comb begin
    if (EX_opcode == `SYSTEM_OPCODE) begin
      case (EX_csr_addr)
        `CSR_MCYCLE:    EX_csr_res = cycle[31:0];    // cycle
        `CSR_MCYCLEH:   EX_csr_res = cycle[63:32];   // cycleh
        `CSR_MINSTRET:  EX_csr_res = instret[31:0];  // instret
        `CSR_MINSTRETH: EX_csr_res = instret[63:32]; // instreth
        default: EX_csr_res = 32'd0;
      endcase
    end else begin
      EX_csr_res = 32'b0;
    end
  end

endmodule