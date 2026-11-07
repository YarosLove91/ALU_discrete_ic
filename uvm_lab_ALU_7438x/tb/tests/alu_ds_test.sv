// ============================================================
// File    : alu_ds_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Directed datasheet test (lab stage 3): replays all 64 truth
// table vectors (sel x {Cn, An, Bn}, An/Bn in {0000, 1111})
// through the DUT; scoreboard compares every output against the
// golden model. For 16-bit chains the corner patterns are
// replicated across all slices.
// ============================================================

  class alu_ds_test extends alu_base_test;
    `uvm_component_utils(alu_ds_test)

    function new(string name = "alu_ds_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual task body_seq();
      alu_ds_seq seq;
      seq = alu_ds_seq::type_id::create("seq");
      seq.start(env_h.agt.sqr);
    endtask : body_seq

  endclass : alu_ds_test
