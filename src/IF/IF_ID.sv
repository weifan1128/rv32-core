`include "CPU_def.svh"
module IF_ID (
  input clk,
  input rst,
  input stall,
  input last_stall,
  input jb_flush,
  input [31:0] IF_jb_pc,
  input [31:0] IF_pc,
  input [31:0] ID_inst, // store last inst to handle stall sig
  output logic [31:0] ID_pc,
  output logic [31:0] ID_true_inst
);
  logic [31:0] last_inst;
  assign ID_true_inst = (last_stall)? last_inst :
                        (jb_flush) ? `RV_NOP : ID_inst;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      ID_pc <= 32'd0;  
      last_inst <= `RV_NOP;  
    end 
    else begin
      ID_pc <= (stall) ? ID_pc : 
               (jb_flush) ? IF_jb_pc : IF_pc;  
      last_inst <= ID_true_inst;
    end
  end

endmodule