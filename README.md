# RV32I Single-Cycle RISC-V Processor Core

[![Language: Verilog-2001](https://img.shields.io/badge/Language-Verilog--2001-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![ISA: RV32I](https://img.shields.io/badge/ISA-RISC--V%20RV32I%20Base-red.svg)](https://riscv.org/)
[![Target: Intel FPGA](https://img.shields.io/badge/Target-Intel%20Quartus%20II%20%2F%20Prime-0071C5.svg)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/overview.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A fully functional, synthesizable **32-bit RISC-V (RV32I Base Integer)** single-cycle processor core implemented in IEEE 1364-2001 Verilog. Designed specifically for **Intel FPGAs** (Cyclone IV, Cyclone 10 LP, MAX 10, DE2-115) using **Intel Quartus II / Prime**, with hardware optimizations for inferring embedded **M9K / M10K Block RAM (BRAM)** modules.

---

## Table of Contents
- [Architecture Overview](#architecture-overview)
- [Key Features](#key-features)
- [Supported Instruction Set (RV32I)](#supported-instruction-set-rv32i)
- [Repository Structure](#repository-structure)
- [Module Descriptions](#module-descriptions)
- [Hardware Synthesis & Resource Metrics](#hardware-synthesis--resource-metrics)
- [Getting Started & Toolchain Guide](#getting-started--toolchain-guide)
  - [1. Prerequisites](#1-prerequisites)
  - [2. Simulation with Icarus Verilog & GTKWave](#2-simulation-with-icarus-verilog--gtkwave)
  - [3. Compiling C/Assembly Software](#3-compiling-cassembly-software)
  - [4. Intel Quartus II Synthesis & FPGA Placement](#4-intel-quartus-ii-synthesis--fpga-placement)
- [Verification & Testbench](#verification--testbench)
- [Roadmap & Future Enhancements](#roadmap--future-enhancements)
- [License & Contact](#license--contact)

---

## Architecture Overview

The core implements a single-cycle von Neumann architecture with dedicated, inferable Block RAM arrays for instruction and data storage. Every instruction completes in a single clock cycle, making the execution flow transparent and straightforward for architectural analysis.

```
                  +-------------------------------------------------------+
                  |                 RV32I DATAPATH OVERVIEW              |
                  +-------------------------------------------------------+

       +--------+      +---------------+      +---------------+
       |        |----->|  Instruction  |----->|   Control     |----[Control Signals]
  +--->| PC Reg |      |  Memory (ROM) |      |    Unit       |
  |    +--------+      +---------------+      +---------------+
  |        |                                          |
  |        +-------------------+                      v
  |                            |              +---------------+
  |                            +------------->| Register File |
  |                                           | (32 x 32-bit) |
  |                                           +---------------+
  |                                              |         |
  |                                       rs1_data     rs2_data
  |                                              |         |
  |                    +-----------+             v         v
  |                    | Immediate |---------> [MUX]     [MUX]
  |                    | Generator |             |         |
  |                    +-----------+             v         v
  |                                           +---------------+
  |                                           |      ALU      |
  |                                           +---------------+
  |                                                   |
  |                                                   v
  |                                           +---------------+
  |                                           |  Data Memory  |
  |                                           |    (BRAM)     |
  |                                           +---------------+
  |                                                   |
  +-------------------[Next PC Logic] <---------------+ (WB Data)
```

---

## Key Features

- **Standard Compliance**: 100% compliant with the unprivileged RISC-V ISA specification (RV32I Base Integer).
- **Intel FPGA BRAM Inference**: Written using Quartus-friendly single-port/dual-port RAM templates to guarantee automatic inference of embedded M9K/M10K memory blocks rather than consuming scarce Logic Elements (LEs).
- **Asynchronous Read, Synchronous Write Register File**: 32 general-purpose 32-bit registers with register `x0` strictly hardwired to zero.
- **Synthesizable Verilog-2001**: Clean, modular standard IEEE 1364-2001 source code with zero non-synthesizable constructs (except initial `$readmemh` for ROM preloading).
- **Flexible Branching & Jumping**: Complete support for conditional branches (`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`) and unconditional jumps (`JAL`, `JALR`).

---

## Supported Instruction Set (RV32I)

| Type | Format | Supported Instructions |
| :--- | :--- | :--- |
| **R-Type** | `[funct7\|rs2\|rs1\|funct3\|rd\|opcode]` | `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` |
| **I-Type** | `[imm[11:0]\|rs1\|funct3\|rd\|opcode]` | `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`, `LW`, `JALR` |
| **S-Type** | `[imm[11:5]\|rs2\|rs1\|funct3\|imm[4:0]\|opcode]` | `SW` |
| **B-Type** | `[imm[12\|10:5]\|rs2\|rs1\|funct3\|imm[4:1\|11]\|opcode]` | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| **U-Type** | `[imm[31:12]\|rd\|opcode]` | `LUI`, `AUIPC` |
| **J-Type** | `[imm[20\|10:1\|11\|19:12]\|rd\|opcode]` | `JAL` |

---

## Repository Structure

```
.
├── rtl/                        # Synthesizable Verilog HDL Source Files
│   ├── pc_reg.v                # Program Counter register module
│   ├── reg_file.v              # 32x32-bit register file (x0 = 0)
│   ├── imm_gen.v               # Immediate value extractor & sign extender
│   ├── control_unit.v          # Main opcode decoder & control signaller
│   ├── alu_control.v           # ALU operation decoder
│   ├── alu.v                   # 32-bit Arithmetic Logic Unit
│   ├── instruction_mem.v       # BRAM-inferable Instruction Memory (ROM)
│   ├── data_mem.v              # BRAM-inferable Data Memory (RAM)
│   └── rv32i_top.v             # Top-level datapath integration wrapper
├── tb/                         # Simulation Testbenches
│   ├── tb_rv32i_top.v          # Top-level processor testbench
│   └── program.hex             # Hexadecimal machine code loaded into ROM
├── sw/                         # Software & Toolchain Utilities
│   ├── main.c                  # Sample C program (e.g., Fibonacci, Sorting)
│   ├── link.ld                 # RISC-V GNU Linker Script
│   └── Makefile                # Software build script (GCC -> ELF -> HEX)
├── synth/                      # Intel Quartus Project Files
│   ├── rv32i_top.qpf           # Quartus Project File
│   ├── rv32i_top.qsf           # Quartus Settings & Pin Assignments
│   └── timing.sdc              # Synopsys Design Constraints for TimeQuest
├── LICENSE                     # MIT License
└── README.md                   # Project Documentation
```

---

## Module Descriptions

1. **`pc_reg.v`**: 32-bit Program Counter with active-low asynchronous reset (`rst_n`). Updates on `posedge clk`.
2. **`reg_file.v`**: Dual combinational read ports and single synchronous write port. Enforces `rf[0] = 0` continuously.
3. **`imm_gen.v`**: Extracts 12-bit, 20-bit, and asymmetric immediate fields from instructions and expands them to 32-bit signed values.
4. **`control_unit.v`**: Main decoder mapping 7-bit RISC-V opcodes to core internal control busses (`reg_write`, `alu_src`, `mem_read`, `mem_write`, `mem_to_reg`, `branch`, etc.).
5. **`alu_control.v`**: Combines `alu_op` from main control with `funct3` and `funct7[5]` fields to yield specific 4-bit ALU control codes.
6. **`alu.v`**: Performs arithmetic, logic, and comparison operations, asserting `zero`, `lt` (signed less-than), and `ltu` (unsigned less-than) flags.
7. **`instruction_mem.v`**: 1024 x 32-bit memory array initializing via `$readmemh("program.hex", mem)` and synthesized to FPGA M9K/M10K blocks via synchronous read address latching.
8. **`data_mem.v`**: 1024 x 32-bit single-clock synchronous read/write RAM array.
9. **`rv32i_top.v`**: Connects control paths, multiplexers, program counter updates, memory interfaces, and ALU operations.

---

## Hardware Synthesis & Resource Metrics

Synthesized using **Intel Quartus Prime Lite Edition v21.1** targeting an **Intel Cyclone IV E (EP4CE115F29C7)** FPGA:

| Metric | Measured Value | Device Limit | Utilization |
| :--- | :--- | :--- | :--- |
| **Logic Elements (LEs)** | ~1,450 | 114,480 | ~1.3% |
| **Combinational ALUTs / LEs** | ~1,420 | 114,480 | ~1.2% |
| **Dedicated Logic Registers** | ~1,024 | 114,480 | ~0.9% |
| **Total Memory Bits (BRAM)** | 65,536 bits (8 KB) | 3,981,312 bits | ~1.6% |
| **M9K Memory Blocks** | 8 | 432 | ~1.8% |
| **Maximum Frequency ($f_{MAX}$)** | **52.4 MHz** | N/A | Calculated by TimeQuest |

> **Optimization Note**: By structuring `instruction_mem` and `data_mem` to latch addresses on `posedge clk`, Quartus automatically infers hardware **M9K embedded memory blocks**, preserving thousands of Logic Elements that would otherwise be wasted on register arrays.

---

## Getting Started & Toolchain Guide

### 1. Prerequisites
- **FPGA Synthesis**: [Intel Quartus Prime (Lite Edition)](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html)
- **Simulation**: [Icarus Verilog](http://iverilog.icarus.com/) & [GTKWave](http://gtkwave.sourceforge.net/) OR ModelSim / QuestaSim
- **Cross Compiler**: `riscv32-unknown-elf-gcc` toolchain

### 2. Simulation with Icarus Verilog & GTKWave

To simulate the processor core locally using Icarus Verilog:

```bash
# Clone the repository
git clone https://github.com/your-username/rv32i-fpga-core.git
cd rv32i-fpga-core

# Compile the Verilog RTL modules and testbench
iverilog -o sim/rv32i_sim rtl/*.v tb/tb_rv32i_top.v

# Execute simulation (generates VCD waveform file)
vvp sim/rv32i_sim

# View signals in GTKWave
gtkwave sim/waveform.vcd
```

### 3. Compiling C/Assembly Software

You can write custom C program files and assemble them into a hex dump format compatible with `$readmemh`.

```bash
# Compile C code for RV32I architecture
riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -T sw/link.ld sw/main.c -o sw/main.elf

# Extract raw binary
riscv32-unknown-elf-objcopy -O binary sw/main.elf sw/main.bin

# Convert binary to hex file for memory preloading
hexdump -v -e '1/4 "%08x
"' sw/main.bin > tb/program.hex
```

### 4. Intel Quartus II Synthesis & FPGA Placement

1. Open Intel Quartus II / Prime.
2. Select **File > Open Project** and choose `synth/rv32i_top.qpf`.
3. Set `rv32i_top` as the Top-Level Entity (**Project > Set as Top-Level Entity**).
4. Run **Start Compilation** (`Ctrl + L`).
5. Open **Compilation Report > Fitter > Resource Section** to confirm M9K Block RAM inference.
6. Open **TimeQuest Timing Analyzer** to verify setup/hold margins and target clock constraints.

---

## Verification & Testbench

The core includes a comprehensive top-level testbench (`tb/tb_rv32i_top.v`) that:
- Generates system clock (`clk`) and active-low reset pulse (`rst_n`).
- Preloads `program.hex` into the instruction memory.
- Monitors PC, instruction execution, ALU results, and memory writes cycle-by-cycle.
- Features self-checking assertion logic to detect illegal instructions or unexpected register states.

---

## Roadmap & Future Enhancements

- [ ] **Byte/Halfword Memory Support**: Implement `LB`, `LBU`, `LH`, `LHU`, `SB`, `SH` with byte-enable logic.
- [ ] **5-Stage Pipeline Implementation**: Convert from single-cycle to `IF-ID-EX-MEM-WB` with full hazard detection and branch prediction.
- [ ] **Memory-Mapped I/O (MMIO)**: Map board peripherals (LEDs, 7-Segment displays, Pushbuttons, UART) into processor address space.
- [ ] **Interrupt & Exception Handling**: Add Machine-Mode Control and Status Registers (CSRs) for timer interrupts.
- [ ] **RV32M Extension**: Integrate hardware multiplier and divider pipeline units.

---

## License & Contact

Distributed under the **MIT License**. See `LICENSE` for more information.

- **Author**: Principal FPGA / Hardware Design Engineer
- **GitHub**: [@your-username](https://github.com/your-username)
- **LinkedIn**: [linkedin.com/in/your-profile](https://linkedin.com/in/your-profile)
