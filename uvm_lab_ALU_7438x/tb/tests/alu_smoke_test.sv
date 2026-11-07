// ============================================================
// File    : alu_smoke_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Smoke test (lab stage 0): 20 random transactions to prove the
// environment is alive end-to-end (driver -> DUT -> monitor ->
// refmodel -> scoreboard). Default test of run_test() in
// alu_tb_top; transaction count overridable via
// +NUM_TRANSACTIONS.
// ============================================================

  class alu_smoke_test extends alu_base_test;
    `uvm_component_utils(alu_smoke_test)

    function new(string name = "alu_smoke_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual task body_seq();
      alu_random_seq seq;
      int unsigned n;
      n = 20;
      void'($value$plusargs("NUM_TRANSACTIONS=%d", n));
      seq = alu_random_seq::type_id::create("seq");
      seq.num_items = n;
      seq.start(env_h.agt.sqr);
    endtask : body_seq

  endclass : alu_smoke_test
