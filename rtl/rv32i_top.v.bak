//Top-Level RISC-V Wrapper

module rv32i_top (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] pc_out,
    output wire [31:0] alu_result_out
);
    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] inst;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] rd_data;
    wire [31:0] imm_ext;
    wire [31:0] alu_in_a;
    wire [31:0] alu_in_b;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;

    wire        branch;
    wire        mem_read;
    wire [1:0]  mem_to_reg;
    wire [1:0]  alu_op;
    wire        mem_write;
    wire        alu_src;
    wire        reg_write;
    wire        jal;
    wire        jalr;
    wire        auipc;
    wire [3:0]  alu_ctrl;

    wire        zero;
    wire        lt;
    wire        ltu;

    assign pc_out         = pc;
    assign alu_result_out = alu_result;

    // Address calculations
    wire [31:0] pc_plus_4    = pc + 32'd4;
    wire [31:0] branch_target = pc + imm_ext;
    wire [31:0] jalr_target   = (rs1_data + imm_ext) & ~32'h1;

    // Branch condition evaluation
    wire [2:0] funct3 = inst[14:12];
    reg take_branch;
    always @(*) begin
        case (funct3)
            3'b000:  take_branch = zero;   // BEQ
            3'b001:  take_branch = ~zero;  // BNE
            3'b100:  take_branch = lt;     // BLT
            3'b101:  take_branch = ~lt;    // BGE
            3'b110:  take_branch = ltu;    // BLTU
            3'b111:  take_branch = ~ltu;   // BGEU
            default: take_branch = 1'b0;
        endcase
    end

    // Next PC selection logic
    assign next_pc = jalr ? jalr_target :
                     (jal || (branch && take_branch)) ? branch_target :
                     pc_plus_4;

    pc_reg pc_unit (
        .clk     (clk),
        .rst_n   (rst_n),
        .next_pc (next_pc),
        .pc      (pc)
    );

    instruction_mem #(
        .ADDR_WIDTH (10),
        .MEM_SIZE   (1024)
    ) imem (
        .clk  (clk),
        .addr (pc[11:2]),
        .inst (inst)
    );

    control_unit control (
        .opcode     (inst[6:0]),
        .branch     (branch),
        .mem_read   (mem_read),
        .mem_to_reg (mem_to_reg),
        .alu_op     (alu_op),
        .mem_write  (mem_write),
        .alu_src    (alu_src),
        .reg_write  (reg_write),
        .jal        (jal),
        .jalr       (jalr),
        .auipc      (auipc)
    );

    reg_file rf (
        .clk       (clk),
        .reg_write (reg_write),
        .rs1_addr  (inst[19:15]),
        .rs2_addr  (inst[24:20]),
        .rd_addr   (inst[11:7]),
        .rd_data   (rd_data),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    imm_gen imm_unit (
        .inst    (inst),
        .imm_ext (imm_ext)
    );

    wire is_rtype = (inst[6:0] == 7'b0110011);
    alu_control alu_ctrl_unit (
        .alu_op   (alu_op),
        .funct3   (funct3),
        .funct7_5 (inst[30]),
        .is_rtype (is_rtype),
        .alu_ctrl (alu_ctrl)
    );

    assign alu_in_a = auipc ? pc : rs1_data;
    assign alu_in_b = alu_src ? imm_ext : rs2_data;

    alu alu_unit (
        .a        (alu_in_a),
        .b        (alu_in_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (zero),
        .lt       (lt),
        .ltu      (ltu)
    );

    data_mem #(
        .ADDR_WIDTH (10),
        .MEM_SIZE   (1024)
    ) dmem (
        .clk        (clk),
        .mem_write  (mem_write),
        .mem_read   (mem_read),
        .addr       (alu_result[11:2]),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );

    assign rd_data = (mem_to_reg == 2'b01) ? mem_read_data :
                     (mem_to_reg == 2'b10) ? pc_plus_4 :
                     alu_result;

endmodule