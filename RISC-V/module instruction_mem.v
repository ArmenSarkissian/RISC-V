//Instruction Memory
module instruction_mem #(
    parameter ADDR_WIDTH = 10,
    parameter MEM_SIZE   = 1024
)(
    input  wire                  clk,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [31:0]           inst
);
    // Quartus infers M9K/M10K embedded memory blocks via single-clock synchronous read
    (* ram_init_file = "program.hex" *) reg [31:0] mem [0:MEM_SIZE-1];

    initial begin
        $readmemh("program.hex", mem);
    end

    always @(posedge clk) begin
        inst <= mem[addr];
    end
endmodule

