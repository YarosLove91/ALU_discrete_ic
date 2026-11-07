// ============================================================
// File    : alu_exhaustive_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Exhaustive sweep of the 4-bit DUT input space:
// 8 ops x 2 Cn x 16 A x 16 B = 4096 vectors. Fatals out for
// 16-bit widths (2^35 vectors - use alu_random_seq instead).
// ============================================================

  class alu_exhaustive_seq extends alu_base_seq;
    `uvm_object_utils(alu_exhaustive_seq)

    function new(string name = "alu_exhaustive_seq");
      super.new(name);
    endfunction : new

    task body();
      if (W != 4) begin
        `uvm_fatal("ALU_EXHAUSTIVE_SEQ.WIDTH",
            "exhaustive sweep is supported for 4-bit DUTs only (16-bit needs 2^35 vectors); use alu_random_test instead")
      end
      for (int s = 0; s < 8; s++) begin
        for (int c = 0; c < 2; c++) begin
          for (int av = 0; av < 16; av++) begin
            for (int bv = 0; bv < 16; bv++) begin
              send(av[3:0], bv[3:0], s[2:0], c[0]);
            end
          end
        end
      end
    endtask : body

  endclass : alu_exhaustive_seq
