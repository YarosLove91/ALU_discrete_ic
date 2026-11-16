// ============================================================
// File    : alu_reset_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Initialization sequence: clears the whole register file to
// zero through the normal driver write protocol. Each
// transaction writes a pair of registers (R[i], R[i+1]); the
// accompanying operation is a benign logic function
// (mode=1, sel=1111 -> F=A=0) so the scored traffic stays
// deterministic. Used by alu_start_reset before the test body.
// ============================================================

  class alu_reset_seq extends alu_base_seq;
    `uvm_object_utils(alu_reset_seq)

    function new(string name = "alu_reset_seq");
      super.new(name);
    endfunction : new

    virtual task body();
      bit [2:0] ra1, ra2;
      for (int i = 0; i < NUM_REGS; i += 2) begin
        ra1 = i[2:0];
        ra2 = i + 1;
        send('0, '0, 1'b1, 1'b1, 4'b1111, 1'b0, ra1, ra2);
      end
    endtask : body

  endclass : alu_reset_seq
