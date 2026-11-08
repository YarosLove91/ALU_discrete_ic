// ============================================================
// File    : alu_monitor.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Monitor: watches the interface through the mon_cb clocking
// block (every signal is an input sampled #1step before the
// clocking event - race-free against driver/DUT updates); on
// valid=1 it collects a transaction ("stimuli + actual DUT
// outputs") and publishes it through the analysis port (to
// scoreboard/coverage/refmodel).
//
// Shadow register file: the monitor passively mirrors the
// synchronous writes it observes on reg_write_* (and the active
// HIGH reset) into rf_shadow, so every sampled transaction also
// carries the expected read data (exp_rdata1/exp_rdata2) for the
// scoreboard register-echo check. At each clocking event the
// valid sampling uses the shadow state BEFORE this edge's write
// commit, exactly like the DUT asynchronous reads.
// ============================================================
  class alu_monitor extends uvm_monitor;
    `uvm_component_utils(alu_monitor)

    alu_vif vif;
    uvm_analysis_port #(alu_transaction) ap;

    // passive mirror of the DUT register file (param_reg_file)
    bit [15:0] rf_shadow [NUM_REGS];

    function new(string name = "alu_monitor", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap", this);
      foreach (rf_shadow[i]) rf_shadow[i] = '0;
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(alu_vif)::get(this, "", "vif", vif)) begin
          `uvm_fatal({get_type_name(), ".NOVIF"},
                      "virtual interface not found in uvm_config_db")
      end
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
      alu_transaction tr;
      super.run_phase(phase);
      forever begin
        @(vif.mon_cb);
        if (vif.rst === 1'b1) begin
          // the DUT register file clears on active HIGH reset
          foreach (rf_shadow[i]) rf_shadow[i] = '0;
        end
        else begin
          // ---- sample the qualified pair first (pre-edge values) ----
          if (vif.mon_cb.valid === 1'b1) begin
            tr = alu_transaction::type_id::create("tr");
            tr.cin       = vif.mon_cb.alu_cin;
            tr.mode      = vif.mon_cb.alu_mode;
            tr.sel       = vif.mon_cb.alu_comm;
            tr.b_source  = vif.mon_cb.b_source_sel;
            tr.ra1       = vif.mon_cb.reg_read_addr1;
            tr.ra2       = vif.mon_cb.reg_read_addr2;
            tr.b_imm     = vif.mon_cb.alu_b_imm;
            tr.rdata1    = vif.mon_cb.reg_read_data1;
            tr.rdata2    = vif.mon_cb.reg_read_data2;
            tr.result    = vif.mon_cb.alu_result;
            tr.cout      = vif.mon_cb.alu_cout;
            tr.nbo       = vif.mon_cb.alu_nbo;
            tr.ngo       = vif.mon_cb.alu_ngo;
            // shadow expectations (state before this edge's write)
            tr.exp_rdata1 = rf_shadow[vif.mon_cb.reg_read_addr1];
            tr.exp_rdata2 = rf_shadow[vif.mon_cb.reg_read_addr2];
            // effective operands actually presented to the ALU
            tr.a = tr.rdata1;
            tr.b = tr.b_source ? tr.b_imm : tr.rdata2;
            `uvm_info({get_type_name(), ".SAMPLED"},
                      $sformatf("sampled %s | %s",
                                tr.inputs2str(), tr.outputs2str()),
                      UVM_HIGH)
            ap.write(tr);
          end
          // ---- then mirror this edge's synchronous write ----
          if (vif.mon_cb.reg_write_enable === 1'b1) begin
            rf_shadow[vif.mon_cb.reg_write_addr] = vif.mon_cb.reg_write_data;
          end
        end
      end
    endtask : run_phase

  endclass : alu_monitor
