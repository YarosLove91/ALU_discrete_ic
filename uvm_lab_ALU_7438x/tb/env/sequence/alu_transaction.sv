// ============================================================
// File    : alu_transaction.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// ALU transaction: stimuli (a, b, s, cn), observed DUT outputs
// (f, p, g, ovr, cn4) and golden-model expectations (exp_*).
// ============================================================
  class alu_transaction extends uvm_sequence_item;

    // ---- stimuli ----
    rand bit [W-1:0] a;
    rand bit [W-1:0] b;
    rand bit [2:0]   s;
    rand bit         cn;

    // ---- actual DUT outputs (filled by the monitor) ----
    bit [W-1:0] f;
    bit         p;
    bit         g;
    bit         ovr;
    bit         cn4;

    // ---- expected outputs (filled by the reference model) ----
    bit [W-1:0] exp_f;
    bit         exp_p;
    bit         exp_g;
    bit         exp_ovr;
    bit         exp_cn4;

    // ---- housekeeping ----
    int unsigned id;

    `uvm_object_utils_begin(alu_transaction)
      `uvm_field_int(id,      UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(a,       UVM_ALL_ON)
      `uvm_field_int(b,       UVM_ALL_ON)
      `uvm_field_int(s,       UVM_ALL_ON)
      `uvm_field_int(cn,      UVM_ALL_ON)
      `uvm_field_int(f,       UVM_ALL_ON)
      `uvm_field_int(p,       UVM_ALL_ON)
      `uvm_field_int(g,       UVM_ALL_ON)
      `uvm_field_int(ovr,     UVM_ALL_ON)
      `uvm_field_int(cn4,     UVM_ALL_ON)
      `uvm_field_int(exp_f,   UVM_ALL_ON)
      `uvm_field_int(exp_p,   UVM_ALL_ON)
      `uvm_field_int(exp_g,   UVM_ALL_ON)
      `uvm_field_int(exp_ovr, UVM_ALL_ON)
      `uvm_field_int(exp_cn4, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "alu_transaction");
      super.new(name);
    endfunction : new

    // operation name comes straight from the alu_op_e enum (.name())
    function string inputs2str();
        alu_op_e op;
        op = alu_op_e'(s);
        return $sformatf("op=%-8s s=%0b cn=%0b a=%0h b=%0h",
            op.name(), s, cn, a, b);
    endfunction : inputs2str

    function string outputs2str();
      return $sformatf("f=%0h p=%0b g=%0b ovr=%0b cn4=%0b", f, p, g, ovr, cn4);
    endfunction : outputs2str

  endclass : alu_transaction
