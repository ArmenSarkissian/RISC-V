	//Data Memory

module data_mem #(
    parameter ADDR_WIDTH = 10,
    parameter MEM_SIZE   = 1024
)(
    input  wire                  clk,
    input  wire                  mem_write,
    input  wire [3:0]            byte_enable,
    input  wire [31:0] 				addr,
    input  wire [31:0]           write_data,
    output reg  [31:0]           read_data
);
    // Standard RAM inference pattern for Intel Quartus synthesis
    reg [31:0] mem [0:MEM_SIZE-1];
	 reg[31:0]	ram_data;
	 
	 wire[9:0] word_addr = addr[11:2];

    always @(posedge clk) begin
        if (mem_write) begin
				if (byte_enable[0]) ram[word_addr][ 7: 0] <= write_data[ 7: 0];
            if (byte_enable[1]) ram[word_addr][15: 8] <= write_data[15: 8];
            if (byte_enable[2]) ram[word_addr][23:16] <= write_data[23:16];
            if (byte_enable[3]) ram[word_addr][31:24] <= write_data[31:24];
        end
        ram_data <= ram[word_addr]; 
	end

    assign read_data=  ram_data;
endmodule: