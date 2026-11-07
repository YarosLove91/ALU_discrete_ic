// ============================================================
// File    : alu_base_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Base sequence: common send() helper building a non-random
// alu_transaction and pushing it through start_item/finish_item.
// All lab sequences derive from it.
// ============================================================

  class alu_base_seq extends uvm_sequence #(alu_transaction);
    `uvm_object_utils(alu_base_seq)

    function new(string name = "alu_base_seq");
      super.new(name);
    endfunction : new

    task send(bit [W-1:0] a, bit [W-1:0] b, bit [2:0] s, bit cn);
      alu_transaction tr;
      tr = alu_transaction::type_id::create("tr");
      start_item(tr);
      tr.a  = a;
      tr.b  = b;
      tr.s  = s;
      tr.cn = cn;
      finish_item(tr);
    endtask : send

  endclass : alu_base_seq
