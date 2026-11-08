// ============================================================
// File    : alu_report_server.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Custom UVM report server, classic "Application of custom UVM
// report server" pattern: extends uvm_default_report_server and
// adds lab-oriented reporting on top of the standard UVM report
// summary:
//   - process_report_message intercept: every UVM_ERROR/UVM_FATAL
//     is accounted per message ID, and the first message text of
//     each ID is kept for quick triage;
//   - summarize: appends an "ALU Lab Report Server Summary"
//     section after the standard one - lab verdict counters
//     (scoreboard / golden sanity / reference model) and the
//     error-fatal-by-ID table with first texts.
// Installed by alu_base_test::build_phase through
// uvm_report_server::set_server(); messages emitted before the
// installation (elaboration banners) stay with the default
// server, exactly like in the Cookbook recipe. Plain text only -
// ANSI color is reserved for the Makefile runtime verdicts
// (lab rule: logs must stay greppable).
// ============================================================

  class alu_report_server extends uvm_default_report_server;

    // error triage tables (string-indexed assoc arrays iterate in
    // lexicographic order -> deterministic summary output)
    protected int    err_id_count[string];
    protected string err_id_first[string];

    function new(string name = "alu_report_server");
      super.new(name);
    endfunction : new

    // Account error/fatal messages per ID, then hand the message
    // over to the default server (severity/quit counting, actions)
    virtual function void process_report_message(
        uvm_report_message report_message);
      string       id;
      uvm_severity sev;
      sev = report_message.get_severity();
      id  = report_message.get_id();
      if (sev == UVM_ERROR || sev == UVM_FATAL) begin
        if (err_id_count.exists(id)) begin
          err_id_count[id]++;
        end else begin
          err_id_count[id] = 1;
          err_id_first[id] = report_message.get_message();
        end
      end
      super.process_report_message(report_message);
    endfunction : process_report_message

    // Standard UVM summary first, then the lab section
    virtual function void summarize(UVM_FILE file = UVM_STDOUT);
      string q[$];
      super.summarize(file);
      q.push_back("\n--- ALU Lab Report Server Summary ---\n");
      q.push_back("** Lab verdict counters\n");
      q.push_back($sformatf("scoreboard    : checked=%0d matched=%0d mismatches=%0d\n",
          g_scb_checked, g_scb_matches, g_scb_mismatches));
      q.push_back($sformatf("golden sanity : checks=%0d errors=%0d\n",
          g_sanity_checks, g_sanity_errors));
      q.push_back($sformatf("ref model     : errors=%0d\n",
          g_refmodel_errors));
      if (err_id_count.size() == 0) begin
        q.push_back("** Error/fatal messages by id: none\n");
      end else begin
        q.push_back("** Error/fatal messages by id (first text kept for triage)\n");
        foreach (err_id_count[id]) begin
          q.push_back($sformatf("[%s] %5d : %s\n",
              id, err_id_count[id], err_id_first[id]));
        end
      end
      if (file == UVM_STDOUT) begin
        `uvm_info("ALU/REPORT/SERVER",
            `UVM_STRING_QUEUE_STREAMING_PACK(q), UVM_NONE)
      end else begin
        foreach (q[i]) begin
          f_display(file, q[i]);
        end
      end
    endfunction : summarize

  endclass : alu_report_server
