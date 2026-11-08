// ============================================================
// File    : alu_scoreboard.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Scoreboard: compares actual DUT outputs against expectations
// (exp_*) for the fields relevant to the selected DUT:
//   74381    : F, G, P
//   74381_16 : F, Co (routed as cn4 on the interface)
//   74382/16 : F, OVR, Cn+4
// Keeps counters and logs the first SCB_MAX_LOG mismatches (the
// rest go to the counter only, to avoid flooding the log).
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
      case (DUT_KIND)
        DUT_381_4: begin
            if (tr.f !== tr.exp_f) begin
              bad = {bad, $sformatf(" F[dut=%0h exp=%0h]", tr.f, tr.exp_f)};
            end
            if (tr.g !== tr.exp_g) begin
              bad = {bad, $sformatf(" G[dut=%0b exp=%0b]", tr.g, tr.exp_g)};
            end
            if (tr.p !== tr.exp_p) begin
              bad = {bad, $sformatf(" P[dut=%0b exp=%0b]", tr.p, tr.exp_p)};
            end
        end
        DUT_381_16: begin
            if (tr.f !== tr.exp_f) begin
              bad = {bad, $sformatf(" F[dut=%0h exp=%0h]", tr.f, tr.exp_f)};
            end
            if (tr.cn4 !== tr.exp_cn4) begin
              bad = {bad, $sformatf(" Co[dut=%0b exp=%0b]", tr.cn4, tr.exp_cn4)};
            end
        end
        DUT_382_4, DUT_382_16: begin
          if (tr.f !== tr.exp_f) begin
            bad = {bad, $sformatf(" F[dut=%0h exp=%0h]", tr.f, tr.exp_f)};
          end
          if (tr.ovr !== tr.exp_ovr) begin
            bad = {bad, $sformatf(" OVR[dut=%0b exp=%0b]", tr.ovr, tr.exp_ovr)};
          end
          if (tr.cn4 !== tr.exp_cn4) begin
            bad = {bad, $sformatf(" Cn+4[dut=%0b exp=%0b]", tr.cn4, tr.exp_cn4)};
          end
        end
      endcase

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
