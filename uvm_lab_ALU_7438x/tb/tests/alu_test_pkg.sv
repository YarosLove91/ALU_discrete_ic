// ============================================================
// File    : alu_test_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Test package: base test (objections, drain, LAB_RESULT
// verdict) and concrete tests. Depends on all lab packages:
// alu_tb_pkg (golden sanity, counters), alu_agent_pkg,
// alu_seq_pkg (sequences), alu_env_pkg (environment).
// ============================================================
`ifndef ALU_TEST_PKG_SV
`define ALU_TEST_PKG_SV

package alu_test_pkg;

  import uvm_pkg::*;
  import alu_tb_pkg::*;
  import alu_agent_pkg::*;
  import alu_seq_pkg::*;
  import alu_env_pkg::*;

  `include "uvm_macros.svh"

  // the base test must be included first
  `include "alu_base_test.sv"
  `include "alu_sanity_test.sv"
  `include "alu_ds_test.sv"
  `include "alu_exhaustive_test.sv"
  `include "alu_corner_test.sv"
  `include "alu_random_test.sv"
  `include "alu_smoke_test.sv"

endpackage : alu_test_pkg

`endif // ALU_TEST_PKG_SV
