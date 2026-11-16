// ============================================================
// File    : alu_start_reset.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Abstract test with an initial initialization (reset) stage.
// Concrete tests extend this class instead of alu_base_test when
// they need a known starting state: do_reset() waits for the
// hardware reset release, clears the register file through the
// driver protocol (alu_reset_seq) and leaves the bus idle before
// body_seq() runs. The objection/drain/verdict flow matches
// alu_base_test.
// ============================================================

  virtual class alu_start_reset extends alu_base_test;
    `uvm_component_utils(alu_start_reset)

    alu_vif vif;

    function new(string name = "alu_start_reset", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(alu_vif)::get(this, "", "vif", vif)) begin
        `uvm_fatal({get_type_name(), ".NOVIF"},
            "virtual interface not found in uvm_config_db")
      end
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      do_reset();
      body_seq();
      repeat (DRAIN_CYCLES) @(vif.drv_cb);  // pipeline drain: monitor -> fifo -> rfm -> scb
      phase.drop_objection(this);
    endtask : run_phase

    // initial initialization: wait for the hardware reset release
    // (rst active HIGH), clear the register file and settle the bus
    virtual task do_reset();
      alu_reset_seq seq;
      `uvm_info({get_type_name(), ".RESET"},
          "waiting for hardware reset release (rst active HIGH)", UVM_HIGH)
      wait (vif.rst === 1'b0);
      repeat (INIT_CYCLES) @(vif.drv_cb);
      seq = alu_reset_seq::type_id::create("seq");
      seq.start(env_h.v_sqr.sqr);
      repeat (INIT_CYCLES) @(vif.drv_cb);
      `uvm_info({get_type_name(), ".RESET"},
          $sformatf("initialization done: %0d registers cleared, bus idle", NUM_REGS),
          UVM_HIGH)
    endtask : do_reset

  endclass : alu_start_reset
