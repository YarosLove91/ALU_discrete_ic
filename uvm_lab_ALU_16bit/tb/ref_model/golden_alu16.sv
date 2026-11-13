// ============================================================
// File    : golden_alu16.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// SystemVerilog golden (reference) model of the alu16 result,
// included into alu_tb_pkg.
//
// Source of semantics: the validated operation tables of the
// student C++ testbench classic_ALU/74181_16bit/tb/tb_verilator/
// tb_alu_16.cpp (logic_operations, math_operations_STRUCT and
// carry_correction_p). The model computes the 16-bit result
// directly, in unsigned 16-bit arithmetic with natural wrap.
//
// Carry convention (74181, active LOW Cin):
//   carry_in_effective = ~Cin  (Cin = 1 -> no carry, Cin = 0 -> carry)
//   additive family : result = expr + carry_in_effective
//   subtractive family (sel 0110/0111/1011/1111): result = expr - Cin
// Logic operations (mode = 1) do not depend on Cin.
// ============================================================

  function automatic void golden_alu16(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cin,
    input  bit        mode,
    input  bit [3:0]  sel,
    output bit [15:0] result
  );
    bit [15:0] cc;              // carry_correction_p(cin): active-LOW Cin
    cc = cin ? 16'd0 : 16'd1;
    result = 16'd0;
    if (mode) begin
      // ---- logic operations (Cin irrelevant) ----
      case (sel)
        4'd0:    result = ~a;                 // ~A
        4'd1:    result = ~(a | b);           // ~(A|B)
        4'd2:    result = (~a) & b;           // ~A & B
        4'd3:    result = 16'h0000;           // logic 0
        4'd4:    result = ~(a & b);           // ~(A&B)
        4'd5:    result = ~b;                 // ~B
        4'd6:    result = a ^ b;              // A ^ B
        4'd7:    result = a & (~b);           // A & ~B
        4'd8:    result = (~a) | b;           // ~A | B
        4'd9:    result = ~(a ^ b);           // ~(A ^ B)
        4'd10:   result = b;                  // B
        4'd11:   result = a & b;              // A & B
        4'd12:   result = 16'hFFFF;           // logic 1
        4'd13:   result = a | (~b);           // A | ~B
        4'd14:   result = a | b;              // A | B
        default: result = a;                  // A  (sel = 4'd15)
      endcase
    end
    else begin
      // ---- arithmetic operations (active-LOW Cin) ----
      case (sel)
        4'd0:    result = a + cc;                          // A + carry
        4'd1:    result = (a | b) + cc;                    // (A|B) + carry
        4'd2:    result = (a | ~b) + cc;                   // (A|~B) + carry
        4'd3:    result = 16'hFFFF + cc;                   // minus 1 + carry
        4'd4:    result = (a + (a & ~b)) + cc;             // A + A~B + carry
        4'd5:    result = ((a | b) + (a & ~b)) + cc;       // (A|B) + A~B + carry
        4'd6:    result = (a - b) - cin;                   // A - B - carry
        4'd7:    result = (a & ~b) - cin;                  // A~B - carry
        4'd8:    result = (a + (a & b)) + cc;              // A + AB + carry
        4'd9:    result = (a + b) + cc;                    // A + B + carry
        4'd10:   result = ((a | ~b) + (a & b)) + cc;       // (A|~B) + AB + carry
        4'd11:   result = (a & b) - cin;                   // AB - carry
        4'd12:   result = (a + a) + cc;                    // A + A + carry
        4'd13:   result = ((a | b) + a) + cc;              // (A|B) + A + carry
        4'd14:   result = ((a | ~b) + a) + cc;             // (A|~B) + A + carry
        default: result = a - cin;                         // A - carry (4'd15)
      endcase
    end
  endfunction : golden_alu16
