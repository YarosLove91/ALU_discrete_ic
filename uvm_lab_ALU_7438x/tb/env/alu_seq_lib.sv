// ============================================================
// File    : alu_seq_lib.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Sequence library:
//   alu_base_seq       - base class, send() helper
//   alu_ds_seq         - datasheet truth-table replay
//                        (sel x {cn, a in {0,F}, b in {0,F}} = 64 vectors)
//   alu_exhaustive_seq - exhaustive sweep of the 4-bit DUT
//                        (8 x 2 x 16 x 16 = 4096 vectors)
//   alu_corner_seq     - corner operand values
//                        (0, 1, MAX_POS, MIN_NEG, ALL_ONES-1, ALL_ONES)
//   alu_random_seq     - random vectors with corner-weighted dist
// ============================================================

  class alu_base_seq extends uvm_sequence #(alu_transaction);
    `uvm_object_utils(alu_base_seq)

    function new(string name = "alu_base_seq");
      super.new(name);
    endfunction : new

    task send(bit [W-1:0] a, bit [W-1:0] b, bit [2:0] s, bit cn);
      alu_transaction tr;
      tr = alu_transaction::type_id::create("tr");
      start_item(tr);
      tr.a  = a;
      tr.b  = b;
      tr.s  = s;
      tr.cn = cn;
      finish_item(tr);
    endtask : send

  endclass : alu_base_seq


  // Replay of the 74F381/74F382 truth-table rows: for every
  // operation - all combinations of {Cn, An, Bn}, An/Bn in {LLLL, HHHH}
  class alu_ds_seq extends alu_base_seq;
    `uvm_object_utils(alu_ds_seq)

    function new(string name = "alu_ds_seq");
      super.new(name);
    endfunction : new

    task body();
      for (int s = 0; s < 8; s++) begin
        for (int in_case = 0; in_case < 8; in_case++) begin
          send(in_case[1] ? ALL_ONES : '0,
              in_case[0] ? ALL_ONES : '0,
              s[2:0],
              in_case[2]);
        end
      end
    endtask : body
  endclass : alu_ds_seq


  // Complete sweep of the 4-bit DUT input space (4096 vectors)
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


  // Corner operand values: signed-range borders, zero, all-ones
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


  // Random sequence; item count is set by the test
  // (+NUM_TRANSACTIONS plusarg). Corner values are weighted via
  // dist so that carries/overflows occur more often.
  class alu_random_seq extends alu_base_seq;
    `uvm_object_utils(alu_random_seq)

    int unsigned num_items = 1000;

    function new(string name = "alu_random_seq");
      super.new(name);
    endfunction : new

    task body();
      alu_transaction tr;
      repeat (num_items) begin
        tr = alu_transaction::type_id::create("tr");
        start_item(tr);
        if (!tr.randomize() with {
              a dist { 0 := 10, ALL_ONES := 10, [1 : ALL_ONES - 1] :/ 80 };
              b dist { 0 := 10, ALL_ONES := 10, [1 : ALL_ONES - 1] :/ 80 };
            }) begin
            `uvm_fatal("ALU_RANDOM_SEQ.RANDOMIZE", "randomize() failed")
        end
        finish_item(tr);
      end
    endtask : body

  endclass : alu_random_seq
