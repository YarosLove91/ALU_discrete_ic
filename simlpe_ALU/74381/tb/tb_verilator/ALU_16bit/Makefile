

ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

# Add multithreading

NUM_THREADS := $(shell nproc)

ifeq ($(NUM_THREADS), 0)
    NUM_THREADS := 2
else
    NUM_THREADS := $(shell echo "$$(( $(NUM_THREADS) - 2 ))")
endif

######################################################################
# Set up variables

GENHTML = genhtml

# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a
# package install, and verilator is in your path. Otherwise find the
# binary relative to $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
VERILATOR = $(z)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif



###############################################################################
# Variables
###############################################################################

OUTPUT_DIR       ?= alu_16_bit

VERILATOR_FLAGS ?=
# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += --x-assign 0
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
# Make waveforms
#VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
VERILATOR_FLAGS += --coverage

VERILATOR_FLAGS += --trace
VERILATOR_FLAGS += -j $(NUM_THREADS)
# Run make to compile model, with as many CPUs as are free
VERILATOR_FLAGS += --build -j
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt

VERILATOR_INPUT ?=
# Input files for Verilator
VERILATOR_INPUT = alu_16_bit.v 
VERILATOR_INPUT += main.cpp
VERILATOR_INPUT += ../alu_74381.v 

######################################################################
VERILATOR_COV_FLAGS ?=
# Create annotated source
VERILATOR_COV_FLAGS += --annotate logs/annotated
# A single coverage hit is considered good enough
VERILATOR_COV_FLAGS += --annotate-min 1
# Create LCOV info
VERILATOR_COV_FLAGS += --write-info logs/coverage.info
# Input file from Verilator
VERILATOR_COV_FLAGS += logs/coverage.dat

######################################################################
default: run

run:
	@echo

	@echo
	@echo "-- VERILATE ----------------"
	$(VERILATOR) --version
	$(VERILATOR) --Mdir $(OUTPUT_DIR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

	@echo
	@echo "-- RUN ---------------------"
	@rm -rf logs
	@mkdir -p logs
	$(OUTPUT_DIR)/Valu_16_bit 
	@echo
	@echo "-- DONE --------------------"


######################################################################
# Other targets

show-config:
	$(VERILATOR) -V

genhtml:
	@echo "-- GENHTML --------------------"
	@echo "-- Note not installed by default, so not in default rule"
	$(GENHTML) logs/coverage.info --output-directory logs/html

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf $(OUTPUT_DIR) logs *.log *.dmp *.vpd core