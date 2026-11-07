// ============================================================
// File    : alu_exhaustive_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Exhaustive test (lab stage 4): applies the complete 4-bit
// input space (8 ops x 2 Cn x 16 A x 16 B = 4096 vectors).
// 4-bit DUTs only - the sequence fatals out for 16-bit widths.
// On the shipped alu_74382.sv RTL this test exposes the OVR
// defect (231 mismatches); see README stages 4-5.
// ============================================================

  class alu_exhaustive_test extends alu_base_test;
    `uvm_component_utils(alu_exhaustive_test)

    function new(string name = "alu_exhaustive_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual task body_seq();
      alu_exhaustive_seq seq;
      seq = alu_exhaustive_seq::type_id::create("seq");
      seq.start(env_h.agt.sqr);
    endtask : body_seq

  endclass : alu_exhaustive_test
