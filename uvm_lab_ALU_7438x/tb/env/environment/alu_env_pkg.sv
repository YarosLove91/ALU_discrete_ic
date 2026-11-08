// ============================================================
// File    : alu_env_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Environment package: reference model (predictor), scoreboard,
// functional coverage collector and the env assembling them with
// the agent. Depends on alu_tb_pkg (golden models, counters) and
// alu_agent_pkg (transaction/agent types).
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
  `include "alu_env.sv"

endpackage : alu_env_pkg

`endif // ALU_ENV_PKG_SV
