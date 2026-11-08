// ============================================================
// File    : alu_tb_top.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Testbench top: clock/reset generation, interface and DUT
// instantiation, virtual interface handover via uvm_config_db,
// run_test().
//
// The DUT is a single combinational block (alu16: four 74181
// slices + 74182 CLA); clock/reset only serve the TB protocol
// (valid qualification, one transaction = two clocks).
// ============================================================
`timescale 1ns/1ps

module alu_tb_top;

    import uvm_pkg::*;
    import alu_cfg_pkg::*;
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
  alu_if vif (.clk(clk), .rst(rst));

    // ---------------- DUT ----------------
  // 16-bit ALU cascade: 4x74181 + 74182 CLA (top_alu_16.sv;
  // same cascade as classic_ALU/74181_16bit/rtl/top/top_alu_16.v
  // plus the half_carry / overflow flag outputs)
  alu16 dut (
    .a          (vif.a),
    .b          (vif.b),
    .Cin        (vif.cin),
    .mode       (vif.mode),
    .sel        (vif.sel),
    .result     (vif.result),
    .Cout       (vif.cout),
    .nBo        (vif.nbo),
    .nGo        (vif.ngo),
    .half_carry (vif.half_carry),
    .overflow   (vif.overflow)
  );

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
