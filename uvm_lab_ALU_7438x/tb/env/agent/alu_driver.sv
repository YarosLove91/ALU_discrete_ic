// ============================================================
// File    : alu_driver.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Driver: applies transactions to the interface on clk edges.
//
// TB protocol (the DUT is purely combinational):
//   - at clock N the driver drives a/b/s/cn and valid <= 1 (NBA);
//   - during clock N the combinational DUT outputs settle;
//   - at clock N+1 the monitor sees valid=1 together with a
//     consistent "inputs/outputs" pair; the driver drops valid.
// Net result: one transaction = 2 clocks (1 clock of valid).
// ============================================================
  class alu_driver extends uvm_driver #(alu_transaction);
    `uvm_component_utils(alu_driver)

    alu_vif vif;

    function new(string name = "alu_driver", uvm_component parent = null);
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
      super.run_phase(phase);
      // idle levels
      vif.a     <= '0;
      vif.b     <= '0;
      vif.s     <= '0;
      vif.cn    <= '0;
      vif.valid <= 1'b0;

      wait (vif.rst === 1'b0);   // wait for reset release (rst active HIGH)
      @(posedge vif.clk);

      forever begin
        seq_item_port.get_next_item(req);
        req.id = g_item_id++;
        @(posedge vif.clk);
        vif.a     <= req.a;
        vif.b     <= req.b;
        vif.s     <= req.s;
        vif.cn    <= req.cn;
        vif.valid <= 1'b1;
        `uvm_info({get_type_name(), ".DRIVE"},
                  $sformatf("[%0d] driving %s", req.id, req.inputs2str()),
                  UVM_HIGH)
        @(posedge vif.clk);
        vif.valid <= 1'b0;
        seq_item_port.item_done();
      end
    endtask : run_phase

  endclass : alu_driver
