// ============================================================
// File    : alu_cfg_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Compile-time configuration package (head of the dependency
// chain).
//
// Each knob has TWO configuration channels:
//   1. default - the literal in the `else branch below
//      (edit it in this file; rebuild triggers automatically);
//   2. override - from the Makefile without editing any file:
//        make rand N=5000 COV=0 CPPREF=1 ...
//      the Makefile passes +define+ALU_CFG_<NAME>=<value> only
//      for knobs explicitly set on the command line.
//
// Feature bits (1 = enabled, 0 = disabled):
//   COVERAGE_EN      - functional coverage collection/report
//   RFM_XCHECK_EN    - reference-model arithmetic cross-check
//   SCB_MATCH_LOG_EN - per-match UVM_HIGH scoreboard logging
//   USE_CPP_REF      - golden model: 0 = SystemVerilog,
//                      1 = C++ via DPI-C (ref_model/dpi/)
// Numeric knobs:
//   NUM_TRANSACTIONS   - alu_random_test vector count
//   SMOKE_TRANSACTIONS - alu_smoke_test vector count
//   SCB_MAX_LOG        - detailed mismatch log cap
//
// The lab has a single DUT (alu16, W = 16), so no DUT-selection
// conditional compilation is required.
// ============================================================
`ifndef ALU_CFG_PKG_SV
`define ALU_CFG_PKG_SV

package alu_cfg_pkg;

  // --------------------------------------------------------
  // Fixed data width of the alu16 DUT
  // --------------------------------------------------------
  localparam int W = 16;

  // Derived width constants
  localparam bit [W-1:0] ALL_ONES = {W{1'b1}};
  localparam bit [W-1:0] MIN_NEG  = {1'b1, {(W-1){1'b0}}};  // 0x8000
  localparam bit [W-1:0] MAX_POS  = ~MIN_NEG;                // 0x7FFF

  // --------------------------------------------------------
  // Feature config bits
  // --------------------------------------------------------
`ifdef ALU_CFG_COVERAGE_EN
  localparam bit COVERAGE_EN = `ALU_CFG_COVERAGE_EN;
`else
  localparam bit COVERAGE_EN = 1'b1;  // functional coverage collector
`endif

`ifdef ALU_CFG_RFM_XCHECK_EN
  localparam bit RFM_XCHECK_EN = `ALU_CFG_RFM_XCHECK_EN;
`else
  localparam bit RFM_XCHECK_EN = 1'b0;  // reference-model cross-check
`endif

`ifdef ALU_CFG_SCB_MATCH_LOG_EN
  localparam bit SCB_MATCH_LOG_EN = `ALU_CFG_SCB_MATCH_LOG_EN;
`else
  localparam bit SCB_MATCH_LOG_EN = 1'b1;  // per-match scoreboard logging
`endif

`ifdef ALU_CFG_USE_CPP_REF
  localparam bit USE_CPP_REF = `ALU_CFG_USE_CPP_REF;
`else
  localparam bit USE_CPP_REF = 1'b0;  // 0 = SV golden, 1 = C++ DPI golden
`endif

  // --------------------------------------------------------
  // Numeric knobs
  // --------------------------------------------------------
`ifdef ALU_CFG_NUM_TRANSACTIONS
  localparam int unsigned NUM_TRANSACTIONS = `ALU_CFG_NUM_TRANSACTIONS;
`else
  localparam int unsigned NUM_TRANSACTIONS = 1000;  // alu_random_test vectors
`endif

`ifdef ALU_CFG_SMOKE_TRANSACTIONS
  localparam int unsigned SMOKE_TRANSACTIONS = `ALU_CFG_SMOKE_TRANSACTIONS;
`else
  localparam int unsigned SMOKE_TRANSACTIONS = 20;  // alu_smoke_test vectors
`endif

`ifdef ALU_CFG_SCB_MAX_LOG
  localparam int unsigned SCB_MAX_LOG = `ALU_CFG_SCB_MAX_LOG;
`else
  localparam int unsigned SCB_MAX_LOG = 20;  // detailed mismatch log cap
`endif

endpackage : alu_cfg_pkg

`endif // ALU_CFG_PKG_SV
