// Register File 

module reg_file (
    input  wire        clk,
    input  wire        reg_write,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);
    reg [31:0] rf [31:1];

    // Asynchronous read; register x0 hardwired to constant zero
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : rf[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : rf[rs2_addr];

    // Synchronous write
    always @(posedge clk) begin
        if (reg_write && (rd_addr != 5'b0)) begin
            rf[rd_addr] <= rd_data;
        end
    end
endmodule