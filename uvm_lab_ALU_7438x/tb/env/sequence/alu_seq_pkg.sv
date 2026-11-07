// ============================================================
// File    : alu_seq_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Sequence package: sequence item (alu_transaction), base
// sequence and the stimulus library (datasheet replay /
// exhaustive / corner / random). Depends on alu_tb_pkg
// (parameters) only - the agent package imports this one.
// ============================================================
`ifndef ALU_SEQ_PKG_SV
`define ALU_SEQ_PKG_SV

package alu_seq_pkg;

import uvm_pkg::*;
import alu_tb_pkg::*;

  `include "uvm_macros.svh"

  `include "alu_transaction.sv"
  // the base sequence must be included first
  `include "alu_base_seq.sv"
  `include "alu_ds_seq.sv"
  `include "alu_exhaustive_seq.sv"
  `include "alu_corner_seq.sv"
  `include "alu_random_seq.sv"

endpackage : alu_seq_pkg

`endif // ALU_SEQ_PKG_SV
