module LD_align_unit (
  input [31:0] WB_dm_data_in,
  input [ 1:0] WB_ld_addr_l2b, // ld_addr last 2 bits
  input [ 2:0] WB_func3,
  output logic [31:0] WB_dm_data_out
);

  logic [31:0] shifted_data;
  logic [ 7:0] byte_data;
  logic [15:0] half_data;

  assign shifted_data = WB_dm_data_in >> {WB_ld_addr_l2b, 3'd0};
  assign byte_data = shifted_data[ 7:0];
  assign half_data = shifted_data[15:0];

  always_comb begin
    unique case (WB_func3)
      3'b000: WB_dm_data_out = {{24{byte_data[ 7]}}, byte_data};// LB
      3'b001: WB_dm_data_out = {{16{half_data[15]}}, half_data};// LH
      3'b010: WB_dm_data_out = shifted_data;                    // LW
      3'b100: WB_dm_data_out = {24'd0, byte_data};              // LBU
      3'b101: WB_dm_data_out = {16'd0, half_data};              // LHU
      default: WB_dm_data_out = shifted_data;
    endcase
  end

endmodule
