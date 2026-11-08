// ============================================================
// File    : alu_smoke_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Smoke test (lab stage 0): SMOKE_TRANSACTIONS random vectors
// (alu_cfg_pkg, default 20) to prove the environment is alive
// end-to-end (driver -> DUT -> monitor -> refmodel ->
// scoreboard). Default test of run_test() in alu_tb_top.
// ============================================================

  class alu_smoke_test extends alu_base_test;
    `uvm_component_utils(alu_smoke_test)

    function new(string name = "alu_smoke_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual task body_seq();
      alu_random_seq seq;
      seq = alu_random_seq::type_id::create("seq");
      seq.num_items = SMOKE_TRANSACTIONS;  // alu_cfg_pkg (override: make SMOKE_N=<count>)
      seq.start(env_h.agt.sqr);
    endtask : body_seq

  endclass : alu_smoke_test
