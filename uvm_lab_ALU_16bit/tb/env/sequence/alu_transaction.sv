// ============================================================
// File    : alu_transaction.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// ALU transaction: stimuli (a, b, cin, mode, sel), observed DUT
// outputs (result, cout, nbo, ngo, half_carry, overflow) and the
// golden-model expectation (exp_result).
//
// The scoreboard currently checks result (the golden model after
// tb_alu_16.cpp computes result); the remaining DUT outputs are
// captured by the monitor for waveforms and future checks.
// ============================================================
  class alu_transaction extends uvm_sequence_item;

    // ---- stimuli ----
    rand bit [15:0] a;
    rand bit [15:0] b;
    rand bit        cin;
    rand bit        mode;
    rand bit [3:0]  sel;

    // ---- actual DUT outputs (filled by the monitor) ----
    bit [15:0] result;
    bit        cout;
    bit        nbo;
    bit        ngo;
    bit        half_carry;
    bit        overflow;

    // ---- expected outputs (filled by the reference model) ----
    bit [15:0] exp_result;

    // ---- housekeeping ----
    int unsigned id;

    `uvm_object_utils_begin(alu_transaction)
      `uvm_field_int(id,         UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(a,          UVM_ALL_ON)
      `uvm_field_int(b,          UVM_ALL_ON)
      `uvm_field_int(cin,        UVM_ALL_ON)
      `uvm_field_int(mode,       UVM_ALL_ON)
      `uvm_field_int(sel,        UVM_ALL_ON)
      `uvm_field_int(result,     UVM_ALL_ON)
      `uvm_field_int(cout,       UVM_ALL_ON)
      `uvm_field_int(nbo,        UVM_ALL_ON)
      `uvm_field_int(ngo,        UVM_ALL_ON)
      `uvm_field_int(half_carry, UVM_ALL_ON)
      `uvm_field_int(overflow,   UVM_ALL_ON)
      `uvm_field_int(exp_result, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "alu_transaction");
      super.new(name);
    endfunction : new

    // operation name comes straight from the alu_op_e enum (.name())
    function string inputs2str();
        alu_op_e op;
        op = alu_op_e'({mode, sel});
        return $sformatf("op=%-30s mode=%0b sel=%04b cin=%0b a=%04h b=%04h",
            op.name(), mode, sel, cin, a, b);
    endfunction : inputs2str

    function string outputs2str();
      return $sformatf("result=%04h cout=%0b nbo=%0b ngo=%0b hc=%0b ovr=%0b",
          result, cout, nbo, ngo, half_carry, overflow);
    endfunction : outputs2str

  endclass : alu_transaction
