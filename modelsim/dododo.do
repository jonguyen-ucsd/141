# Compile
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/Definitions.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/ALU.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/Ctrl.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/DataMem.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/InstFetch.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/InstROM.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/LUT.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/program1_tb.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/program2_tb.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/program3_tb.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/RegFile.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/TopLevel.sv
vlog -reportprogress 300 -work work C:/Users/jnvie/Documents/GitHub/141/verilog/TopLevel_tb.sv

# Start Simulation
vsim -gui work.decrypt_depad_tb

# Add waves
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/Reset
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/Start
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/Clk
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/Ack
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/ALU_op
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/ALU_en
add wave -position insertpoint -radix unsigned -format analog-step -height 74 -max 115 sim:/decrypt_depad_tb/dut/PgmCtr
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/PCTarg
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/Instruction
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/reg_A_addr
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/reg_B_addr
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/reg_write_addr
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/reg_A_value
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/reg_B_value
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/reg_write_value
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/ALU_out
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/mem_write_value
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/mem_read_value
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/RegWrite
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/MemWrite
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/BranchEn
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/Halt
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/CycleCt
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/label_index
add wave -position insertpoint -radix unsigned sim:/decrypt_depad_tb/dut/RF1/Registers
add wave -position insertpoint -radix hexadecimal sim:/decrypt_depad_tb/dut/DM1/Core

# run
run -all

# set zoom
wave zoom full