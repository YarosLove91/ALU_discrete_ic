// ============================================================
// File    : alu_tb_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Testbench package: DUT selection (compile-time define from
// the Makefile), shared parameters/typedefs, verdict counters,
// and `includes of the reference model (tb/ref_model/), UVM
// environment classes (tb/env/) and tests (tb/tests/).
// ============================================================
`ifndef ALU_TB_PKG_SV
`define ALU_TB_PKG_SV

package alu_tb_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

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

  localparam bit [W-1:0] ALL_ONES = {W{1'b1}};
  localparam bit [W-1:0] MIN_NEG  = {1'b1, {(W-1){1'b0}}};  // 0x8 / 0x8000
  localparam bit [W-1:0] MAX_POS  = ~MIN_NEG;                // 0x7 / 0x7FFF
  localparam bit         FAM_382  = (DUT_KIND == DUT_382_4) || (DUT_KIND == DUT_382_16);

  // Operation encoding shared by both families (Function Select Table)
  typedef enum bit [2:0] {
    OP_CLEAR   = 3'b000,
    OP_B_SUB_A = 3'b001,
    OP_A_SUB_B = 3'b010,
    OP_ADD     = 3'b011,
    OP_XOR     = 3'b100,
    OP_OR      = 3'b101,
    OP_AND     = 3'b110,
    OP_PRESET  = 3'b111
  } alu_op_e;

  // Virtual interface type (instantiated in alu_tb_top)
  typedef virtual alu_if #(W) alu_vif;

  // --------------------------------------------------------
  // Global verdict counters (a teaching simplification; a
  // production env would use uvm_report_server / config_db)
  // --------------------------------------------------------
  int unsigned g_item_id         = 0;
  int unsigned g_scb_checked     = 0;
  int unsigned g_scb_matches     = 0;
  int unsigned g_scb_mismatches  = 0;
  int unsigned g_sanity_checks   = 0;
  int unsigned g_sanity_errors   = 0;
  int unsigned g_refmodel_errors = 0;

  // --------------------------------------------------------
  // Printable operation name (for logs)
  // --------------------------------------------------------
  function automatic string alu_op_name(bit [2:0] s);
    case (alu_op_e'(s))
      OP_CLEAR   : return "CLEAR ";
      OP_B_SUB_A : return "B-A   ";
      OP_A_SUB_B : return "A-B   ";
      OP_ADD     : return "A+B   ";
      OP_XOR     : return "A^B   ";
      OP_OR      : return "A|B   ";
      OP_AND     : return "A&B   ";
      OP_PRESET  : return "PRESET";
      default    : return "??????"; // TODO: Make UVM_ERROR
    endcase
  endfunction : alu_op_name

// --------------------------------------------------------
// Golden (reference) models and datasheet truth tables
// --------------------------------------------------------
`include "alu_ds_tables.sv"   // ds_row_t, ds381_row, ds382_row
`include "golden_381.sv"      // golden_381, golden_381_w16
`include "golden_382.sv"      // golden_382, golden_382_w16
`include "golden_sanity.sv"   // run_golden_sanity (self-check)

// --------------------------------------------------------
// UVM environment classes
// --------------------------------------------------------
`include "alu_transaction.sv"
`include "alu_sequencer.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_agent.sv"
`include "alu_ref_model.sv"
`include "alu_scoreboard.sv"
`include "alu_coverage.sv"
`include "alu_env.sv"
`include "alu_seq_lib.sv"

// --------------------------------------------------------
// Tests (the base test must be included first)
// --------------------------------------------------------
`include "alu_base_test.sv"
`include "alu_sanity_test.sv"
`include "alu_ds_test.sv"
`include "alu_exhaustive_test.sv"
`include "alu_corner_test.sv"
`include "alu_random_test.sv"
`include "alu_smoke_test.sv"

endpackage : alu_tb_pkg

`endif // ALU_TB_PKG_SV
