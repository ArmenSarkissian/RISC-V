//Data Memory

module data_mem #(
    parameter ADDR_WIDTH = 10,
    parameter MEM_SIZE   = 1024
)(
    input  wire                  clk,
    input  wire                  mem_write,
    input  wire                  mem_read,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [31:0]           write_data,
    output reg  [31:0]           read_data
);
    // Standard RAM inference pattern for Intel Quartus synthesis
    reg [31:0] mem [0:MEM_SIZE-1];

    always @(posedge clk) begin
        if (mem_write) begin
            mem[addr] <= write_data;
        end
        if (mem_read) begin
            read_data <= mem[addr];
        end
    end
endmodule