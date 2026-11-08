// ============================================================
// File    : alu_tb_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Common testbench package: operation enum ({mode, sel} 5-bit
// encoding), virtual interface type, global verdict counters and
// the golden (reference) model (`includes from tb/ref_model/).
// All compile-time configuration lives in alu_cfg_pkg.
// UVM classes live in the local packages:
//   alu_seq_pkg (tb/env/sequence), alu_agent_pkg (tb/env/agent),
//   alu_env_pkg (tb/env/environment), alu_test_pkg (tb/tests).
//
// Operation encoding source: tb/params_pkg.sv (OP_A_*/OP_L_*),
// re-declared here as a self-contained lab enum. The 5-bit code
// is {mode, sel}: mode = 0 -> arithmetic, mode = 1 -> logic.
// ============================================================
`ifndef ALU_TB_PKG_SV
`define ALU_TB_PKG_SV

package alu_tb_pkg;

  import uvm_pkg::*;
  import alu_cfg_pkg::*;

  `include "uvm_macros.svh"

  // Combined {mode, sel} operation encoding (Function Table 74181)
  typedef enum bit [4:0] {
    // ---- arithmetic (mode = 0) ----
    OP_A_A_PLUS_CARRY               = 5'b0_0000,
    OP_A_A_PLUS_B_PLUS_CARRY        = 5'b0_0001,
    OP_A_A_PLUS_NOT_B_PLUS_CARRY    = 5'b0_0010,
    OP_A_MINUS_1_PLUS_CARRY         = 5'b0_0011,
    OP_A_A_PLUS_A_AND_NOT_B         = 5'b0_0100,
    OP_A_A_PLUS_B_PLUS_A_AND_NOT_B  = 5'b0_0101,
    OP_A_A_MINUS_B_MINUS_CARRY      = 5'b0_0110,
    OP_A_A_AND_NOT_B_MINUS_CARRY    = 5'b0_0111,
    OP_A_A_PLUS_A_AND_B_PLUS_CARRY  = 5'b0_1000,
    OP_A_A_PLUS_B                   = 5'b0_1001,
    OP_A_A_PLUS_NOT_B_PLUS_A_AND_B  = 5'b0_1010,
    OP_A_A_AND_B_MINUS_CARRY        = 5'b0_1011,
    OP_A_A_PLUS_A_PLUS_CARRY        = 5'b0_1100,
    OP_A_A_PLUS_B_PLUS_A_PLUS_1     = 5'b0_1101,
    OP_A_A_PLUS_NOT_B_PLUS_A_PLUS_1 = 5'b0_1110,
    OP_A_A_MINUS_1                  = 5'b0_1111,
    // ---- logic (mode = 1) ----
    OP_L_NOT_A                      = 5'b1_0000,
    OP_L_A_OR_B_NOT                 = 5'b1_0001,
    OP_L_NOT_A_AND_B                = 5'b1_0010,
    OP_L_LOGIC_0                    = 5'b1_0011,
    OP_L_NOT_A_AND_NOT_B            = 5'b1_0100,
    OP_L_NOT_B                      = 5'b1_0101,
    OP_L_XOR                        = 5'b1_0110,
    OP_L_A_AND_NOT_B                = 5'b1_0111,
    OP_L_NOT_A_OR_B                 = 5'b1_1000,
    OP_L_XNOR                       = 5'b1_1001,
    OP_L_B                          = 5'b1_1010,
    OP_L_A_AND_B                    = 5'b1_1011,
    OP_L_LOGIC_1                    = 5'b1_1100,
    OP_L_A_OR_NOT_B                 = 5'b1_1101,
    OP_L_A_OR_B                     = 5'b1_1110,
    OP_L_A                          = 5'b1_1111
  } alu_op_e;

  // Virtual interface type (instantiated in alu_tb_top)
  typedef virtual alu_if alu_vif;

  // --------------------------------------------------------
  // Transaction payload types (packed structs):
  //   alu_stim_t - CPU-level stimulus set (driver -> DUT)
  //   alu_outs_t - observed DUT output set; the transaction
  //                keeps one instance for the actual values and
  //                one for the expectations (act vs exp)
  // --------------------------------------------------------
  typedef struct packed {
    bit [2:0]  ra2;       // operand B register address
    bit [2:0]  ra1;       // operand A register address
    bit        b_source;  // operand B source: 0 = R[ra2], 1 = immediate
    bit [3:0]  sel;       // function select
    bit        mode;      // 0 = arithmetic, 1 = logic
    bit        cin;       // carry in (active LOW)
    bit [15:0] b;         // operand B (R[ra2] write / alu_b_imm)
    bit [15:0] a;         // operand A (R[ra1] write)
  } alu_stim_t;

  typedef struct packed {
    bit        ngo;       // 74182 group generate (active LOW)
    bit        nbo;       // 74182 group propagate (active LOW)
    bit        cout;      // ALU carry out (active LOW)
    bit [15:0] result;    // ALU result
    bit [15:0] b_imm;     // sampled immediate operand
    bit [15:0] rdata2;    // operand B presented to the ALU
    bit [15:0] rdata1;    // operand A presented to the ALU
  } alu_outs_t;

  // --------------------------------------------------------
  // Global verdict counters (a teaching simplification; a
  // production env would use uvm_report_server / config_db)
  // --------------------------------------------------------
  int unsigned g_item_id         = 0;
  int unsigned g_scb_checked     = 0;
  int unsigned g_scb_matches     = 0;
  int unsigned g_scb_mismatches  = 0;
  int unsigned g_sanity_checks   = 0;
  int unsigned g_sanity_errors   = 0;
  int unsigned g_refmodel_errors = 0;

  // --------------------------------------------------------
  // Golden (reference) model of the alu16 result
  // --------------------------------------------------------
  `include "golden_alu16.sv"   // golden_alu16 (SV model, result)
  `include "golden_dpi.sv"     // DPI-C imports + golden_alu16_sel selector

endpackage : alu_tb_pkg

`endif // ALU_TB_PKG_SV
