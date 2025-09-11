# Makefile with auto targets for each testbench

VLOG = iverilog
VVPP = vvp
VLOG_FLAGS = -g2012 -I $(TB_DIR)#$(RTL_DIR)$(TOP_DIR)

# Directories
RTL_DIR = rtl/src
TOP_DIR = rtl/top
TB_DIR = tb

# Files
RTL_SOURCES = $(wildcard $(RTL_DIR)/*.v)
TOP_SOURCES = $(wildcard $(TOP_DIR)/*.v)
TB_SOURCES = $(wildcard $(TB_DIR)/tb_*.v)
TB_MODULES = $(notdir $(basename $(TB_SOURCES)))

# Default target
help:
	@echo "Available testbench targets:"
	@$(foreach tb,$(TB_MODULES),echo "  $(tb)";)
	@echo ""
	@echo "Usage: make <testbench_name> [wave=1]"
	@echo "Example: make tb_reg_file"
	@echo "         make tb_simple_CPU wave=1"

# Rule for each testbench
define TB_RULE
$(1):
	$$(VLOG) $$(VLOG_FLAGS) -m test_cpu_top -o simulation $$(RTL_SOURCES) $$(TOP_SOURCES) $$(TB_DIR)/$(1).v
ifeq ($$(wave),1)
	$$(VVPP) simulation +vcd
else
	$$(VVPP) simulation
endif
endef

# Generate rules for all testbenches
$(foreach tb,$(TB_MODULES),$(eval $(call TB_RULE,$(tb))))

# Waveform viewing
wave:
	gtkwave *.vcd &

# Clean
clean:
	rm -f simulation *.vcd

.PHONY: help clean wave $(TB_MODULES)