# ============================================================
# Student lab: UVM verification of the 16-bit 74181+74182 ALU
#   Simulator: Verilator 5.x + uvm-verilator (UVM 1800.2)
#
#   tb/              - UVM testbench (interface, packages, top)
#   top_alu_16.sv    - DUT (alu16: 4x74181 + 74182 CLA)
#   ../classic_ALU/  - 74181 slice RTL (dependency)
#   ../common_CLA/   - 74182 CLA RTL (dependency)
#   uvm-verilator/   - UVM library (cloned by: make uvm_download)
# ============================================================

CXX      := g++

# ------------------------------------------------------------
# Run parameters (overridable from the command line)
#   TEST : alu_smoke_test | alu_random_test
#
# Configuration knobs (override the localparam defaults from
# tb/alu_cfg_pkg.sv; passed as +define+ALU_CFG_<NAME>=<value>
# only when set explicitly, any change triggers a rebuild):
#   N        -> NUM_TRANSACTIONS    (alu_random_test vectors)
#   SMOKE_N  -> SMOKE_TRANSACTIONS  (alu_smoke_test vectors)
#   COV      -> COVERAGE_EN         (1/0 functional coverage)
#   XCHK     -> RFM_XCHECK_EN       (1/0 golden arithmetic cross-check)
#   SCB_LOG  -> SCB_MAX_LOG         (detailed mismatch log cap)
#   MATCH_LOG-> SCB_MATCH_LOG_EN    (1/0 per-match scoreboard log)
#   CPPREF   -> USE_CPP_REF         (1 = C++ DPI golden, 0 = SV)
# ------------------------------------------------------------
DUT  := alu16
TEST ?= alu_smoke_test
VERBOSITY    ?= UVM_HIGH
# Additional simulation plusargs (override: make SIM_PLUSARGS="...")
# +UVM_NO_RELNOTES suppresses the UVM release-notes banner
SIM_PLUSARGS ?= +UVM_NO_RELNOTES

CFG_DEFINES :=
ifdef N
  CFG_DEFINES += +define+ALU_CFG_NUM_TRANSACTIONS=$(N)
endif
ifdef SMOKE_N
  CFG_DEFINES += +define+ALU_CFG_SMOKE_TRANSACTIONS=$(SMOKE_N)
endif
ifdef COV
  CFG_DEFINES += +define+ALU_CFG_COVERAGE_EN=$(COV)
endif
ifdef XCHK
  CFG_DEFINES += +define+ALU_CFG_RFM_XCHECK_EN=$(XCHK)
endif
ifdef SCB_LOG
  CFG_DEFINES += +define+ALU_CFG_SCB_MAX_LOG=$(SCB_LOG)
endif
ifdef MATCH_LOG
  CFG_DEFINES += +define+ALU_CFG_SCB_MATCH_LOG_EN=$(MATCH_LOG)
endif
ifdef CPPREF
  CFG_DEFINES += +define+ALU_CFG_USE_CPP_REF=$(CPPREF)
endif
CFG_STRING := DUT=$(DUT) N=$(N) SMOKE_N=$(SMOKE_N) COV=$(COV) XCHK=$(XCHK) SCB_LOG=$(SCB_LOG) MATCH_LOG=$(MATCH_LOG) CPPREF=$(CPPREF)

NUM_THREADS := $(shell nproc 2>/dev/null || echo 4)
MAKEFLAGS += --no-print-directory

# ------------------------------------------------------------
# Paths to the RTL under verification (single source of truth)
# ------------------------------------------------------------
RTL_ROOT := $(CURDIR)/..
RTL_181  := $(RTL_ROOT)/classic_ALU/src_common/74181.v
RTL_182  := $(RTL_ROOT)/common_CLA/74182_CLA/74182_CLA.v
DUT_TOP  := $(CURDIR)/top_alu_16.sv

RTL_SRCS := $(RTL_181) $(RTL_182) $(DUT_TOP)

# ------------------------------------------------------------
# UVM (uvm-verilator)
# ------------------------------------------------------------
VERILATOR   := verilator
UVM_DIR     ?= $(CURDIR)/uvm-verilator
UVM_REPO    := https://github.com/chipsalliance/uvm-verilator.git
UVM_MARKER  := .uvm_downloaded
UVM_DPI_SRC := $(UVM_DIR)/src/dpi/uvm_dpi.cc

TB_TOP    := alu_tb_top
TB_DIR    := tb
RFM_DIR   := tb/ref_model
AGENT_DIR := tb/env/agent
SEQ_DIR   := tb/env/sequence
ENV_DIR   := tb/env/environment
TEST_DIR  := tb/tests
OUT_DIR   := uvm_out/$(DUT)
LOG_DIR   := logs
LOG       := $(LOG_DIR)/$(TEST).log

# Compilation units in dependency order:
# params pkg -> cfg pkg -> common pkg -> sequence pkg -> agent pkg ->
# env pkg -> test pkg -> top; class files are `included into their packages
TB_PKG_SRCS := $(TB_DIR)/params_pkg.sv \
               $(TB_DIR)/alu_cfg_pkg.sv \
               $(TB_DIR)/alu_tb_pkg.sv \
               $(SEQ_DIR)/alu_seq_pkg.sv \
               $(AGENT_DIR)/alu_agent_pkg.sv \
               $(ENV_DIR)/alu_env_pkg.sv \
               $(TEST_DIR)/alu_test_pkg.sv
TB_ALL      := $(wildcard $(TB_DIR)/*.sv) $(wildcard $(RFM_DIR)/*.sv) \
               $(wildcard $(RFM_DIR)/dpi/*.cpp) \
               $(wildcard $(AGENT_DIR)/*.sv) $(wildcard $(SEQ_DIR)/*.sv) \
               $(wildcard $(ENV_DIR)/*.sv) $(wildcard $(TEST_DIR)/*.sv)

# C++ golden model (DPI-C), activated by USE_CPP_REF in alu_cfg_pkg.sv
RFM_CPP_SRC := $(RFM_DIR)/dpi/alu_golden_dpi.cpp

# ------------------------------------------------------------
# Linker auto-detection: mold -> lld -> gold -> system default
# ------------------------------------------------------------
LINKER ?= $(shell for l in mold lld gold; do \
            if command -v $$l >/dev/null 2>&1; then echo $$l; break; fi; \
          done)
ifneq ($(strip $(LINKER)),)
  LDFLAGS += -fuse-ld=$(LINKER)
  LINKER_DISPLAY := $(LINKER)
else
  LINKER_DISPLAY := (system default: bfd)
endif

TRACE_FLAGS :=
ifeq ($(TRACE),1)
  TRACE_FLAGS := --trace
  # keep the trace build isolated from the regular one
  OUT_DIR := uvm_out/$(DUT)_trace
endif

BIN := $(OUT_DIR)/V$(TB_TOP)

VFLAGS := \
	--binary \
	--timing \
	--vpi \
	-j $(NUM_THREADS) \
	-Wno-fatal \
	-Wno-DECLFILENAME \
	-Wno-UNUSED \
	-Wno-WIDTHTRUNC \
	-Wno-WIDTHCONCAT \
	-Wno-UNSIGNED \
	-Wno-CASEINCOMPLETE \
	-Wno-TIMESCALEMOD \
	$(TRACE_FLAGS) \
	$(CFG_DEFINES) \
	+incdir+$(UVM_DIR)/src \
	+incdir+$(TB_DIR) \
	+incdir+$(RFM_DIR) \
	+incdir+$(AGENT_DIR) \
	+incdir+$(SEQ_DIR) \
	+incdir+$(ENV_DIR) \
	+incdir+$(TEST_DIR) \
	--top-module $(TB_TOP) \
	--Mdir $(OUT_DIR) \
	$(if $(strip $(LDFLAGS)),-LDFLAGS "$(LDFLAGS)",)

# ------------------------------------------------------------
# Colored console verdicts (default behavior)
#   green "TEST SUCCESFULLY PASS !" / red "TEST FAILURE !"
#   Color is decided at recipe runtime: enabled when stdout is
#   a terminal, auto-disabled in pipes/CI or when NO_COLOR is
#   set (https://no-color.org).
# ------------------------------------------------------------
CLR_PASS := \033[1;32m
CLR_FAIL := \033[1;31m
CLR_OFF  := \033[0m

# runtime color gate: usage $(call clr,<code>) -> assigns C/R shell vars
define clr
	if [ -t 1 ] && [ -z "$$NO_COLOR" ]; then C='$(1)'; R='$(CLR_OFF)'; else C=''; R=''; fi
endef

# ------------------------------------------------------------
# Targets
# ------------------------------------------------------------
.PHONY: all build run smoke rand help list clean distclean FORCE \
        uvm_download waves test

# Regression targets fan out to sub-makes sharing one OUT_DIR;
# serialize to avoid concurrent Verilator builds into the same --Mdir
.NOTPARALLEL:

all: run

uvm_download: $(UVM_MARKER)

$(UVM_MARKER):
	@if [ ! -d "$(UVM_DIR)" ]; then \
		echo ">>> [uvm] Cloning uvm-verilator..."; \
		git clone --depth 1 $(UVM_REPO) $(UVM_DIR); \
	fi
	@touch $@

build: $(BIN)

# Config stamp: rewritten (triggering a rebuild) only when the
# effective knob set changes; file edits to alu_cfg_pkg.sv are
# covered by the TB_ALL dependency
CFG_STAMP := $(OUT_DIR)/.cfg_stamp

$(CFG_STAMP): FORCE
	@mkdir -p $(OUT_DIR)
	@echo "$(CFG_STRING) TRACE=$(TRACE)" > $@.tmp
	@if cmp -s $@.tmp $@ 2>/dev/null; then rm -f $@.tmp; else mv $@.tmp $@; fi

FORCE:

$(BIN): $(UVM_MARKER) $(TB_ALL) $(RTL_SRCS) $(CFG_STAMP) $(firstword $(MAKEFILE_LIST))
	@mkdir -p $(OUT_DIR) $(LOG_DIR)
	@echo ">>> [build] $(CFG_STRING) jobs=$(NUM_THREADS) ld=$(LINKER_DISPLAY)"
	$(VERILATOR) $(VFLAGS) \
		$(UVM_DIR)/src/uvm_pkg.sv \
		$(TB_DIR)/alu_if.sv \
		$(RTL_181) \
		$(RTL_182) \
		$(DUT_TOP) \
		$(TB_PKG_SRCS) \
		$(TB_DIR)/alu_tb_top.sv \
		$(RFM_CPP_SRC) \
		$(UVM_DPI_SRC) \
		-CFLAGS "-std=c++17"

run: build
	@mkdir -p $(LOG_DIR)
	@echo ">>> [run] TEST=$(TEST) cfg:$(if $(strip $(CFG_DEFINES)), $(CFG_DEFINES), alu_cfg_pkg defaults)"
	-$(BIN) +UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=$(VERBOSITY) $(SIM_PLUSARGS) 2>&1 | tee $(LOG)
	@if grep -q "LAB_RESULT: PASS" $(LOG); then \
		$(call clr,$(CLR_PASS)); \
		printf "$$C>>> TEST SUCCESFULLY PASS !$$R (%s)\n" "$(LOG)"; \
	else \
		$(call clr,$(CLR_FAIL)); \
		printf "$$C>>> TEST FAILURE !$$R (%s)\n" "$(LOG)"; \
		exit 1; \
	fi

# single run with VCD dump (TRACE=1 rebuilds into a separate dir)
waves:
	@$(MAKE) run TRACE=1
	@echo ">>> Waves: $(LOG_DIR)/waves.vcd (gtkwave $(LOG_DIR)/waves.vcd)"

# ------------------------------------------------------------
# Single runs
# ------------------------------------------------------------
smoke:
	@$(MAKE) run TEST=alu_smoke_test

rand:
	@$(MAKE) run TEST=alu_random_test

# ------------------------------------------------------------
# Regressions
#   test - current core suite (smoke + random)
# ------------------------------------------------------------
test: smoke rand
	@$(call clr,$(CLR_PASS)); \
	printf "$$C>>> REGRESSION test: TEST SUCCESFULLY PASS !$$R\n"

# ------------------------------------------------------------
clean:
	@rm -rf uvm_out $(LOG_DIR) *.vcd

distclean: clean
	@rm -rf $(UVM_DIR) $(UVM_MARKER)

list:
	@echo "DUT        : $(DUT)"
	@echo "TEST       : $(TEST)"
	@echo "CFG        : $(CFG_STRING)"
	@echo "RTL_SRCS   : $(RTL_SRCS)"
	@echo "BIN        : $(BIN)"
	@echo "LD         : $(LINKER_DISPLAY)"
	@echo "VERILATOR  : $(shell $(VERILATOR) --version)"

help:
	@echo "Student lab: UVM verification of the 16-bit 74181+74182 ALU (Verilator)"
	@echo ""
	@echo "Quick start:"
	@echo "  make uvm_download        - clone uvm-verilator (once)"
	@echo "  make smoke               - quick smoke run (alu16)"
	@echo "  make run TEST=<test> [N=<count>] [COV=0|1] [CPPREF=0|1]"
	@echo ""
	@echo "  TEST: alu_smoke_test | alu_random_test"
	@echo ""
	@echo "Configuration knobs (override localparam defaults from"
	@echo "tb/alu_cfg_pkg.sv; unset knobs use the file defaults):"
	@echo "  N=<n>        NUM_TRANSACTIONS    (random test vectors)"
	@echo "  SMOKE_N=<n>  SMOKE_TRANSACTIONS  (smoke test vectors)"
	@echo "  COV=0|1      COVERAGE_EN         (functional coverage)"
	@echo "  XCHK=0|1     RFM_XCHECK_EN       (golden arithmetic cross-check)"
	@echo "  SCB_LOG=<n>  SCB_MAX_LOG         (mismatch log cap)"
	@echo "  MATCH_LOG=0|1 SCB_MATCH_LOG_EN   (per-match scoreboard log)"
	@echo "  CPPREF=0|1   USE_CPP_REF         (1 = C++ DPI golden model)"
	@echo ""
	@echo "Regressions:"
	@echo "  make test                - core suite (smoke + random)"
	@echo ""
	@echo "Misc:"
	@echo "  make waves TEST=...      - run with VCD dump (logs/waves.vcd)"
	@echo "  make list                - print variables"
	@echo "  make clean / distclean   - cleanup (distclean removes uvm-verilator)"
