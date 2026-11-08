// ============================================================
// File    : alu_coverage.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Functional coverage collector (uvm_subscriber):
//   cp_mode / cp_sel  - all 32 functions ({mode, sel})
//   cp_cin            - carry input (active LOW)
//   cp_bsrc           - operand B source (register / immediate)
//   cp_ra1 / cp_ra2   - register file addresses (R0..R7)
//   cp_a/cp_b         - corner operand values
//                       (0, 1, MAX_POS, MIN_NEG, ALL_ONES-1,
//                        ALL_ONES, others)
//   crosses: func (mode x sel), func x cin, func x bsrc, a x b
// Coverage is printed in report_phase; the lab target is 100%.
// Gated by the COVERAGE_EN config bit (alu_cfg_pkg) at two levels:
// alu_env does not create/connect the collector when it is 0, and
// the internal guards below skip sampling and print DISABLED if the
// component is created anyway (e.g. via factory override).
// ============================================================
  class alu_coverage extends uvm_subscriber #(alu_transaction);
    `uvm_component_utils(alu_coverage)

    alu_transaction tr_c;

    covergroup cg;
      cp_mode : coverpoint tr_c.mode;
      cp_sel  : coverpoint tr_c.sel {
        bins sel_[] = {[0 : 15]};
      }
      cp_cin  : coverpoint tr_c.cin;
      cp_bsrc : coverpoint tr_c.b_source;
      cp_ra1  : coverpoint tr_c.ra1 {
        bins reg_[] = {[0 : NUM_REGS - 1]};
      }
      cp_ra2  : coverpoint tr_c.ra2 {
        bins reg_[] = {[0 : NUM_REGS - 1]};
      }

      cp_a : coverpoint tr_c.a {
        bins zero     = {0};
        bins one      = {1};
        bins max_pos  = {MAX_POS};
        bins min_neg  = {MIN_NEG};
        bins ones_m1  = {ALL_ONES - 1};
        bins ones     = {ALL_ONES};
        bins mid      = default;
      }
      cp_b : coverpoint tr_c.b {
        bins zero     = {0};
        bins one      = {1};
        bins max_pos  = {MAX_POS};
        bins min_neg  = {MIN_NEG};
        bins ones_m1  = {ALL_ONES - 1};
        bins ones     = {ALL_ONES};
        bins mid      = default;
      }

      x_func      : cross cp_mode, cp_sel;
      x_func_cin  : cross cp_mode, cp_sel, cp_cin;
      x_func_bsrc : cross cp_mode, cp_sel, cp_bsrc;
      x_a_b       : cross cp_a, cp_b;
    endgroup

    function new(string name = "alu_coverage", uvm_component parent = null);
      super.new(name, parent);
      cg = new();
    endfunction : new

    virtual function void write(alu_transaction t);
      if (!COVERAGE_EN) begin
        return;  // coverage disabled via alu_cfg_pkg (COVERAGE_EN = 0)
      end
      tr_c = t;
      cg.sample();
    endfunction : write

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if (!COVERAGE_EN) begin
          `uvm_info({get_type_name(), ".REPORT"},
                    "functional coverage: DISABLED (COVERAGE_EN=0)", UVM_HIGH)
          return;
        end
        `uvm_info({get_type_name(), ".REPORT"},
                  $sformatf("functional coverage: %.2f%%", cg.get_coverage()),
                  UVM_HIGH)
    endfunction : report_phase

  endclass : alu_coverage
