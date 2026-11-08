// ============================================================
// File    : alu_transaction.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// CPU-level transaction.
//
// Stimuli (driver intent):
//   a, b       - operand values: a is written into R[ra1]; b is
//                written into R[ra2] (register path) or driven on
//                alu_b_imm (immediate path, b_source = 1)
//   cin/mode/sel - ALU operation (active-LOW cin)
//   b_source   - operand B source select
//   ra1/ra2    - register file addresses
//
// Observed DUT outputs (filled by the monitor):
//   rdata1/rdata2 - operands actually presented to the ALU
//   b_imm         - sampled immediate operand
//   result/cout/nbo/ngo - ALU outputs
//
// Expectations:
//   exp_result      - golden model (from the sampled operands)
//   exp_rdata1/2    - monitor shadow register file (write history)
// ============================================================
  class alu_transaction extends uvm_sequence_item;

    // ---- stimuli ----
    rand bit [15:0] a;
    rand bit [15:0] b;
    rand bit        cin;
    rand bit        mode;
    rand bit [3:0]  sel;
    rand bit        b_source;
    rand bit [2:0]  ra1;
    rand bit [2:0]  ra2;

    // ---- actual DUT outputs (filled by the monitor) ----
    bit [15:0] rdata1;
    bit [15:0] rdata2;
    bit [15:0] b_imm;
    bit [15:0] result;
    bit        cout;
    bit        nbo;
    bit        ngo;

    // ---- expected outputs ----
    bit [15:0] exp_result;   // filled by the reference model
    bit [15:0] exp_rdata1;   // filled by the monitor (shadow RF)
    bit [15:0] exp_rdata2;   // filled by the monitor (shadow RF)

    // ---- housekeeping ----
    int unsigned id;

    `uvm_object_utils_begin(alu_transaction)
      `uvm_field_int(id,         UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(a,          UVM_ALL_ON)
      `uvm_field_int(b,          UVM_ALL_ON)
      `uvm_field_int(cin,        UVM_ALL_ON)
      `uvm_field_int(mode,       UVM_ALL_ON)
      `uvm_field_int(sel,        UVM_ALL_ON)
      `uvm_field_int(b_source,   UVM_ALL_ON)
      `uvm_field_int(ra1,        UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(ra2,        UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(rdata1,     UVM_ALL_ON)
      `uvm_field_int(rdata2,     UVM_ALL_ON)
      `uvm_field_int(b_imm,      UVM_ALL_ON)
      `uvm_field_int(result,     UVM_ALL_ON)
      `uvm_field_int(cout,       UVM_ALL_ON)
      `uvm_field_int(nbo,        UVM_ALL_ON)
      `uvm_field_int(ngo,        UVM_ALL_ON)
      `uvm_field_int(exp_result, UVM_ALL_ON)
      `uvm_field_int(exp_rdata1, UVM_ALL_ON)
      `uvm_field_int(exp_rdata2, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "alu_transaction");
      super.new(name);
    endfunction : new

    // operation name comes straight from the alu_op_e enum (.name())
    function string inputs2str();
        alu_op_e op;
        op = alu_op_e'({mode, sel});
        return $sformatf("op=%-30s mode=%0b sel=%04b cin=%0b a=%04h b=%04h bsrc=%0b ra1=%0d ra2=%0d",
            op.name(), mode, sel, cin, a, b, b_source, ra1, ra2);
    endfunction : inputs2str

    function string outputs2str();
      return $sformatf("rdata1=%04h rdata2=%04h result=%04h cout=%0b nbo=%0b ngo=%0b",
          rdata1, rdata2, result, cout, nbo, ngo);
    endfunction : outputs2str

  endclass : alu_transaction
