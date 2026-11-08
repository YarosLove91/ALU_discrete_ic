// ============================================================
// File    : alu_random_vseq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Random virtual sequence: scenario wrapper starting the real
// alu_random_seq on the agent sequencer (p_sequencer.sqr).
// Item count is set by the test (SMOKE_TRANSACTIONS /
// NUM_TRANSACTIONS from alu_cfg_pkg). Tests stay thin: they
// create this vseq and start it on env.v_sqr.
// ============================================================
  class alu_random_vseq extends alu_base_vseq;
    `uvm_object_utils(alu_random_vseq)

    int unsigned num_items = 1000;

    function new(string name = "alu_random_vseq");
      super.new(name);
    endfunction : new

    task body();
      alu_random_seq seq;
      seq = alu_random_seq::type_id::create("seq");
      seq.num_items = num_items;
      seq.start(p_sequencer.sqr);
    endtask : body

  endclass : alu_random_vseq
