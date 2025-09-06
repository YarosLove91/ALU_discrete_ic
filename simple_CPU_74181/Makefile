# Makefile for ALU Processor Simulation
# Uses wildcard and pattern substitution for automatic file discovery

# Compiler and simulator
VLOG = iverilog
VVPP = vvp
VLOG_FLAGS = -g2012  # Enable SystemVerilog features

# Directories
RTL_TOP_DIR = rtl/top
TB_DIR = tb
RTL_DIR = rtl/src

# Source files (automatically discover all .v files)
RTL_SOURCES = $(wildcard $(RTL_DIR)/*.v)
TOP_SOURCES = $(wildcard $(RTL_TOP_DIR)/*.v)
ALL_SOURCES = $(RTL_SOURCES) $(TOP_SOURCES)

# Test files (all files starting with tb_)
TEST_FILES = $(wildcard $(TB_DIR)/tb_*.v)

# Output files
SIMULATION = simulation
VCD_OUTPUT = wave.vcd

# Default target
all: compile run

# Compilation with automatic dependency detection
compile: $(SIMULATION)

$(SIMULATION): $(ALL_SOURCES) $(TEST_FILES)
	@echo "Source files:"
	@$(foreach file, $(ALL_SOURCES), echo "  $(file)";)
	@echo "Test files:"
	@$(foreach file, $(TEST_FILES), echo "  $(file)";)
	$(VLOG) $(VLOG_FLAGS) -o $@ $^
	@echo "Compilation completed: $@"

# Run simulation
run: $(SIMULATION)
	$(VVPP) $<
	@echo "Simulation completed"

# Run with VCD output for waveform viewing
wave: $(SIMULATION)
	$(VVPP) $< +vcd
	@echo "Waveform simulation completed. Open $(VCD_OUTPUT) with gtkwave"

# Clean build artifacts
clean:
	rm -f $(SIMULATION) $(VCD_OUTPUT) *.vcd
	@echo "Clean completed"

# List all source files
list-src:
	@echo "Source files:"
	@$(foreach file, $(ALL_SOURCES), echo "  $(notdir $(file))";)

# List all test files
list-test:
	@echo "Test files:"
	@$(foreach file, $(TEST_FILES), echo "  $(notdir $(file))";)

# Run specific test (e.g., make test-file=tb_simple_CPU.v)
test: $(SIMULATION)
	$(VLOG) $(VLOG_FLAGS) -o $(SIMULATION) $(ALL_SOURCES) $(TB_DIR)/$(test-file)
	$(VVPP) $(SIMULATION)

# Pattern-based compilation for different test scenarios
test-%: $(ALL_SOURCES) $(TB_DIR)/tb_%.v
	$(VLOG) $(VLOG_FLAGS) -o $(SIMULATION) $^
	$(VVPP) $(SIMULATION)

# Display help information
help:
	@echo "Available targets:"
	@echo "  all       - Compile and run (default)"
	@echo "  compile   - Compile only"
	@echo "  run       - Run simulation"
	@echo "  wave      - Run with VCD output"
	@echo "  clean     - Remove generated files"
	@echo "  list-src  - List source files"
	@echo "  list-test - List test files"
	@echo "  test-%    - Run specific test (e.g., test-simple_CPU)"
	@echo "  test      - Run custom test (use test-file=filename.v)"

# Phony targets
.PHONY: all compile run wave clean list-src list-test test help