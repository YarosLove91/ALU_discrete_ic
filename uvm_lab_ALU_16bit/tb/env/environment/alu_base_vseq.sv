// ============================================================
// File    : alu_base_vseq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Base virtual sequence (Sunburst Design pattern): started on
// the virtual sequencer (alu_vsequencer), never sends items
// itself - it coordinates real sequences started on the agent
// sequencers reachable through p_sequencer. The p_sequencer
// handle is created by `uvm_declare_p_sequencer (typed $cast of
// m_sequencer), so concrete vseqs address p_sequencer.sqr
// directly.
// ============================================================
  class alu_base_vseq extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(alu_base_vseq)
    `uvm_declare_p_sequencer(alu_vsequencer)

    function new(string name = "alu_base_vseq");
      super.new(name);
    endfunction : new

  endclass : alu_base_vseq
