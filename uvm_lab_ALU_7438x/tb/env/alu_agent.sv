// ============================================================
// File    : alu_agent.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Agent: sequencer + driver + monitor (active by default).
// ============================================================
  class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

    alu_sequencer sqr;
    alu_driver    drv;
    alu_monitor   mon;

    function new(string name = "alu_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = alu_monitor::type_id::create("mon", this);
      if (get_is_active() == UVM_ACTIVE) begin
        sqr = alu_sequencer::type_id::create("sqr", this);
        drv = alu_driver::type_id::create("drv", this);
      end
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (get_is_active() == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
      end
    endfunction : connect_phase

  endclass : alu_agent
