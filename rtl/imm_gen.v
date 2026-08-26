//Immediate Generator 

module imm_gen (
    input  wire [31:0] inst,
    output reg  [31:0] imm_ext
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            7'b0010011, // I-type ALU
            7'b0000011, // I-type Load
            7'b1100111: // JALR
                imm_ext = {{20{inst[31]}}, inst[31:20]};

            7'b0100011: // S-type Store
                imm_ext = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            7'b1100011: // B-type Branch
                imm_ext = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};

            7'b0110111, // U-type LUI
            7'b0010111: // U-type AUIPC
                imm_ext = {inst[31:12], 12'b0};

            7'b1101111: // J-type JAL
                imm_ext = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

            default:
                imm_ext = 32'b0;
        endcase
    end
endmodule