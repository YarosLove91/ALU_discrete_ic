// ============================================================
// File    : alu_base_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Base sequence: common send() helper building a non-random
// alu_transaction and pushing it through start_item/finish_item.
// All lab sequences derive from it. Defaults address R0 (operand
// A) and R1 (operand B) over the register path.
// ============================================================

  class alu_base_seq extends uvm_sequence #(alu_transaction);
    `uvm_object_utils(alu_base_seq)

    function new(string name = "alu_base_seq");
      super.new(name);
    endfunction : new

    task send(bit [15:0] a, bit [15:0] b, bit cin, bit mode, bit [3:0] sel,
              bit b_source = 1'b0, bit [2:0] ra1 = 3'd0, bit [2:0] ra2 = 3'd1);
      alu_transaction tr;
      tr = alu_transaction::type_id::create("tr");
      start_item(tr);
      tr.a        = a;
      tr.b        = b;
      tr.cin      = cin;
      tr.mode     = mode;
      tr.sel      = sel;
      tr.b_source = b_source;
      tr.ra1      = ra1;
      tr.ra2      = ra2;
      finish_item(tr);
    endtask : send

  endclass : alu_base_seq
