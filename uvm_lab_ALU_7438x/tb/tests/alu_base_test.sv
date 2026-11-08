// ============================================================
// File    : alu_base_test.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Abstract base test: builds the environment, runs the
// test-specific sequence (body_seq), drains the pipeline,
// prints the final LAB_RESULT verdict consumed by the Makefile
// and returns a non-zero exit code on failure ($fatal).
// ============================================================

  virtual class alu_base_test extends uvm_test;
    `uvm_component_utils(alu_base_test)

    alu_env env_h;
    // require the scoreboard to have checked at least one transaction
    bit require_dut_checks = 1'b1;

    function new(string name = "alu_base_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env_h = alu_env::type_id::create("env_h", this);
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
      `uvm_info({get_type_name(), ".START"},
          $sformatf("starting test: DUT=%s W=%0d cfg: COVERAGE_EN=%0b RFM_XCHECK_EN=%0b USE_CPP_REF=%0b NUM_TRANSACTIONS=%0d",
              DUT_KIND.name(), W, COVERAGE_EN, RFM_XCHECK_EN, USE_CPP_REF, NUM_TRANSACTIONS),
          UVM_HIGH)
      phase.raise_objection(this);
      body_seq();
      #200;  // pipeline drain: monitor -> fifo -> rfm -> scb
      phase.drop_objection(this);
    endtask : run_phase

    // extension point: the concrete sequence of the test
    pure virtual task body_seq();

    // Final lab verdict (the LAB_RESULT line is parsed by the Makefile)
    virtual function void final_phase(uvm_phase phase);
      uvm_report_server srv;
      bit ok;
      super.final_phase(phase);
      srv = uvm_report_server::get_server();
      ok = (g_scb_mismatches  == 0) &&
        (g_sanity_errors   == 0) &&
        (g_refmodel_errors == 0) &&
        (srv.get_severity_count(UVM_ERROR) == 0) &&
        (srv.get_severity_count(UVM_FATAL) == 0) &&
        (!require_dut_checks || g_scb_checked > 0);

      if (ok) begin
        $display("LAB_RESULT: PASS  (DUT=%s TEST=%s scb_checked=%0d)",
            DUT_KIND.name(), get_type_name(), g_scb_checked);
      end else begin
        $display("LAB_RESULT: FAIL  (DUT=%s TEST=%s scb_checked=%0d mismatches=%0d errors=%0d)",
            DUT_KIND.name(), get_type_name(), g_scb_checked, g_scb_mismatches,
            srv.get_severity_count(UVM_ERROR));
        $fatal(1, "lab test failed - see UVM_ERROR messages above");
      end
    endfunction : final_phase
  endclass : alu_base_test
