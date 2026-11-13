ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

######################################################################
# Paths (relative to project root: simlpe_ALU/74382/)

PROJ_ROOT := $(CURDIR)
RTL_DIR   := $(PROJ_ROOT)/rtl
TB_DIR    := $(PROJ_ROOT)/tb
GEN_DIR   := $(TB_DIR)/tb_verilator
FL_DIR    := $(PROJ_ROOT)/file_lists
OBJ_DIR   := $(PROJ_ROOT)/obj_dir

######################################################################
# Tools

VERILATOR          = verilator
VERILATOR_COVERAGE = verilator_coverage
CXX                = g++
CXXFLAGS           = -O2 -std=c++17

######################################################################
# Test configuration

# default values for tests' defines
test_name ?= DATASHEET_VECTORS_TEST
sw_tst_op ?= a+b
vsize     ?= 100

######################################################################
# Verilator flags

VERILATOR_FLAGS  = +incdir+$(TB_DIR)/tb_verilog
# Generate C++ in executable form
VERILATOR_FLAGS += --binary
# Optimize
VERILATOR_FLAGS += --x-assign 0
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
VERILATOR_FLAGS += --coverage

VERILATOR_FLAGS += --trace

VERILATOR_FLAGS += -Wno-fatal

VERILATOR_FLAGS += +define+$(test_name) +define+DEF_SW_TEST_OP=$(sw_tst_op) +define+DEF_TEST_VECTOR_SIZE=$(vsize)

VERILATOR_FLAGS += --top tb
VERILATOR_FLAGS += --Mdir $(OBJ_DIR)

VERILATOR_INPUT = -f $(FL_DIR)/src.f -f $(FL_DIR)/tb.f

######################################################################
# Targets

default: run

$(TB_DIR)/generate: $(GEN_DIR)/sw_test_vectors_gen.cpp $(GEN_DIR)/sw_test_vectors_gen.h
	$(CXX) $(CXXFLAGS) -o $@ $<

run: $(TB_DIR)/generate
	@echo
	@echo "-- VERILATE ----------------"
	$(VERILATOR) --version
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)
	@echo
	@echo "-- RUN ---------------------"
	@rm -rf logs
	@mkdir -p logs
	$(TB_DIR)/generate $(sw_tst_op) $(vsize)
	$(OBJ_DIR)/Vtb
	@echo
	@echo "-- DONE --------------------"

######################################################################
# Other targets

show-config:
	$(VERILATOR) -V

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf $(OBJ_DIR) logs *.log *.dmp *.vpd core *.txt $(TB_DIR)/*.txt *.dat $(TB_DIR)/generate
