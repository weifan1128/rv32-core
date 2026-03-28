module rst_buff(
	input clk,
	input rst,
	output logic rst_buff
);
	logic rst_reg;
	
	always_ff @(posedge clk) begin
		rst_reg <= rst;
		rst_buff <= rst || rst_reg;
	end
endmodule
