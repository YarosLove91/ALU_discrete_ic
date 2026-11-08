# ============================================================
# Student lab: UVM verification of the 74381/74382 ALUs
#   Simulator: Verilator 5.x + uvm-verilator (UVM 1800.2)
#
#   tb/            - UVM testbench (interface, package, top)
#   ../simlpe_ALU/ - RTL under verification (74381 / 74382)
#   uvm-verilator/ - UVM library (cloned by: make uvm_download)
# ============================================================

CXX      := g++

# ------------------------------------------------------------
# Run parameters (overridable from the command line)
#   DUT  : 74381 | 74382 | 74381_16 | 74382_16
#   TEST : alu_smoke_test | alu_sanity_test | alu_ds_test |
#          alu_exhaustive_test | alu_random_test | alu_corner_test
#
# Compile-time configuration knobs (see the CFG_DEFINES block below):
#   N, SMOKE_N, COV, XCHK, SCB_LOG
# ------------------------------------------------------------
DUT  ?= 74381
TEST ?= alu_ds_test
VERBOSITY    ?= UVM_HIGH
# Additional simulation plusargs (override: make SIM_PLUSARGS="...")
# +UVM_NO_RELNOTES suppresses the UVM release-notes banner
SIM_PLUSARGS ?= +UVM_NO_RELNOTES

# Compile-time knobs (alu_cfg_pkg). Defaults live ONLY in
# tb/alu_cfg_pkg.sv (single source of truth); a +define+ is passed
# solely when a knob is explicitly set (make N=5000 COV=0 ...).
# Changing any knob rewrites .cfg_stamp and triggers a rebuild.
CFG_DEFINES :=
ifdef N
  CFG_DEFINES += +define+NUM_TRANSACTIONS=$(N)
endif
ifdef SMOKE_N
  CFG_DEFINES += +define+SMOKE_TRANSACTIONS=$(SMOKE_N)
endif
ifdef COV
  CFG_DEFINES += +define+COVERAGE_EN=$(COV)
endif
ifdef XCHK
  CFG_DEFINES += +define+RFM_XCHECK_EN=$(XCHK)
endif
ifdef SCB_LOG
  CFG_DEFINES += +define+SCB_MAX_LOG=$(SCB_LOG)
endif
CFG_STRING := DUT=$(DUT) N=$(N) SMOKE_N=$(SMOKE_N) COV=$(COV) XCHK=$(XCHK) SCB_LOG=$(SCB_LOG)

NUM_THREADS := $(shell nproc 2>/dev/null || echo 4)
MAKEFLAGS += --no-print-directory

# ------------------------------------------------------------
# Paths to the RTL under verification (single source of truth)
# ------------------------------------------------------------
RTL_ROOT := $(CURDIR)/../simlpe_ALU
RTL_381  := $(RTL_ROOT)/74381/rtl
RTL_382  := $(RTL_ROOT)/74382/rtl

ifeq ($(DUT),74381)
  RTL_SRCS := $(RTL_381)/src/alu_74381.v
else ifeq ($(DUT),74381_16)
  RTL_SRCS := $(RTL_381)/src/alu_74381.v $(RTL_381)/top/alu_16_bit.v
else ifeq ($(DUT),74382)
  RTL_SRCS := $(RTL_382)/src/alu_74382_pkg.sv $(RTL_382)/src/alu_74382.sv
else ifeq ($(DUT),74382_16)
  RTL_SRCS := $(RTL_382)/src/alu_74382_pkg.sv $(RTL_382)/src/alu_74382.sv $(RTL_382)/top/alu_16_chain.sv
else
  $(error Unknown DUT='$(DUT)'. Available: 74381, 74382, 74381_16, 74382_16)
endif

# ------------------------------------------------------------
# UVM (uvm-verilator)
# ------------------------------------------------------------
VERILATOR   := verilator
UVM_DIR     := $(CURDIR)/uvm-verilator
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
LOG       := $(LOG_DIR)/$(DUT)_$(TEST).log

# Compilation units in dependency order:
# cfg pkg -> common pkg -> sequence pkg -> agent pkg -> env pkg ->
# test pkg -> top; class files are `included into their packages
TB_PKG_SRCS := $(TB_DIR)/alu_cfg_pkg.sv \
               $(TB_DIR)/alu_tb_pkg.sv \
               $(SEQ_DIR)/alu_seq_pkg.sv \
               $(AGENT_DIR)/alu_agent_pkg.sv \
               $(ENV_DIR)/alu_env_pkg.sv \
               $(TEST_DIR)/alu_test_pkg.sv
TB_ALL      := $(wildcard $(TB_DIR)/*.sv) $(wildcard $(RFM_DIR)/*.sv) \
               $(wildcard $(AGENT_DIR)/*.sv) $(wildcard $(SEQ_DIR)/*.sv) \
               $(wildcard $(ENV_DIR)/*.sv) $(wildcard $(TEST_DIR)/*.sv)

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
	+define+DUT_$(DUT) \
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
.PHONY: all build run smoke sanity help list clean distclean FORCE \
        uvm_download waves \
        ds381 ds382 exh381 exh382 rand381 rand382 corner381 corner382 \
        rand381_16 rand382_16 ds381_16 ds382_16 \
        test hunt test_all

# Regression targets fan out to sub-makes sharing one OUT_DIR per DUT;
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

# Config stamp: rewrites (and thus triggers a rebuild) only when
# the compile-time configuration actually changes
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
		$(RTL_SRCS) \
		$(TB_PKG_SRCS) \
		$(TB_DIR)/alu_tb_top.sv \
		$(UVM_DPI_SRC) \
		-CFLAGS "-std=c++17"

run: build
	@mkdir -p $(LOG_DIR)
	@echo ">>> [run] DUT=$(DUT) TEST=$(TEST) cfg:$(if $(CFG_DEFINES),$(CFG_DEFINES), alu_cfg_pkg defaults)"
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
# Single runs (DUT x TEST)
# ------------------------------------------------------------
sanity:
	@$(MAKE) run DUT=74381 TEST=alu_sanity_test

ds381:
	@$(MAKE) run DUT=74381 TEST=alu_ds_test
ds382:
	@$(MAKE) run DUT=74382 TEST=alu_ds_test
ds381_16:
	@$(MAKE) run DUT=74381_16 TEST=alu_ds_test
ds382_16:
	@$(MAKE) run DUT=74382_16 TEST=alu_ds_test

exh381:
	@$(MAKE) run DUT=74381 TEST=alu_exhaustive_test
exh382:
	@$(MAKE) run DUT=74382 TEST=alu_exhaustive_test

rand381:
	@$(MAKE) run DUT=74381 TEST=alu_random_test N=$(N)
rand382:
	@$(MAKE) run DUT=74382 TEST=alu_random_test N=$(N)
rand381_16:
	@$(MAKE) run DUT=74381_16 TEST=alu_random_test N=$(N)
rand382_16:
	@$(MAKE) run DUT=74382_16 TEST=alu_random_test N=$(N)

corner381:
	@$(MAKE) run DUT=74381 TEST=alu_corner_test
corner382:
	@$(MAKE) run DUT=74382 TEST=alu_corner_test

smoke:
	@$(MAKE) run DUT=74381 TEST=alu_smoke_test

# ------------------------------------------------------------
# Regressions
#   test     - core suite: green regardless of the defect state
#   hunt     - stage-4 regression: FAILs while the OVR defect is
#              injected (docs/instructor/alu_74382_inject_ovr_bug.patch),
#              PASSes on the fixed RTL
#   test_all - full matrix (test + hunt + random/corner 382)
# ------------------------------------------------------------
test: sanity ds381 ds382 exh381 rand381 corner381 ds381_16 rand381_16 ds382_16
	@$(call clr,$(CLR_PASS)); \
	printf "$$C>>> REGRESSION test: TEST SUCCESFULLY PASS !$$R\n"

hunt: exh382
	@$(call clr,$(CLR_PASS)); \
	printf "$$C>>> REGRESSION hunt: TEST SUCCESFULLY PASS ! (OVR defect is fixed)$$R\n"

test_all: test exh382 rand382 corner382 rand382_16
	@$(call clr,$(CLR_PASS)); \
	printf "$$C>>> REGRESSION test_all: TEST SUCCESFULLY PASS !$$R\n"

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
	@echo "Student lab: UVM verification of the 74381/74382 ALUs (Verilator)"
	@echo ""
	@echo "Quick start:"
	@echo "  make uvm_download        - clone uvm-verilator (once)"
	@echo "  make smoke               - quick smoke run (74381)"
	@echo "  make run DUT=<dut> TEST=<test> [N=<count>] [COV=0|1]"
	@echo ""
	@echo "  DUT : 74381 | 74382 | 74381_16 | 74382_16"
	@echo "  TEST: alu_smoke_test | alu_sanity_test | alu_ds_test |"
	@echo "        alu_exhaustive_test | alu_random_test | alu_corner_test"
	@echo ""
	@echo "Compile-time config (defaults: tb/alu_cfg_pkg.sv; set a knob to"
	@echo "override it via +define+, changing any knob rebuilds the DUT):"
	@echo "  N=<n>        NUM_TRANSACTIONS   (random test vectors)"
	@echo "  SMOKE_N=<n>  SMOKE_TRANSACTIONS (smoke test vectors)"
	@echo "  COV=0|1      COVERAGE_EN        (functional coverage)"
	@echo "  XCHK=0|1     RFM_XCHECK_EN      (golden 16-bit cross-check)"
	@echo "  SCB_LOG=<n>  SCB_MAX_LOG        (mismatch log cap)"
	@echo ""
	@echo "Regressions:"
	@echo "  make test                - core suite (green in any defect state)"
	@echo "  make hunt                - stage 4: OVR defect regression (FAIL while injected)"
	@echo "  make test_all            - full matrix (PASS on the fixed RTL)"
	@echo ""
	@echo "Misc:"
	@echo "  make waves DUT=... TEST=... - run with VCD dump (logs/waves.vcd)"
	@echo "  make list                - print variables"
	@echo "  make clean / distclean   - cleanup (distclean removes uvm-verilator)"
