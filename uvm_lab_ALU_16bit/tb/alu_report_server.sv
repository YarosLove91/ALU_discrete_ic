// ============================================================
// File    : alu_report_server.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Custom UVM report server, classic "Application of custom UVM
// report server" pattern (SNUG 2013, G. McGregor): extends
// uvm_default_report_server and adds lab-oriented reporting on
// top of the standard UVM report summary:
//   - process_report_message intercept: every UVM_ERROR/UVM_FATAL
//     is accounted per message ID; the first message text, time
//     and source location of each ID are kept for quick triage;
//     all messages are histogrammed by verbosity (the meta-data
//     the default summary does not show);
//   - summarize: appends an "ALU Lab Report Server Summary"
//     section after the standard one - run info (test, UVM
//     revision, sim time, verbosity, seed), alu_cfg_pkg config,
//     lab verdict counters (stimulus / scoreboard / golden
//     sanity / reference model / functional coverage), the
//     verbosity histogram and the error-fatal-by-ID table with
//     first texts.
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
    protected string err_id_time[string];
    protected string err_id_loc[string];

    // message histogram by verbosity (all severities)
    protected int    verb_count[int];

    function new(string name = "alu_report_server");
      super.new(name);
    endfunction : new

    // Account error/fatal messages per ID, histogram verbosities,
    // then hand the message over to the default server
    // (severity/quit counting, actions)
    virtual function void process_report_message(
        uvm_report_message report_message);
      string       id;
      uvm_severity sev;
      int          verb;
      sev  = report_message.get_severity();
      id   = report_message.get_id();
      verb = report_message.get_verbosity();
      if (verb_count.exists(verb)) begin
        verb_count[verb]++;
      end else begin
        verb_count[verb] = 1;
      end
      if (sev == UVM_ERROR || sev == UVM_FATAL) begin
        if (err_id_count.exists(id)) begin
          err_id_count[id]++;
        end else begin
          err_id_count[id] = 1;
          err_id_first[id] = report_message.get_message();
          err_id_time[id]  = $sformatf("%0t", $realtime);
          if (report_message.get_filename() != "") begin
            err_id_loc[id] = $sformatf("%s(%0d)",
                report_message.get_filename(), report_message.get_line());
          end else begin
            err_id_loc[id] = "n/a";
          end
        end
      end
      super.process_report_message(report_message);
    endfunction : process_report_message

    // Verbosity value -> enum name (UVM_NONE..UVM_DEBUG) or number
    // for intermediate/custom levels (SNUG 2013 pattern)
    protected function string verbosity_name(int verbosity);
      uvm_verbosity v;
      if ($cast(v, verbosity)) begin
        verbosity_name = v.name();
      end else begin
        verbosity_name = $sformatf("%0d", verbosity);
      end
    endfunction : verbosity_name

    // Standard UVM summary first, then the lab section
    virtual function void summarize(UVM_FILE file = UVM_STDOUT);
      string q[$];
      uvm_component test_h;
      string test_name;
      int    std_verbs[6] = '{UVM_NONE, UVM_LOW, UVM_MEDIUM,
                              UVM_HIGH, UVM_FULL, UVM_DEBUG};
      int    other_cnt;
      bit    is_std;
      super.summarize(file);

      q.push_back("\n--- ALU Lab Report Server Summary ---\n");

      // ---- run info ----
      test_h    = uvm_root::get().get_child("uvm_test_top");
      test_name = (test_h != null) ? test_h.get_type_name() : "unknown";
      q.push_back("** Run info\n");
      q.push_back($sformatf("test          : %s\n", test_name));
      q.push_back($sformatf("UVM           : %s\n", uvm_revision_string()));
      q.push_back($sformatf("sim time      : %0.0f ns (%0t)\n",
          $realtime, $realtime));
      q.push_back($sformatf("verbosity     : %s\n",
          verbosity_name(uvm_top.get_report_verbosity_level(UVM_INFO))));
      q.push_back($sformatf("seed          : %0d (reproduce: +verilator+seed+%0d)\n",
          $get_initial_random_seed, $get_initial_random_seed));
      q.push_back($sformatf("DUT           : cpu_top (W=%0d NUM_REGS=%0d)\n",
          W, NUM_REGS));

      // ---- compile-time configuration ----
      q.push_back("** Config (alu_cfg_pkg)\n");
      q.push_back($sformatf("COVERAGE_EN=%0b RFM_XCHECK_EN=%0b USE_CPP_REF=%0b SCB_MATCH_LOG_EN=%0b\n",
          COVERAGE_EN, RFM_XCHECK_EN, USE_CPP_REF, SCB_MATCH_LOG_EN));
      q.push_back($sformatf("NUM_TRANSACTIONS=%0d SMOKE_TRANSACTIONS=%0d SCB_MAX_LOG=%0d\n",
          NUM_TRANSACTIONS, SMOKE_TRANSACTIONS, SCB_MAX_LOG));
      q.push_back($sformatf("golden model  : %s\n",
          USE_CPP_REF ? "C++ DPI" : "SystemVerilog"));

      // ---- lab verdict counters ----
      q.push_back("** Lab verdict counters\n");
      q.push_back($sformatf("stimulus      : issued=%0d\n", g_item_id));
      if (g_scb_checked > 0) begin
        q.push_back($sformatf("scoreboard    : checked=%0d matched=%0d mismatches=%0d (match rate %.2f%%)\n",
            g_scb_checked, g_scb_matches, g_scb_mismatches,
            100.0 * real'(g_scb_matches) / real'(g_scb_checked)));
      end else begin
        q.push_back($sformatf("scoreboard    : checked=%0d matched=%0d mismatches=%0d\n",
            g_scb_checked, g_scb_matches, g_scb_mismatches));
      end
      q.push_back($sformatf("golden sanity : checks=%0d errors=%0d\n",
          g_sanity_checks, g_sanity_errors));
      q.push_back($sformatf("ref model     : errors=%0d (xcheck %s)\n",
          g_refmodel_errors, RFM_XCHECK_EN ? "enabled" : "disabled"));
      if (g_cov_percent >= 0.0) begin
        q.push_back($sformatf("coverage      : %.2f%%\n", g_cov_percent));
      end else begin
        q.push_back("coverage      : DISABLED (COVERAGE_EN=0)\n");
      end

      // ---- verbosity histogram (SNUG 2013: the meta-data the
      // default UVM summary hides) ----
      q.push_back("** Report counts by verbosity\n");
      foreach (std_verbs[i]) begin
        q.push_back($sformatf("%-10s : %0d\n", verbosity_name(std_verbs[i]),
            verb_count.exists(std_verbs[i]) ? verb_count[std_verbs[i]] : 0));
      end
      other_cnt = 0;
      foreach (verb_count[k]) begin
        is_std = 0;
        foreach (std_verbs[i]) begin
          if (k == std_verbs[i]) begin
            is_std = 1;
          end
        end
        if (!is_std) begin
          other_cnt += verb_count[k];
        end
      end
      if (other_cnt > 0) begin
        q.push_back($sformatf("%-10s : %0d\n", "other", other_cnt));
      end

      // ---- error/fatal triage ----
      if (err_id_count.size() == 0) begin
        q.push_back("** Error/fatal messages by id: none\n");
      end else begin
        q.push_back("** Error/fatal messages by id (first occurrence kept for triage)\n");
        foreach (err_id_count[id]) begin
          q.push_back($sformatf("[%s] %5d : @ %s %s : %s\n",
              id, err_id_count[id], err_id_time[id], err_id_loc[id],
              err_id_first[id]));
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
