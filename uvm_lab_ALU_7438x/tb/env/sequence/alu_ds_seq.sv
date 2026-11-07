// ============================================================
// File    : alu_ds_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Datasheet truth-table replay: for every operation - all
// combinations of {Cn, An, Bn}, An/Bn in {LLLL, HHHH}
// (8 ops x 8 input cases = 64 vectors). For 16-bit chains the
// corner patterns are replicated across all slices.
// ============================================================

  class alu_ds_seq extends alu_base_seq;
    `uvm_object_utils(alu_ds_seq)

    function new(string name = "alu_ds_seq");
      super.new(name);
    endfunction : new

    task body();
      for (int s = 0; s < 8; s++) begin
        for (int in_case = 0; in_case < 8; in_case++) begin
          send (in_case[1] ? ALL_ONES : '0,
                in_case[0] ? ALL_ONES : '0,
                s[2:0],
                in_case[2]);
        end
      end
    endtask : body

  endclass : alu_ds_seq
