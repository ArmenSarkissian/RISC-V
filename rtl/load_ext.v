module load_ext (
    input  wire [31:0] raw_data,
    input  wire [2:0]  funct3,
    input  wire [1:0]  byte_offset,
    output reg  [31:0] load_data
);
    reg [7:0]  selected_byte;
    reg [15:0] selected_half;

    always @(*) begin
        // Select byte lane based on address bits [1:0]
        case (byte_offset)
            2'b00:   selected_byte = raw_data[7:0];
            2'b01:   selected_byte = raw_data[15:8];
            2'b10:   selected_byte = raw_data[23:16];
            2'b11:   selected_byte = raw_data[31:24];
        endcase

        // Select halfword lane based on address bit [1]
        selected_half = byte_offset[1] ? raw_data[31:16] : raw_data[15:0];

        // Apply Sign or Zero extension according to opcode funct3
        case (funct3)
            3'b000:  load_data = {{24{selected_byte[7]}}, selected_byte}; // LB (Sign-Extended)
            3'b001:  load_data = {{16{selected_half[15]}}, selected_half}; // LH (Sign-Extended)
            3'b010:  load_data = raw_data;                                 // LW (Full Word)
            3'b100:  load_data = {24'b0, selected_byte};                  // LBU (Zero-Extended)
            3'b101:  load_data = {16'b0, selected_half};                  // LHU (Zero-Extended)
            default: load_data = raw_data;
        endcase
    end
endmodule