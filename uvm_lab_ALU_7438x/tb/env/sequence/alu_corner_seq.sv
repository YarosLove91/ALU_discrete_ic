// ============================================================
// File    : alu_corner_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Corner sequence: all pairs of boundary operand values
// {0, 1, MAX_POS, MIN_NEG, ALL_ONES-1, ALL_ONES} across all
// 8 operations and both Cn values (6 x 6 x 8 x 2 = 576
// vectors). Targets carry/overflow boundaries of the signed
// range; closes functional coverage to 100%.
// ============================================================

  class alu_corner_seq extends alu_base_seq;
    `uvm_object_utils(alu_corner_seq)

    function new(string name = "alu_corner_seq");
      super.new(name);
    endfunction : new

    task body();
      bit [W-1:0] vals[6];
      vals[0] = '0;
      vals[1] = {{(W-1){1'b0}}, 1'b1};
      vals[2] = MAX_POS;
      vals[3] = MIN_NEG;
      vals[4] = ALL_ONES - 1;
      vals[5] = ALL_ONES;
      foreach (vals[i]) begin
        foreach (vals[j]) begin
          for (int s = 0; s < 8; s++) begin
            for (int c = 0; c < 2; c++) begin
              send(vals[i], vals[j], s[2:0], c[0]);
            end
          end
        end
      end
    endtask : body

  endclass : alu_corner_seq
