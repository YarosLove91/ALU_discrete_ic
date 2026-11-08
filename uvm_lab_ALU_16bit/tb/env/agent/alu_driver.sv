// ============================================================
// File    : alu_driver.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Driver: applies transactions to the interface through the
// drv_cb clocking block (stimuli are driven at the clocking
// event, race-free against the DUT sampling).
//
// TB protocol (DUT: cpu_top, register file write is synchronous,
// ALU path is combinational), one transaction = 4 clocks:
//   - clock N   : reg_write_enable=1, write a -> R[ra1];
//   - clock N+1 : write b -> R[ra2] (register path only, the
//                 write commits at this edge; immediate path
//                 drops write_enable);
//   - clock N+2 : op phase - read addresses, alu_cin/mode/comm,
//                 b_source_sel/alu_b_imm and valid <= 1; the
//                 combinational ALU output settles during the
//                 cycle;
//   - clock N+3 : the monitor sees valid=1 together with a
//                 consistent "inputs/outputs" pair; the driver
//                 drops valid.
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
      @(vif.drv_cb);
      vif.drv_cb.reg_write_enable <= 1'b0;
      vif.drv_cb.reg_read_addr1   <= '0;
      vif.drv_cb.reg_read_addr2   <= '0;
      vif.drv_cb.reg_write_addr   <= '0;
      vif.drv_cb.reg_write_data   <= '0;
      vif.drv_cb.alu_cin          <= '0;
      vif.drv_cb.alu_mode         <= '0;
      vif.drv_cb.alu_comm         <= '0;
      vif.drv_cb.b_source_sel     <= '0;
      vif.drv_cb.alu_b_imm        <= '0;
      vif.drv_cb.valid            <= 1'b0;

      wait (vif.rst === 1'b0);   // wait for reset release (rst active HIGH)
      @(vif.drv_cb);

      forever begin
        seq_item_port.get_next_item(req);
        req.id = g_item_id++;

        // ---- phase 1: operand A -> R[ra1] ----
        @(vif.drv_cb);
        vif.drv_cb.reg_write_enable <= 1'b1;
        vif.drv_cb.reg_write_addr   <= req.ra1;
        vif.drv_cb.reg_write_data   <= req.a;
        `uvm_info({get_type_name(), ".RF_WRITE"},
                  $sformatf("[%0d] R%0d <= %04h", req.id, req.ra1, req.a),
                  UVM_HIGH)

        // ---- phase 2: operand B -> R[ra2] (register path only) ----
        @(vif.drv_cb);
        if (req.b_source == 1'b0) begin
          vif.drv_cb.reg_write_addr <= req.ra2;
          vif.drv_cb.reg_write_data <= req.b;
          `uvm_info({get_type_name(), ".RF_WRITE"},
                    $sformatf("[%0d] R%0d <= %04h", req.id, req.ra2, req.b),
                    UVM_HIGH)
        end
        else begin
          vif.drv_cb.reg_write_enable <= 1'b0;
        end

        // ---- phase 3: op phase - controls + valid ----
        @(vif.drv_cb);
        vif.drv_cb.reg_write_enable <= 1'b0;
        vif.drv_cb.reg_read_addr1   <= req.ra1;
        vif.drv_cb.reg_read_addr2   <= req.ra2;
        vif.drv_cb.alu_cin          <= req.cin;
        vif.drv_cb.alu_mode         <= req.mode;
        vif.drv_cb.alu_comm         <= req.sel;
        vif.drv_cb.b_source_sel     <= req.b_source;
        vif.drv_cb.alu_b_imm        <= req.b;
        vif.drv_cb.valid            <= 1'b1;
        `uvm_info({get_type_name(), ".DRIVE"},
                  $sformatf("[%0d] driving %s", req.id, req.inputs2str()),
                  UVM_HIGH)

        // ---- phase 4: monitor samples here; drop valid ----
        @(vif.drv_cb);
        vif.drv_cb.valid <= 1'b0;
        seq_item_port.item_done();
      end
    endtask : run_phase

  endclass : alu_driver
