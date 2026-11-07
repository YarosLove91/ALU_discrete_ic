// ============================================================
// File    : alu_sequencer.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Sequencer: plain uvm_sequencer parameterized with
// alu_transaction.
// ============================================================
  class alu_sequencer extends uvm_sequencer #(alu_transaction);
    `uvm_component_utils(alu_sequencer)

    function new(string name = "alu_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

  endclass : alu_sequencer
