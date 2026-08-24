//ALU Control Decoder

module alu_control (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7_5,
    input  wire       is_rtype,
    output reg  [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; // ADD (Load, Store, AUIPC)
            2'b01: alu_ctrl = 4'b0001; // SUB (Branch comparison)
            2'b11: alu_ctrl = 4'b1010; // PASS B (LUI)
            2'b10: begin               // R-type / I-type
                case (funct3)
                    3'b000:  alu_ctrl = (funct7_5 && is_rtype) ? 4'b0001 : 4'b0000; // SUB or ADD
                    3'b001:  alu_ctrl = 4'b0010; // SLL
                    3'b010:  alu_ctrl = 4'b0011; // SLT
                    3'b011:  alu_ctrl = 4'b0100; // SLTU
                    3'b100:  alu_ctrl = 4'b0101; // XOR
                    3'b101:  alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110; // SRA or SRL
                    3'b110:  alu_ctrl = 4'b1000; // OR
                    3'b111:  alu_ctrl = 4'b1001; // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule
