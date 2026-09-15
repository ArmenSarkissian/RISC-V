# 1. Define a 50 MHz clock constraint (20.000 ns period) on the 'clk' port
create_clock -name clk -period 20.000 [get_ports clk]

# 2. Derive clock uncertainty for accurate FPGA timing analysis
derive_clock_uncertainty