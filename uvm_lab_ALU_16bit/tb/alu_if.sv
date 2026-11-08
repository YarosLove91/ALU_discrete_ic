// ============================================================
// File    : alu_if.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// ALU interface (16-bit alu16: 4x74181 cascade + 74182 CLA).
//
//   a, b, cin, mode, sel       - stimuli (driver -> DUT)
//   result                     - operation result (16 bit)
//   cout, nbo, ngo             - carry out / group P,G (active LOW)
//   half_carry, overflow       - CLA Cnx / signed overflow flags
//   valid                      - qualification signal: the
//                                "inputs/outputs" pair is valid
//                                for one clock (TB protocol)
//
// Carry convention (74181 datasheet): cin/cout/half_carry are
// active LOW (1 = no carry).
// ============================================================
  interface alu_if (
    input logic clk,
    input logic rst
  );

    // ---- stimuli ----
    logic [15:0] a;
    logic [15:0] b;
    logic        cin;
    logic        mode;
    logic [3:0]  sel;

    // ---- DUT outputs ----
    logic [15:0] result;
    logic        cout;
    logic        nbo;
    logic        ngo;
    logic        half_carry;
    logic        overflow;

    // ---- handshake ----
    logic        valid;

    initial begin
        a          = '0;
        b          = '0;
        cin        = '0;
        mode       = '0;
        sel        = '0;
        valid      = '0;
    end

  endinterface : alu_if
