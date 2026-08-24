//program counter

module pc_reg(
	input wire 	clk,
	input wire	rst_n,
	input wire [31:0} next_pc, 
	output reg [31:0] pc
);

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		pc <= 32'h00000000;
		
	else 
		pc <= next_pc;

	end
endmodule
