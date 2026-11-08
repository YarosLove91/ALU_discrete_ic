// ============================================================
// File    : alu_base_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
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

    task send(bit [15:0] a, bit [15:0] b, bit cin, bit mode, bit [3:0] sel);
      alu_transaction tr;
      tr = alu_transaction::type_id::create("tr");
      start_item(tr);
      tr.a    = a;
      tr.b    = b;
      tr.cin  = cin;
      tr.mode = mode;
      tr.sel  = sel;
      finish_item(tr);
    endtask : send

  endclass : alu_base_seq
