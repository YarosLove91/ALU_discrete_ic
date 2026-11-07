// ============================================================
// File    : alu_tb_top.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Testbench top: clock/reset generation, interface and DUT
// instantiation, virtual interface handover via uvm_config_db,
// run_test().
//
// DUT selection is compile-time (+define+DUT_74381 / DUT_74382 /
// DUT_74381_16 / DUT_74382_16), driven by the Makefile (DUT=...).
// ============================================================
`timescale 1ns/1ps

module alu_tb_top;

    import uvm_pkg::*;
    import alu_tb_pkg::*;
    import alu_test_pkg::*;

  // ---------------- clock / reset ----------------
  logic clk = 1'b0;
  logic rst = 1'b1;

  always #5 clk = ~clk;

  initial begin
    repeat (3) @(posedge clk);
    rst <= 1'b0;
  end

  // ---------------- interface ----------------
  alu_if #(W) vif (.clk(clk), .rst(rst));

    // ---------------- DUT ----------------
`ifdef DUT_74381
  // 4-bit 74381 core (P/G outputs for 74182 CLA cascading)
  alu_74381 dut (
    .A  (vif.a),
    .B  (vif.b),
    .S  (vif.s),
    .Cn (vif.cn),
    .F  (vif.f),
    .P  (vif.p),
    .G  (vif.g)
  );
`elsif DUT_74382
    // 4-bit 74382 core (OVR / Cn+4 outputs for ripple cascading)
    alu_74382 dut (
      .sel       (vif.s),
      .carry_in  (vif.cn),
      .port_a    (vif.a),
      .port_b    (vif.b),
      .result    (vif.f),
      .overflow  (vif.ovr),
      .carry_out (vif.cn4)
    );
`elsif DUT_74381_16
    // 16-bit 74381 chain (carry via P/G: Co = ~G | (~P & Cn))
    alu_16_bit dut (
      .A  (vif.a),
      .B  (vif.b),
      .S  (vif.s),
      .Cn (vif.cn),
      .F  (vif.f),
      .Co (vif.cn4)
    );
`elsif DUT_74382_16
    // 16-bit 74382 ripple chain (Cn+4 -> carry_in of the next slice)
    alu_chain dut (
      .sel          (vif.s),
      .ch_carry_in  (vif.cn),
      .ch_port_a    (vif.a),
      .ch_port_b    (vif.b),
      .ch_result    (vif.f),
      .ch_overflow  (vif.ovr),
      .ch_carry_out (vif.cn4)
    );
`else
  initial begin
    $fatal(1, "DUT not selected: expect +define+DUT_74381|DUT_74382|DUT_74381_16|DUT_74382_16");
  end
`endif

    // ---------------- UVM start ----------------
  initial begin
`ifdef VM_TRACE
  $dumpfile("logs/waves.vcd");
  $dumpvars(0, alu_tb_top);
`endif
  uvm_config_db#(alu_vif)::set(null, "*", "vif", vif);
  run_test("alu_smoke_test");
end

endmodule : alu_tb_top
