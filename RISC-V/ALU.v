//Arithmatic Logic Unit

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero,
    output wire        lt,
    output wire        ltu
);
    assign zero = (a == b);
    assign lt   = ($signed(a) < $signed(b));
    assign ltu  = (a < b);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;                 // ADD
            4'b0001: result = a - b;                 // SUB
            4'b0010: result = a << b[4:0];           // SLL
            4'b0011: result = {31'b0, lt};           // SLT
            4'b0100: result = {31'b0, ltu};          // SLTU
            4'b0101: result = a ^ b;                 // XOR
            4'b0110: result = a >> b[4:0];           // SRL
            4'b0111: result = $signed(a) >>> b[4:0]; // SRA
            4'b1000: result = a | b;                 // OR
            4'b1001: result = a & b;                 // AND
            4'b1010: result = b;                     // PASS B
            default: result = 32'b0;
        endcase
    end
endmodule
