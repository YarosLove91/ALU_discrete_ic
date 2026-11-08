// ============================================================
// File    : alu_scoreboard.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Scoreboard: compares the actual DUT outputs against the
// expectations:
//   alu_result            vs exp_result (golden model)
//   reg_read_data1/2      vs exp_rdata1/2 (monitor shadow
//                          register file - echo check)
// Keeps counters and logs the first SCB_MAX_LOG mismatches (the
// rest go to the counter only, to avoid flooding the log).
//
// The remaining DUT outputs (cout, nbo, ngo) are captured in the
// transaction; they join the comparison when the golden model is
// extended beyond result.
// ============================================================
class alu_scoreboard extends uvm_subscriber #(alu_transaction);
    `uvm_component_utils(alu_scoreboard)

    // detailed mismatch log cap comes from alu_cfg_pkg (SCB_MAX_LOG)

    function new(string name = "alu_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual function void write(alu_transaction tr);
      string bad;
      bad = "";
      if (tr.result !== tr.exp_result) begin
        bad = {bad, $sformatf(" result[dut=%04h exp=%04h]",
            tr.result, tr.exp_result)};
      end
      if (tr.rdata1 !== tr.exp_rdata1) begin
        bad = {bad, $sformatf(" RF1[dut=%04h exp=%04h]",
            tr.rdata1, tr.exp_rdata1)};
      end
      if (tr.rdata2 !== tr.exp_rdata2) begin
        bad = {bad, $sformatf(" RF2[dut=%04h exp=%04h]",
            tr.rdata2, tr.exp_rdata2)};
      end

      g_scb_checked++;
      if (bad == "") begin
          g_scb_matches++;
          if (SCB_MATCH_LOG_EN) begin
            `uvm_info({get_type_name(), ".MATCHED"},
                $sformatf("[%0d] match: %s", tr.id, tr.inputs2str()),
                UVM_HIGH)
          end
      end else begin
        g_scb_mismatches++;
        if (g_scb_mismatches <= SCB_MAX_LOG) begin
            `uvm_error({get_type_name(), ".MISMATCH"},
                $sformatf("[%0d]%s |%s", tr.id, tr.inputs2str(), bad))
        end
          else if (g_scb_mismatches == SCB_MAX_LOG + 1) begin
            `uvm_error({get_type_name(), ".LOG_LIMIT"},
                $sformatf("detailed mismatch log capped at %0d messages, further mismatches counted only",
                          SCB_MAX_LOG))
          end
      end
    endfunction : write

    virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info({get_type_name(), ".SUMMARY"},
                $sformatf("transactions checked: %0d | matched: %0d | mismatches: %0d",
                          g_scb_checked, g_scb_matches, g_scb_mismatches),
                UVM_HIGH)
    endfunction : report_phase

  endclass : alu_scoreboard
