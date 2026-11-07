// ============================================================
// File    : alu_random_seq.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Constrained-random sequence; item count is set by the test
// (+NUM_TRANSACTIONS plusarg). Corner values are weighted via
// dist so that carries/overflows occur more often.
// ============================================================

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
