`include "./SRAM_wrapper.sv"
`include "./CPU/CPU.sv"

module top (
  input clk,
  input rst
);

logic [ 3:0] MEM_dm_w_en;
logic [31:0] MEM_alu_mul_res;
logic [31:0] MEM_dm_st_data;
logic [31:0] dm_ld_data;
logic [31:0] ID_inst;
logic [31:0] IF_pc;

CPU CPU(
  .clk(clk),
  .rst(rst), 
  .ID_inst(ID_inst),    
  .dm_ld_data(dm_ld_data),  

  .IF_pc(IF_pc), 
  .MEM_dm_w_en(MEM_dm_w_en),  
  .MEM_alu_mul_res(MEM_alu_mul_res),  
  .MEM_dm_st_data(MEM_dm_st_data)  
);

SRAM_wrapper IM1(
  .CK(clk),
  .CS(1'b1),
  .OE(1'b1),
  .WEB(4'b1111),
  .A(IF_pc[15:2]),  
  .DI(),
  .DO(ID_inst)  
);
SRAM_wrapper DM1(
  .CK(clk),  
  .CS(1'b1),  
  .OE(1'b1),  
  .WEB(MEM_dm_w_en), 
  .A(MEM_alu_mul_res[15:2]),  
  .DI(MEM_dm_st_data),  
  .DO(dm_ld_data)   
);

endmodule