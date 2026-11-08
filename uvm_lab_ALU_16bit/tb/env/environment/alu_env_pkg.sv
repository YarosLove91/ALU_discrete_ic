// ============================================================
// File    : alu_env_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Environment package: reference model (predictor), scoreboard,
// functional coverage collector, virtual sequencer + virtual
// sequences (Sunburst Design pattern) and the env assembling
// them with the agent. Depends on alu_tb_pkg (golden model,
// counters) and alu_agent_pkg (transaction/agent types).
// ============================================================
`ifndef ALU_ENV_PKG_SV
`define ALU_ENV_PKG_SV

package alu_env_pkg;

  import uvm_pkg::*;
  import alu_cfg_pkg::*;
  import alu_tb_pkg::*;
  import alu_seq_pkg::*;
  import alu_agent_pkg::*;

  `include "uvm_macros.svh"

  `include "alu_ref_model.sv"
  `include "alu_scoreboard.sv"
  `include "alu_coverage.sv"
  // the virtual sequencer must precede the virtual sequences
  `include "alu_vsequencer.sv"
  `include "alu_base_vseq.sv"
  `include "alu_random_vseq.sv"
  `include "alu_env.sv"

endpackage : alu_env_pkg

`endif // ALU_ENV_PKG_SV
