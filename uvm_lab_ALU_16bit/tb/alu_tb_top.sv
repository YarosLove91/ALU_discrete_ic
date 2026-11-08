// ============================================================
// File    : alu_tb_top.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Testbench top: clock/reset generation, interface and DUT
// instantiation, virtual interface handover via uvm_config_db,
// run_test().
//
// DUT: cpu_top (DUT/simple_CPU_top.v) - register file
// (param_reg_file) + operand-B source mux + the 16-bit ALU
// cascade alu16 (4x74181 + 74182 CLA, DUT/top_alu_16.sv).
// The register file is synchronous (clk), reset is active HIGH;
// the ALU datapath is combinational. The TB protocol qualifies
// sampled pairs with valid (one transaction = four clocks).
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
  // CPU-level wrapper: param_reg_file + operand-B mux + alu16
  cpu_top dut (
    .clk             (clk),
    .reset           (rst),
    .reg_write_enable (vif.reg_write_enable),
    .reg_read_addr1   (vif.reg_read_addr1),
    .reg_read_addr2   (vif.reg_read_addr2),
    .reg_write_addr   (vif.reg_write_addr),
    .reg_write_data   (vif.reg_write_data),
    .alu_cin          (vif.alu_cin),
    .alu_mode         (vif.alu_mode),
    .alu_comm         (vif.alu_comm),
    .b_source_sel     (vif.b_source_sel),
    .alu_b_imm        (vif.alu_b_imm),
    .reg_read_data1   (vif.reg_read_data1),
    .reg_read_data2   (vif.reg_read_data2),
    .alu_result       (vif.alu_result),
    .alu_cout         (vif.alu_cout),
    .alu_nbo          (vif.alu_nbo),
    .alu_ngo          (vif.alu_ngo)
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
