// ============================================================
// File    : alu_random_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Constrained-random stress test: +NUM_TRANSACTIONS vectors
// (default 1000) with corner-weighted operand distribution
// (0 and ALL_ONES at 10% each). Reproducible via
// +verilator+seed+<N>.
// ============================================================

  class alu_random_test extends alu_base_test;
    `uvm_component_utils(alu_random_test)

    function new(string name = "alu_random_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual task body_seq();
      alu_random_seq seq;
      int unsigned n;
      n = 1000;
      void'($value$plusargs("NUM_TRANSACTIONS=%d", n));
      seq = alu_random_seq::type_id::create("seq");
      seq.num_items = n;
      seq.start(env_h.agt.sqr);
    endtask : body_seq

  endclass : alu_random_test
