module JB_Unit (
  input  [31:0] jb_op1,
  input  [31:0] jb_op2,
  input  jb_flush,
  output logic [31:0] IF_jb_pc
);
  logic [31:0] jb_res;
  // Merge pc sel here
  logic [31:0] jb_op2_or_4;

  assign jb_op2_or_4 = (jb_flush)? jb_op2 : 32'd4;
  assign jb_res = jb_op1 + jb_op2_or_4;
  assign IF_jb_pc = {jb_res[31:1], 1'b0};

endmodule
