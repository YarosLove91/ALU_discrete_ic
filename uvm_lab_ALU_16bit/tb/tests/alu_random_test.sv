// ============================================================
// File    : alu_random_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Constrained-random stress test: NUM_TRANSACTIONS vectors
// (alu_cfg_pkg: default 1000 in the file, override via
// make N=<count>) with corner-weighted operand distribution
// (0 and ALL_ONES at 10% each). Reproducible via
// +verilator+seed+<N>.
// ============================================================

  class alu_random_test extends alu_base_test;
    `uvm_component_utils(alu_random_test)

    function new(string name = "alu_random_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual task body_seq();
      alu_random_vseq vseq;
      vseq = alu_random_vseq::type_id::create("vseq");
      vseq.num_items = NUM_TRANSACTIONS;  // alu_cfg_pkg (override: make N=<count>)
      vseq.start(env_h.v_sqr);
    endtask : body_seq

  endclass : alu_random_test
