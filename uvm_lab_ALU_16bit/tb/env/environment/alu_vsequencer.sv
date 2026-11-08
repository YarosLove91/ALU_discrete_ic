// ============================================================
// File    : alu_vsequencer.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Virtual sequencer (Sunburst Design virtual-sequence pattern):
// a component-level sequencer that does not generate items
// itself but holds handles to the real agent sequencers, so a
// virtual sequence can coordinate scenarios across agents.
// The lab has a single agent, so one handle is enough:
//   sqr - alu_sequencer of alu_agent (wired in alu_env
//         connect_phase: v_sqr.sqr = agt.sqr).
// ============================================================
  class alu_vsequencer extends uvm_sequencer #(uvm_sequence_item);
    `uvm_component_utils(alu_vsequencer)

    // handle to the real (agent) sequencer, assigned by alu_env
    alu_sequencer sqr;

    function new(string name = "alu_vsequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

  endclass : alu_vsequencer
