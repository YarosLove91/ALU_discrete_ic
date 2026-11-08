// ============================================================
// File    : alu_cfg_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Compile-time configuration package (head of the dependency
// chain). Every knob below can be overridden from the Makefile
// via defines without editing the code, e.g.:
//   make run DUT=74382 TEST=alu_random_test N=5000 COV=0
// (the Makefile turns them into +define+<NAME>=<value> flags)
//
// Feature bits (1 = enabled, 0 = disabled):
//   COVERAGE_EN      - functional coverage collection/report
//   RFM_XCHECK_EN    - 16-bit golden-model cross-check
//   SCB_MATCH_LOG_EN - per-match UVM_HIGH scoreboard logging
//   USE_CPP_REF      - golden model: 0 = SV (default), 1 = C++ DPI-C
// Numeric knobs:
//   NUM_TRANSACTIONS   - alu_random_test vector count
//   SMOKE_TRANSACTIONS - alu_smoke_test vector count
//   SCB_MAX_LOG        - detailed mismatch log cap
// ============================================================
`ifndef ALU_CFG_PKG_SV
`define ALU_CFG_PKG_SV

package alu_cfg_pkg;

  // --------------------------------------------------------
  // DUT selection (set by the Makefile: +define+DUT_<...>)
  // --------------------------------------------------------
  typedef enum { DUT_381_4, DUT_382_4, DUT_381_16, DUT_382_16 } dut_kind_e;

`ifdef DUT_74381
  localparam dut_kind_e DUT_KIND = DUT_381_4;
  localparam int        W        = 4;
`elsif DUT_74382
  localparam dut_kind_e DUT_KIND = DUT_382_4;
  localparam int        W        = 4;
`elsif DUT_74381_16
  localparam dut_kind_e DUT_KIND = DUT_381_16;
  localparam int        W        = 16;
`elsif DUT_74382_16
  localparam dut_kind_e DUT_KIND = DUT_382_16;
  localparam int        W        = 16;
`else
  localparam dut_kind_e DUT_KIND = DUT_381_4;
  localparam int        W        = 4;
`endif

  // Derived width constants
  localparam bit [W-1:0] ALL_ONES = {W{1'b1}};
  localparam bit [W-1:0] MIN_NEG  = {1'b1, {(W-1){1'b0}}};  // 0x8 / 0x8000
  localparam bit [W-1:0] MAX_POS  = ~MIN_NEG;                // 0x7 / 0x7FFF
  localparam bit         FAM_382  = (DUT_KIND == DUT_382_4) || (DUT_KIND == DUT_382_16);

  // --------------------------------------------------------
  // Feature config bits
  // --------------------------------------------------------
`ifndef COVERAGE_EN
  `define COVERAGE_EN 1
`endif
  localparam bit COVERAGE_EN = `COVERAGE_EN;

`ifndef RFM_XCHECK_EN
  `define RFM_XCHECK_EN 1
`endif
  localparam bit RFM_XCHECK_EN = `RFM_XCHECK_EN;

`ifndef SCB_MATCH_LOG_EN
  `define SCB_MATCH_LOG_EN 1
`endif
  localparam bit SCB_MATCH_LOG_EN = `SCB_MATCH_LOG_EN;

  // Golden model selection: 0 = SystemVerilog model (default),
  // 1 = C++ model via DPI-C (tb/ref_model/dpi/alu_golden_dpi.cpp)
`ifndef USE_CPP_REF
  `define USE_CPP_REF 0
`endif
  localparam bit USE_CPP_REF = `USE_CPP_REF;

  // --------------------------------------------------------
  // Numeric knobs
  // --------------------------------------------------------
`ifndef NUM_TRANSACTIONS
  `define NUM_TRANSACTIONS 1000
`endif
  localparam int unsigned NUM_TRANSACTIONS = `NUM_TRANSACTIONS;

`ifndef SMOKE_TRANSACTIONS
  `define SMOKE_TRANSACTIONS 20
`endif
  localparam int unsigned SMOKE_TRANSACTIONS = `SMOKE_TRANSACTIONS;

`ifndef SCB_MAX_LOG
  `define SCB_MAX_LOG 20
`endif
  localparam int unsigned SCB_MAX_LOG = `SCB_MAX_LOG;

endpackage : alu_cfg_pkg

`endif // ALU_CFG_PKG_SV
