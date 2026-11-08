// ============================================================
// File    : alu_transaction.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// CPU-level transaction. Payload is carried by the packed
// structs from alu_tb_pkg:
//   stim - stimuli (driver intent): a is written into R[ra1]; b
//          is written into R[ra2] (register path) or driven on
//          alu_b_imm (immediate path, b_source = 1); cin/mode/sel
//          select the ALU operation (active-LOW cin)
//   act  - actual DUT outputs (filled by the monitor)
//   exp  - expectations: exp.result from the reference model,
//          exp.rdata1/2 from the monitor shadow register file
// ============================================================
  class alu_transaction extends uvm_sequence_item;

    // ---- payload ----
    rand alu_stim_t stim;   // stimuli (driver intent)
    alu_outs_t      act;    // actual DUT outputs (monitor)
    alu_outs_t      exp;    // expected outputs (refmodel + monitor shadow)

    // ---- housekeeping ----
    int unsigned id;

    `uvm_object_utils_begin(alu_transaction)
      `uvm_field_int(id,   UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(stim, UVM_ALL_ON)
      `uvm_field_int(act,  UVM_ALL_ON)
      `uvm_field_int(exp,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "alu_transaction");
      super.new(name);
    endfunction : new

    // operation name comes straight from the alu_op_e enum (.name())
    function string inputs2str();
        alu_op_e op;
        op = alu_op_e'({stim.mode, stim.sel});
        return $sformatf("op=%s mode=%0b sel=%0b cin=%0b a=%0h b=%0h bsrc=%0b ra1=%0d ra2=%0d",
            op.name(), stim.mode, stim.sel, stim.cin, stim.a, stim.b,
            stim.b_source, stim.ra1, stim.ra2);
    endfunction : inputs2str

    function string outputs2str();
      return $sformatf("rdata1=%0h rdata2=%0h result=%0h cout=%0b nbo=%0b ngo=%0b",
          act.rdata1, act.rdata2, act.result, act.cout, act.nbo, act.ngo);
    endfunction : outputs2str

  endclass : alu_transaction
