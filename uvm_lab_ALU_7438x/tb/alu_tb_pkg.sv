// ============================================================
// File    : alu_tb_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Common testbench package: operation enum, virtual interface
// type, global verdict counters and golden (reference) models
// with datasheet truth tables (`includes from tb/ref_model/).
// All compile-time configuration lives in alu_cfg_pkg.
// UVM classes live in the local packages:
//   alu_seq_pkg (tb/env/sequence), alu_agent_pkg (tb/env/agent),
//   alu_env_pkg (tb/env/environment), alu_test_pkg (tb/tests).
// ============================================================
`ifndef ALU_TB_PKG_SV
`define ALU_TB_PKG_SV

package alu_tb_pkg;

  import uvm_pkg::*;
  import alu_cfg_pkg::*;

  `include "uvm_macros.svh"

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
  // Golden (reference) models and datasheet truth tables
  // --------------------------------------------------------
  `include "alu_ds_tables.sv"   // ds_row_t, ds381_row, ds382_row
  `include "golden_381.sv"      // golden_381, golden_381_w16
  `include "golden_382.sv"      // golden_382, golden_382_w16
  `include "golden_sanity.sv"   // run_golden_sanity (self-check)

endpackage : alu_tb_pkg

`endif // ALU_TB_PKG_SV
