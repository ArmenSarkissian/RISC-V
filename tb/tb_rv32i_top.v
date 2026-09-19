`timescale 1ns / 1ps

module tb_rv32i_top;

    // Testbench Signals
    reg        clk;
    reg        rst_n;
    wire [31:0] pc_out;
    wire [31:0] alu_result_out;

    // Instantiate Top-Level Core (DUT)
    rv32i_top uut (
        .clk            (clk),
        .rst_n          (rst_n),
        .pc_out         (pc_out),
        .alu_result_out (alu_result_out)
    );

    // Clock Generation (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk   = 0;
        rst_n = 0;

        // Preload Machine Code Program into Instruction Memory
        // Ensure 'program.hex' is placed in your ModelSim working directory
        $readmemh("program.hex", uut.imem.mem);

        // Hold Reset Low for 20ns
        #20;
        rst_n = 1;

        // Monitor PC, ALU Output, and Registers in ModelSim Console
        $display("\n--- Starting RV32I Processor Core Simulation ---");
        $monitor("Time=%0t ns | PC=0x%h | ALU_Out=0x%h | x1=0x%h | x2=0x%h | x3=0x%h",
                 $time, pc_out, alu_result_out, 
                 uut.rf.rf[1], uut.rf.rf[2], uut.rf.rf[3]);

        // Run simulation for 200ns
        #200;
        $display("--- Simulation Completed Successfully ---");
        $finish;
    end
// Helper task for automated checking
    task check_reg;
        input [4:0]  reg_num;
        input [31:0] expected;
        input [128:0] test_name;
        begin
            if (uut.rf.rf[reg_num] === expected) begin
                $display("[PASS] %-15s | x%0d = 0x%h", test_name, reg_num, expected);
            end else begin
                $display("[FAIL] %-15s | x%0d = 0x%h (Expected: 0x%h)", 
                          test_name, reg_num, uut.rf.rf[reg_num], expected);
            end
        end
    endtask

    // Execution sequence check
    initial begin
        clk = 0; rst_n = 0;
        $readmemh("program.hex", uut.imem.mem);
        #20; rst_n = 1;

        // Run cycles to allow program execution
        #100;

        // Validate final state values
        $display("\n--- CORE VERIFICATION RESULTS ---");
        check_reg(1, 32'h00000005, "ADDI Verification");
        check_reg(2, 32'h0000000a, "ADDI Verification");
        check_reg(3, 32'h0000000f, "ADD Verification");
        check_reg(4, 32'h0000000f, "SW / LW Load Check");
        $finish;
    end
endmodule