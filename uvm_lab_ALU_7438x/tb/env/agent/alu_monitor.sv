// ============================================================
// File    : alu_monitor.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Monitor: watches the interface; on valid=1 it collects a
// transaction ("stimuli + actual DUT outputs") and publishes it
// through the analysis port (to scoreboard/coverage/refmodel).
// ============================================================
  class alu_monitor extends uvm_monitor;
    `uvm_component_utils(alu_monitor)

    alu_vif vif;
    uvm_analysis_port #(alu_transaction) ap;

    function new(string name = "alu_monitor", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap", this);
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
      wait (vif.rst === 1'b0);
      forever begin
        @(posedge vif.clk);
        if (vif.valid === 1'b1) begin
          tr = alu_transaction::type_id::create("tr");
          tr.a   = vif.a;
          tr.b   = vif.b;
          tr.s   = vif.s;
          tr.cn  = vif.cn;
          tr.f   = vif.f;
          tr.p   = vif.p;
          tr.g   = vif.g;
          tr.ovr = vif.ovr;
          tr.cn4 = vif.cn4;
          `uvm_info({get_type_name(), ".SAMPLED"},
                    $sformatf("sampled %s | %s",
                              tr.inputs2str(), tr.outputs2str()),
                    UVM_HIGH)
          ap.write(tr);
        end
      end
    endtask : run_phase

  endclass : alu_monitor
