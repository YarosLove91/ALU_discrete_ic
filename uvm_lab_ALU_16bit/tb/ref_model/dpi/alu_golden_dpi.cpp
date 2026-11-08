// ============================================================
// File    : alu_golden_dpi.cpp
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// C++ golden (reference) model of the alu16 result, called from
// SystemVerilog via DPI-C. Table-driven design after the student
// work classic_ALU/74181_16bit/tb_verilator/tb_alu_16.cpp
// (operation tables as std::function lambdas + carry_correction_p).
//
// Model selection is done on the SV side by the USE_CPP_REF
// config bit (alu_cfg_pkg): 0 = SV golden (default), 1 = this
// C++ model.
//
// Semantics (74181 function table, positive logic):
//   logic (mode = 1)    : result = f(A, B), Cin is irrelevant
//   arithmetic (mode = 0): additive family   expr + ~Cin
//                          subtractive family expr - Cin
//   Cin is active LOW (carry_correction_p: Cin==1 -> 0, else 1)
// Difference from the source tb_alu_16.cpp: the arithmetic is
// kept in uint16_t with explicit masks (the source uses int16_t,
// whose signedness hides sign-extension on ~ and overflows).
// ============================================================
#include <cstdint>
#include <array>
#include <functional>

namespace {

  using u16 = uint16_t;

  // active-LOW carry-in correction (after tb_alu_16.cpp)
  static inline u16 carry_correction_p(int cin) {
    return (cin == 1) ? u16(0) : u16(1);
  }

  // ------------------------------------------------------------
  // logic operations (mode = 1): result(a, b) -> 16 bit
  // ------------------------------------------------------------
  using LogicOp = std::function<u16(u16, u16)>;

  const std::array<LogicOp, 16> kLogicOps = {{
    [](u16 a, u16 b) { return u16(~a); },                 // 0x0 ~A
    [](u16 a, u16 b) { return u16(~(a | b)); },           // 0x1 ~(A|B)
    [](u16 a, u16 b) { return u16((~a) & b); },           // 0x2 ~A & B
    [](u16 a, u16 b) { return u16(0x0000); },             // 0x3 logic 0
    [](u16 a, u16 b) { return u16(~(a & b)); },           // 0x4 ~(A&B)
    [](u16 a, u16 b) { return u16(~b); },                 // 0x5 ~B
    [](u16 a, u16 b) { return u16(a ^ b); },              // 0x6 A ^ B
    [](u16 a, u16 b) { return u16(a & (~b)); },           // 0x7 A & ~B
    [](u16 a, u16 b) { return u16((~a) | b); },           // 0x8 ~A | B
    [](u16 a, u16 b) { return u16(~(a ^ b)); },           // 0x9 ~(A ^ B)
    [](u16 a, u16 b) { return u16(b); },                  // 0xA B
    [](u16 a, u16 b) { return u16(a & b); },              // 0xB A & B
    [](u16 a, u16 b) { return u16(0xFFFF); },             // 0xC logic 1
    [](u16 a, u16 b) { return u16(a | (~b)); },           // 0xD A | ~B
    [](u16 a, u16 b) { return u16(a | b); },              // 0xE A | B
    [](u16 a, u16 b) { return u16(a); },                  // 0xF A
  }};

  // ------------------------------------------------------------
  // arithmetic operations (mode = 0): result(a, b, cin) -> 16 bit
  // additive family uses carry_correction_p(cin); the subtractive
  // family (0x6, 0x7, 0xB, 0xF) subtracts the raw active-LOW Cin
  // ------------------------------------------------------------
  using MathOp = std::function<u16(u16, u16, int)>;

  const std::array<MathOp, 16> kMathOps = {{
    [](u16 a, u16 b, int cin) {                                     // 0x0
      return u16(a + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x1
      return u16((a | b) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x2
      return u16((a | u16(~b)) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x3
      return u16(0xFFFF + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x4
      return u16((a + (a & u16(~b))) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x5
      return u16(((a | b) + (a & u16(~b))) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x6
      return u16((a - b) - u16(cin & 1));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x7
      return u16((a & u16(~b)) - u16(cin & 1));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x8
      return u16((a + (a & b)) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0x9
      return u16((a + b) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0xA
      return u16(((a | u16(~b)) + (a & b)) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0xB
      return u16((a & b) - u16(cin & 1));
    },
    [](u16 a, u16 b, int cin) {                                     // 0xC
      return u16((a + a) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0xD
      return u16(((a | b) + a) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0xE
      return u16(((a | u16(~b)) + a) + carry_correction_p(cin));
    },
    [](u16 a, u16 b, int cin) {                                     // 0xF
      return u16(a - u16(cin & 1));
    },
  }};

}  // namespace

// ------------------------------------------------------------
// DPI-C export (SV import lives in tb/ref_model/golden_dpi.sv).
// ABI note: the interface uses plain int/int* (canonical DPI
// mapping for 32-bit 2-state values) instead of packed bit
// vectors, whose C representation is svBitVecVal* - the SV-side
// wrapper does the width masking/conversion.
// ------------------------------------------------------------
extern "C" {

  void alu_golden_alu16_cpp(int a, int b, int cin, int mode, int sel,
                            int* result) {
    const u16 aw = u16(a & 0xFFFF);
    const u16 bw = u16(b & 0xFFFF);
    const int s  = sel & 0xF;
    const int m  = mode & 1;
    const int c  = cin & 1;
    *result = (m != 0) ? int(kLogicOps[s](aw, bw))
                       : int(kMathOps[s](aw, bw, c));
  }

}  // extern "C"
