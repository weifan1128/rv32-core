`include "CPU_def.svh"
module ST_align_unit (
  input [ 4:0] MEM_opcode,
  input [ 2:0] MEM_func3,
  input [ 1:0] MEM_addr_offset,
  input [31:0] MEM_rs2_data,
  output logic [3:0]  MEM_dm_w_en,
  output logic [31:0] MEM_dm_st_data
);

  always_comb begin
    case (MEM_addr_offset)
      2'b00: MEM_dm_st_data = MEM_rs2_data;
      2'b01: MEM_dm_st_data = {MEM_rs2_data[23:0], 8'b0};
      2'b10: MEM_dm_st_data = {MEM_rs2_data[15:0], 16'b0};
      2'b11: MEM_dm_st_data = {MEM_rs2_data[7:0], 24'b0};
      default: MEM_dm_st_data = MEM_rs2_data;
    endcase
  end

  always_comb begin
    if (MEM_opcode == `STORE_OPCODE) begin
      case (MEM_func3)
        3'b000:  MEM_dm_w_en = ~(4'b0001 << MEM_addr_offset); // SB:
        3'b001:  MEM_dm_w_en = (MEM_addr_offset == 2'd0) ? 4'b1100 : 4'b0011; // SH
        3'b010:  MEM_dm_w_en = 4'b0000;                    // SW
        default: MEM_dm_w_en = 4'b1111;
      endcase
    end else begin
      MEM_dm_w_en = 4'b1111;
    end
  end

endmodule