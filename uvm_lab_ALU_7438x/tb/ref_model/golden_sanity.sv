// ============================================================
// File    : golden_sanity.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Golden-model self-check against the datasheet truth tables
// (used by alu_sanity_test). Verifies golden_381/golden_382 on
// every table row: sel x {Cn, An, Bn}, An/Bn in {0000, 1111} -
// 64 rows per chip, 128 checks total. Requires alu_ds_tables.sv,
// golden_381.sv and golden_382.sv to be included first.
// ============================================================

  function automatic void run_golden_sanity();
    ds_row_t  row;
    bit [3:0] a, b, f;
    bit       cn, x1, x2;
    g_sanity_checks = 0;
    g_sanity_errors = 0;
    for (int sel = 0; sel < 8; sel++) begin
      for (int in_case = 0; in_case < 8; in_case++) begin
        cn = in_case[2];
        a  = in_case[1] ? 4'hF : 4'h0;
        b  = in_case[0] ? 4'hF : 4'h0;

        // 74381: x1 = G, x2 = P
        row = ds381_row(sel, in_case);
        golden_381(a, b, cn, sel[2:0], f, x2, x1);
        g_sanity_checks++;
        if (f !== row.f || x1 !== row.x1 || x2 !== row.x2) begin
          g_sanity_errors++;
          uvm_report_error("GOLDEN_381.DS_MISMATCH", $sformatf(
              "golden_381 != datasheet: sel=%0b cn=%0b a=%0h b=%0h | F %0h/%0h G %0b/%0b P %0b/%0b (golden/ds)",
              sel[2:0], cn, a, b, f, row.f, x1, row.x1, x2, row.x2));
        end

        // 74382: x1 = OVR, x2 = Cn+4
        row = ds382_row(sel, in_case);
        golden_382(a, b, cn, sel[2:0], f, x1, x2);
        g_sanity_checks++;
        if (f !== row.f || x1 !== row.x1 || x2 !== row.x2) begin
            g_sanity_errors++;
            uvm_report_error("GOLDEN_382.DS_MISMATCH", $sformatf(
                "golden_382 != datasheet: sel=%0b cn=%0b a=%0h b=%0h | F %0h/%0h OVR %0b/%0b Cn4 %0b/%0b",
                sel[2:0], cn, a, b, f, row.f, x1, row.x1, x2, row.x2));
        end
      end
    end
  endfunction : run_golden_sanity
