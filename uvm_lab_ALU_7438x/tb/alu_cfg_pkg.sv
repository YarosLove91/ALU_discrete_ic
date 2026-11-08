// ============================================================
// File    : alu_cfg_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Compile-time configuration package (head of the dependency
// chain). Single source of truth for all testbench knobs:
// edit the localparam values below - the Makefile rebuilds the
// DUT automatically (the package is a build dependency).
//
// Feature bits (1 = enabled, 0 = disabled):
//   COVERAGE_EN      - functional coverage collection/report
//   RFM_XCHECK_EN    - 16-bit golden-model cross-check
//   SCB_MATCH_LOG_EN - per-match UVM_HIGH scoreboard logging
//   USE_CPP_REF      - golden model: 0 = SystemVerilog,
//                      1 = C++ via DPI-C (ref_model/dpi/)
// Numeric knobs:
//   NUM_TRANSACTIONS   - alu_random_test vector count
//   SMOKE_TRANSACTIONS - alu_smoke_test vector count
//   SCB_MAX_LOG        - detailed mismatch log cap
//
// Only the DUT selection stays conditional-compilation based:
// it is structural - tb/alu_tb_top.sv instantiates different
// RTL under the same +define+DUT_<...> passed by the Makefile.
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
  // Feature config bits (edit the values here)
  // --------------------------------------------------------
  localparam bit COVERAGE_EN      = 1'b1;  // functional coverage collector
  localparam bit RFM_XCHECK_EN    = 1'b1;  // 16-bit golden-model cross-check
  localparam bit SCB_MATCH_LOG_EN = 1'b1;  // per-match scoreboard logging
  localparam bit USE_CPP_REF      = 1'b0;  // 0 = SV golden, 1 = C++ DPI golden

  // --------------------------------------------------------
  // Numeric knobs (edit the values here)
  // --------------------------------------------------------
  localparam int unsigned NUM_TRANSACTIONS   = 1000;  // alu_random_test vectors
  localparam int unsigned SMOKE_TRANSACTIONS = 20;    // alu_smoke_test vectors
  localparam int unsigned SCB_MAX_LOG        = 20;    // mismatch log cap

endpackage : alu_cfg_pkg

`endif // ALU_CFG_PKG_SV
