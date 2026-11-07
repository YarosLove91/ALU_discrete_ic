// ============================================================
// File    : alu_corner_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Corner test: all pairs of boundary operand values
// {0, 1, MAX_POS, MIN_NEG, ALL_ONES-1, ALL_ONES} across all
// 8 operations and both Cn values (6 x 6 x 8 x 2 = 576
// vectors). Targets carry/overflow boundaries of the signed
// range; closes functional coverage to 100%.
// ============================================================

  class alu_corner_test extends alu_base_test;
    `uvm_component_utils(alu_corner_test)

    function new(string name = "alu_corner_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual task body_seq();
      alu_corner_seq seq;
      seq = alu_corner_seq::type_id::create("seq");
      seq.start(env_h.agt.sqr);
    endtask : body_seq

  endclass : alu_corner_test
