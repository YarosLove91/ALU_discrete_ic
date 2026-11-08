// ============================================================
// File    : params_pkg.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// Command encoding package (moved from the former params.vh).
// Source of the 74181 operation encodings: OP_L_* (logic,
// mode = 1) and OP_A_* (arithmetic, mode = 0) plus the combined
// 5-bit {mode, sel} codes. The CPU-testbench macros (ALU_REG /
// CHECK / READ_REG) are intentionally not part of the lab.
// ============================================================
`ifndef PARAMS_PKG_SV
`define PARAMS_PKG_SV

package params_pkg;

  // ==================== ALU PARAMETERS ====================
  parameter int DATA_WIDTH = 16;
  parameter int ADDR_WIDTH = 3;  // 8 registers => 3 bits

  // ==================== CONTROL SIGNALS ====================
  parameter logic ALU_MODE_ARITHMETIC = 1'b0;
  parameter logic ALU_MODE_LOGIC      = 1'b1;

  parameter logic B_SOURCE_REGISTER  = 1'b0;
  parameter logic B_SOURCE_IMMEDIATE = 1'b1;

  // Unambiguous 74181 carry semantics:
  // C_in = 1 - no carry in, C_in = 0 - carry in (active LOW)
  parameter logic CARRY_IN_ACTIVE   = 1'b0;  // C_in = 0 (carry present)
  parameter logic CARRY_IN_INACTIVE = 1'b1;  // C_in = 1 (no carry)

  parameter logic CARRY_CHECK_DISABLED = 1'b0;
  parameter logic CARRY_CHECK_ENABLED  = 1'b1;

  // ==================== ALU 74181 COMMANDS ====================
  // Logical Operations (M = 1)
  parameter logic [3:0]
    OP_L_NOT_A          = 4'b0000,
    OP_L_A_OR_B_NOT     = 4'b0001,
    OP_L_NOT_A_AND_B    = 4'b0010,
    OP_L_LOGIC_0        = 4'b0011,
    OP_L_NOT_A_AND_NOT_B= 4'b0100,
    OP_L_NOT_B          = 4'b0101,
    OP_L_XOR            = 4'b0110,
    OP_L_A_AND_NOT_B    = 4'b0111,
    OP_L_NOT_A_OR_B     = 4'b1000,
    OP_L_XNOR           = 4'b1001,
    OP_L_B              = 4'b1010,
    OP_L_A_AND_B        = 4'b1011,
    OP_L_LOGIC_1        = 4'b1100,
    OP_L_A_OR_NOT_B     = 4'b1101,
    OP_L_A_OR_B         = 4'b1110,
    OP_L_A              = 4'b1111;

  // Arithmetic Operations (M = 0)
  parameter logic [3:0]
    OP_A_A_PLUS_CARRY               = 4'b0000,
    OP_A_A_PLUS_B_PLUS_CARRY        = 4'b0001,
    OP_A_A_PLUS_NOT_B_PLUS_CARRY    = 4'b0010,
    OP_A_MINUS_1_PLUS_CARRY         = 4'b0011,
    OP_A_A_PLUS_A_AND_NOT_B         = 4'b0100,
    OP_A_A_PLUS_B_PLUS_A_AND_NOT_B  = 4'b0101,
    OP_A_A_MINUS_B_MINUS_CARRY      = 4'b0110,
    OP_A_A_AND_NOT_B_MINUS_CARRY    = 4'b0111,
    OP_A_A_PLUS_A_AND_B_PLUS_CARRY  = 4'b1000,
    OP_A_A_PLUS_B                   = 4'b1001,
    OP_A_A_PLUS_NOT_B_PLUS_A_AND_B  = 4'b1010,
    OP_A_A_AND_B_MINUS_CARRY        = 4'b1011,
    OP_A_A_PLUS_A_PLUS_CARRY        = 4'b1100,
    OP_A_A_PLUS_B_PLUS_A_PLUS_1     = 4'b1101,
    OP_A_A_PLUS_NOT_B_PLUS_A_PLUS_1 = 4'b1110,
    OP_A_A_MINUS_1                  = 4'b1111;

  // ==================== COMBINED ALU COMMANDS ====================
  parameter logic [4:0]
    OP_A_PLUS_CARRY              = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_CARRY},
    OP_A_PLUS_B_PLUS_CARRY       = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_B_PLUS_CARRY},
    OP_A_PLUS_NOT_B_PLUS_CARRY   = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_NOT_B_PLUS_CARRY},
    OP_MINUS_1_PLUS_CARRY        = {ALU_MODE_ARITHMETIC, OP_A_MINUS_1_PLUS_CARRY},
    OP_A_PLUS_A_AND_NOT_B        = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_A_AND_NOT_B},
    OP_A_PLUS_B_PLUS_A_AND_NOT_B = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_B_PLUS_A_AND_NOT_B},
    OP_A_MINUS_B_MINUS_CARRY     = {ALU_MODE_ARITHMETIC, OP_A_A_MINUS_B_MINUS_CARRY},
    OP_A_AND_NOT_B_MINUS_CARRY   = {ALU_MODE_ARITHMETIC, OP_A_A_AND_NOT_B_MINUS_CARRY},
    OP_A_PLUS_A_AND_B_PLUS_CARRY = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_A_AND_B_PLUS_CARRY},
    OP_A_PLUS_B                  = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_B},
    OP_A_PLUS_NOT_B_PLUS_A_AND_B = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_NOT_B_PLUS_A_AND_B},
    OP_A_AND_B_MINUS_CARRY       = {ALU_MODE_ARITHMETIC, OP_A_A_AND_B_MINUS_CARRY},
    OP_A_PLUS_A_PLUS_CARRY       = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_A_PLUS_CARRY},
    OP_A_PLUS_B_PLUS_A_PLUS_1    = {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_B_PLUS_A_PLUS_1},
    OP_A_PLUS_NOT_B_PLUS_A_PLUS_1= {ALU_MODE_ARITHMETIC, OP_A_A_PLUS_NOT_B_PLUS_A_PLUS_1},
    OP_A_MINUS_1                 = {ALU_MODE_ARITHMETIC, OP_A_A_MINUS_1};

  parameter logic [4:0]
    OP_NOT_A           = {ALU_MODE_LOGIC, OP_L_NOT_A},
    OP_A_OR_B_NOT      = {ALU_MODE_LOGIC, OP_L_A_OR_B_NOT},
    OP_NOT_A_AND_B     = {ALU_MODE_LOGIC, OP_L_NOT_A_AND_B},
    OP_LOGIC_0         = {ALU_MODE_LOGIC, OP_L_LOGIC_0},
    OP_NOT_A_AND_NOT_B = {ALU_MODE_LOGIC, OP_L_NOT_A_AND_NOT_B},
    OP_NOT_B           = {ALU_MODE_LOGIC, OP_L_NOT_B},
    OP_XOR             = {ALU_MODE_LOGIC, OP_L_XOR},
    OP_A_AND_NOT_B     = {ALU_MODE_LOGIC, OP_L_A_AND_NOT_B},
    OP_NOT_A_OR_B      = {ALU_MODE_LOGIC, OP_L_NOT_A_OR_B},
    OP_XNOR            = {ALU_MODE_LOGIC, OP_L_XNOR},
    OP_B               = {ALU_MODE_LOGIC, OP_L_B},
    OP_A_AND_B         = {ALU_MODE_LOGIC, OP_L_A_AND_B},
    OP_LOGIC_1         = {ALU_MODE_LOGIC, OP_L_LOGIC_1},
    OP_A_OR_NOT_B      = {ALU_MODE_LOGIC, OP_L_A_OR_NOT_B},
    OP_A_OR_B          = {ALU_MODE_LOGIC, OP_L_A_OR_B},
    OP_A               = {ALU_MODE_LOGIC, OP_L_A};

  // ==================== REGISTER ADDRESSES ====================
  parameter logic [ADDR_WIDTH-1:0]
      REG_R0 = 3'd0, REG_R1 = 3'd1, REG_R2 = 3'd2, REG_R3 = 3'd3,
      REG_R4 = 3'd4, REG_R5 = 3'd5, REG_R6 = 3'd6, REG_R7 = 3'd7;

  // ==================== TEST CONSTANTS ====================
  parameter logic [DATA_WIDTH-1:0] TEST_ZERO  = '0;
  parameter logic [DATA_WIDTH-1:0] TEST_ONES  = '1;
  parameter logic [DATA_WIDTH-1:0] TEST_ONE   = {{DATA_WIDTH-1{1'b0}}, 1'b1};
  parameter logic [DATA_WIDTH-1:0] TEST_MSB   = {1'b1, {DATA_WIDTH-1{1'b0}}};
  parameter logic [DATA_WIDTH-1:0] TEST_LSB   = TEST_ONE;
  parameter logic [DATA_WIDTH-1:0] INDIFFERENT_VAL = {DATA_WIDTH{1'bx}};
  parameter logic [ADDR_WIDTH-1:0] INDIFFERENT_REG = {ADDR_WIDTH{1'bx}};

  // Register name helper
  function automatic string get_reg_name(input logic [ADDR_WIDTH-1:0] addr);
    get_reg_name = $sformatf("R%0d", addr);
  endfunction : get_reg_name

endpackage : params_pkg

`endif // PARAMS_PKG_SV
