// ============================================================
// File    : alu_agent_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Agent package: sequencer, driver, monitor and the agent.
// The sequence item (alu_transaction) lives in alu_seq_pkg, so
// the dependency chain is: alu_tb_pkg -> alu_seq_pkg ->
// alu_agent_pkg.
// ============================================================
`ifndef ALU_AGENT_PKG_SV
`define ALU_AGENT_PKG_SV

package alu_agent_pkg;

    import uvm_pkg::*;
    import alu_tb_pkg::*;
    import alu_seq_pkg::*;

    `include "uvm_macros.svh"

    `include "alu_sequencer.sv"
    `include "alu_driver.sv"
    `include "alu_monitor.sv"
    `include "alu_agent.sv"

endpackage : alu_agent_pkg

`endif // ALU_AGENT_PKG_SV
