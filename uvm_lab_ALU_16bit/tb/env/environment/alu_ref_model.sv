// ============================================================
// File    : alu_ref_model.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Reference model (predictor): receives a transaction carrying
// the DUT inputs and actual outputs from the TLM FIFO, computes
// the expected ALU result with the package golden function
// (golden_alu16_sel: SV or C++ DPI per USE_CPP_REF) and forwards
// it to the scoreboard.
//
// The prediction uses the effective operands sampled by the
// monitor (tr.a = reg_read_data1, tr.b = b_source ? alu_b_imm :
// reg_read_data2), i.e. the values actually presented to the ALU
// inside cpu_top; the register file itself is checked separately
// by the scoreboard echo comparison (exp_rdata1/2 from the
// monitor shadow).
//
// RFM_XCHECK_EN (alu_cfg_pkg) additionally cross-checks the
// golden result of the two canonical arithmetic operations
// (A PLUS B, A MINUS B) against direct 17-bit arithmetic - a
// golden-model self-check protecting it from typos.
// ============================================================
  class alu_ref_model extends uvm_component;
    `uvm_component_utils(alu_ref_model)

    uvm_get_port      #(alu_transaction) in_port;
    uvm_analysis_port #(alu_transaction) ap;

    function new(string name = "alu_ref_model", uvm_component parent = null);
      super.new(name, parent);
      in_port = new("in_port", this);
      ap      = new("ap", this);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
      alu_transaction tr;
      super.run_phase(phase);
      forever begin
        in_port.get(tr);
        predict(tr);
        ap.write(tr);
      end
    endtask : run_phase

    // Fill the exp_* fields of the transaction from its inputs.
    // golden_alu16_sel switches between the SV and C++ DPI models
    // according to the USE_CPP_REF config bit (alu_cfg_pkg).
    function void predict(alu_transaction tr);
      golden_alu16_sel(tr.a, tr.b, tr.cin, tr.mode, tr.sel, tr.exp_result);
      if (RFM_XCHECK_EN) begin
        xcheck_arith_16(tr);
      end
    endfunction : predict

    // Cross-check: golden model vs direct 17-bit arithmetic for
    // the canonical operations A PLUS B (sel=1001) and
    // A MINUS B (sel=0110), arithmetic mode only.
    function void xcheck_arith_16(alu_transaction tr);
      bit [16:0] sum;
      bit [16:0] diff;
      if (tr.mode !== 1'b0) begin
        return;
      end
      if (tr.sel == 4'b1001) begin
        // A PLUS B: result = a + b + ~cin (Cin active LOW)
        sum = {1'b0, tr.a} + {1'b0, tr.b} + {16'b0, ~tr.cin};
        if (tr.exp_result !== sum[15:0]) begin
          g_refmodel_errors++;
          `uvm_error({get_type_name(), ".XCHK_SUM"},
              $sformatf("golden model self-check failed: %s | golden=%04h arithmetic=%04h",
                  tr.inputs2str(), tr.exp_result, sum[15:0]))
        end
      end
      else if (tr.sel == 4'b0110) begin
        // A MINUS B: result = a - b - cin (Cin active LOW)
        diff = {1'b0, tr.a} - {1'b0, tr.b} - {16'b0, tr.cin};
        if (tr.exp_result !== diff[15:0]) begin
          g_refmodel_errors++;
          `uvm_error({get_type_name(), ".XCHK_DIFF"},
              $sformatf("golden model self-check failed: %s | golden=%04h arithmetic=%04h",
                  tr.inputs2str(), tr.exp_result, diff[15:0]))
        end
      end
    endfunction : xcheck_arith_16

  endclass : alu_ref_model
