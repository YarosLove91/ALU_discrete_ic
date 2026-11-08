// ============================================================
// File    : alu_env.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Environment:
//
//   agt(mon) --ap--> to_rfm (TLM FIFO) --> rfm (golden) --ap--> scb
//          \--ap-------------------------------------------> cov
// ============================================================
  class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)

    alu_agent      agt;
    alu_ref_model  rfm;
    alu_scoreboard scb;
    alu_coverage   cov;

    uvm_tlm_analysis_fifo #(alu_transaction) to_rfm;

    function new(string name = "alu_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agt    = alu_agent::type_id::create("agt", this);
      rfm    = alu_ref_model::type_id::create("rfm", this);
      scb    = alu_scoreboard::type_id::create("scb", this);
      // COVERAGE_EN=0: collector is not created at all;
      // alu_coverage additionally honors the bit internally
      if (COVERAGE_EN) begin
        cov = alu_coverage::type_id::create("cov", this);
      end
      to_rfm = new("to_rfm", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agt.mon.ap.connect(to_rfm.analysis_export);
      rfm.in_port.connect(to_rfm.get_export);
      rfm.ap.connect(scb.analysis_export);
      if (COVERAGE_EN) begin
        agt.mon.ap.connect(cov.analysis_export);
      end
    endfunction : connect_phase

  endclass : alu_env
