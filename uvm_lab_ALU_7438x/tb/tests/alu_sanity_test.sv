// ============================================================
// File    : alu_sanity_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// TB self-check (lab stage 2): verifies the golden models
// golden_381/golden_382 against both datasheet truth tables
// (128 checks). Does not stimulate the DUT, so it runs with any
// DUT define and must pass before the golden model is trusted.
// ============================================================

  class alu_sanity_test extends alu_base_test;
    `uvm_component_utils(alu_sanity_test)

    function new(string name = "alu_sanity_test", uvm_component parent = null);
      super.new(name, parent);
      require_dut_checks = 1'b0;  // the DUT is not stimulated
    endfunction : new

    virtual task body_seq();
      `uvm_info({get_type_name(), ".GOLDEN_CHECK"},
                "self-checking golden_381/golden_382 against the 74F381/74F382 datasheet truth tables...",
                UVM_HIGH)
      run_golden_sanity();
      if (g_sanity_errors == 0) begin
        `uvm_info({get_type_name(), ".DONE"},
                  $sformatf("golden models match the datasheets: %0d checks, 0 errors",
                            g_sanity_checks),
                  UVM_HIGH)
      end
      else begin
        `uvm_error ({get_type_name(), ".DONE"},
                    $sformatf("golden models DO NOT match the datasheets: %0d errors out of %0d checks",
                              g_sanity_errors,
                              g_sanity_checks))
      end
    endtask : body_seq
  endclass : alu_sanity_test
