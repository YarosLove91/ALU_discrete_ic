# Makefile for ALU Processor Simulation

VLOG = iverilog
VVPP = vvp
SRC = param_reg_file.v top_alu_16.v 74181.v cla_74182.v cpu_top.v
TEST = test_cpu_commands.v

all: compile run

compile:
	$(VLOG) -o simulation $(SRC) $(TEST)

run:
	$(VVPP) simulation

clean:
	rm -f simulation *.vcd

.PHONY: all compile run clean