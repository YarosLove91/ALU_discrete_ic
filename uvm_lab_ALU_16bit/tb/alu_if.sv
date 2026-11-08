// ============================================================
// File    : alu_if.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// CPU-level interface (DUT: cpu_top = param_reg_file + operand-B
// mux + alu16, see DUT/simple_CPU_top.v).
//
//   reg_*                - register file control (stimuli):
//                          synchronous write, asynchronous reads
//   alu_cin/mode/comm    - ALU operation control (stimuli)
//   b_source_sel         - operand B source: 0 = R[ra2],
//                          1 = alu_b_imm (immediate)
//   reg_read_data1/2     - operands actually presented to the ALU
//   alu_result/cout/nbo/ngo - ALU outputs (cout active LOW)
//   valid                - qualification signal: the
//                          "inputs/outputs" pair is valid for one
//                          clock (TB protocol)
//
// Carry convention (74181 datasheet): alu_cin/alu_cout are
// active LOW (1 = no carry). reset is active HIGH.
//
// Timing decoupling: two clocking blocks on posedge clk -
//   drv_cb - stimuli as outputs (driven by alu_driver);
//   mon_cb - EVERY signal as input #1step (race-free sampling by
//            alu_monitor, including the write bus mirrored into
//            the shadow register file).
// Modports drv_mp/mon_mp bundle the clocking block with clk/rst.
// ============================================================
  interface alu_if (
    input logic clk,
    input logic rst
  );

    // ---- register file control (stimuli) ----
    logic        reg_write_enable;
    logic [2:0]  reg_read_addr1;
    logic [2:0]  reg_read_addr2;
    logic [2:0]  reg_write_addr;
    logic [15:0] reg_write_data;

    // ---- ALU control (stimuli) ----
    logic        alu_cin;
    logic        alu_mode;
    logic [3:0]  alu_comm;
    logic        b_source_sel;
    logic [15:0] alu_b_imm;

    // ---- DUT outputs ----
    logic [15:0] reg_read_data1;
    logic [15:0] reg_read_data2;
    logic [15:0] alu_result;
    logic        alu_cout;
    logic        alu_nbo;
    logic        alu_ngo;

    // ---- handshake ----
    logic        valid;

    initial begin
        reg_write_enable = '0;
        reg_read_addr1   = '0;
        reg_read_addr2   = '0;
        reg_write_addr   = '0;
        reg_write_data   = '0;
        alu_cin          = '0;
        alu_mode         = '0;
        alu_comm         = '0;
        b_source_sel     = '0;
        alu_b_imm        = '0;
        valid            = '0;
    end

    // ---- driver clocking block: stimuli out, driven at the edge ----
    clocking drv_cb @(posedge clk);
      default input #1step output #0;
      output  reg_write_enable,
              reg_read_addr1,
              reg_read_addr2,
              reg_write_addr,
              reg_write_data,
              alu_cin,
              alu_mode,
              alu_comm,
              b_source_sel,
              alu_b_imm,
              valid;
    endclocking : drv_cb

    // ---- monitor clocking block: everything sampled race-free ----
    clocking mon_cb @(posedge clk);
      default input #1step;
      input reg_write_enable,
            reg_read_addr1,
            reg_read_addr2,
            reg_write_addr,
            reg_write_data,
            alu_cin,
            alu_mode,
            alu_comm,
            b_source_sel,
            alu_b_imm,
            valid,
            reg_read_data1,
            reg_read_data2,
            alu_result,
            alu_cout,
            alu_nbo,
            alu_ngo;
    endclocking : mon_cb

    // ---- modports ----
    modport drv_mp (clocking drv_cb, input clk, rst);
    modport mon_mp (clocking mon_cb, input clk, rst);

  endinterface : alu_if
