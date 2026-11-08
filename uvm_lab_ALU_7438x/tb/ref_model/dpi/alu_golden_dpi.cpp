// ============================================================
// File    : alu_golden_dpi.cpp
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// C++ golden (reference) model, called from SystemVerilog via
// DPI-C. Table-driven design after the student work
// classic_ALU/74181_16bit/tb_verilator/tb_alu_16.cpp
// (operation tables as std::function lambdas).
//
// Model selection is done on the SV side by the USE_CPP_REF
// config bit (alu_cfg_pkg): 0 = SV golden (default), 1 = this
// C++ model. Both models are cross-verified against the
// datasheet truth tables by alu_sanity_test.
//
// Semantics per 74F381/74F382 datasheets:
//   74381: F + group P/G outputs (active LOW) for the 74182 CLA
//          P = ~(&pi), G = ~(gi3 | pi3&gi2 | pi3&pi2&gi1 |
//                          pi3&pi2&pi1&gi0)
//   74382: F + Cn+4 carry output + OVR, where for arithmetic
//          operations OVR = Cn+3 ^ Cn+4 (datasheet definition),
//          for the rest OVR = Cn+4 (per Truth Table)
//   16-bit: 74381 chain carry Co = ~G | (~P & Cn) (lookahead),
//           74382 chain ripple Cn+4 -> next slice carry_in;
//           chain OVR/Cn+4 come from the most significant slice
// ============================================================
#include <cstdint>
#include <array>
#include <functional>

namespace {

  using u8  = uint8_t;
  using u16 = uint16_t;

  // Operation encodings (Function Select Table, shared by 74381/74382)
  enum Sel : unsigned {
    SEL_CLEAR   = 0,  // 000
    SEL_B_SUB_A = 1,  // 001
    SEL_A_SUB_B = 2,  // 010
    SEL_ADD     = 3,  // 011
    SEL_XOR     = 4,  // 100
    SEL_OR      = 5,  // 101
    SEL_AND     = 6,  // 110
    SEL_PRESET  = 7   // 111
  };

  // ------------------------------------------------------------
  // 74381: table of per-operation lambdas (after tb_alu_16.cpp)
  //   result(a,b,cn) -> F3..F0
  //   prop(a,b)      -> per-bit propagate vector pi
  //   gen(a,b)       -> per-bit generate vector gi
  // ------------------------------------------------------------
  using OpFn  = std::function<u8(u8, u8, u8)>;
  using PgFn  = std::function<u8(u8, u8)>;

  struct Op381 {
    OpFn result;
    PgFn prop;
    PgFn gen;
  };

  const std::array<Op381, 8> kOps381 = {{
    // CLEAR: F = 0
    { [](u8, u8, u8) { return u8(0x0); },
      [](u8, u8) { return u8(0xF); },
      [](u8, u8) { return u8(0xF); } },
    // B - A: F = B + ~A + Cn
    { [](u8 a, u8 b, u8 cn) { return u8((b + u8(~a) + cn) & 0xF); },
      [](u8 a, u8 b) { return u8((u8(~a) | b) & 0xF); },
      [](u8 a, u8 b) { return u8((u8(~a) & b) & 0xF); } },
    // A - B: F = A + ~B + Cn
    { [](u8 a, u8 b, u8 cn) { return u8((a + u8(~b) + cn) & 0xF); },
      [](u8 a, u8 b) { return u8((a | u8(~b)) & 0xF); },
      [](u8 a, u8 b) { return u8((a & u8(~b)) & 0xF); } },
    // A + B: F = A + B + Cn
    { [](u8 a, u8 b, u8 cn) { return u8((a + b + cn) & 0xF); },
      [](u8 a, u8 b) { return u8((a | b) & 0xF); },
      [](u8 a, u8 b) { return u8((a & b) & 0xF); } },
    // A ^ B; truth table: A=0, B=F suppresses propagate
    { [](u8 a, u8 b, u8) { return u8((a ^ b) & 0xF); },
      [](u8 a, u8 b) { return u8((a == 0x0 && b == 0xF) ? 0x0 : ((a | b) & 0xF)); },
      [](u8 a, u8 b) { return u8((a & b) & 0xF); } },
    // A | B
    { [](u8 a, u8 b, u8) { return u8((a | b) & 0xF); },
      [](u8 a, u8 b) { return u8((a == 0xF && b == 0xF) ? 0xF : 0x0); },
      [](u8, u8) { return u8(0x0); } },
    // A & B
    { [](u8 a, u8 b, u8) { return u8((a & b) & 0xF); },
      [](u8 a, u8 b) {
          if ((a == 0x0 && b == 0x0) || (a == 0xF && b == 0x0)) return u8(0xF);
          if (a == 0x0 && b == 0xF) return u8(0x0);
          return u8(0xF);
      },
      [](u8 a, u8 b) {
          if ((a == 0x0 && b == 0x0) || (a == 0xF && b == 0x0)) return u8(0xF);
          if (a == 0x0 && b == 0xF) return u8(0x0);
          return u8(0x0);
      } },
    // PRESET: F = 1111
    { [](u8, u8, u8) { return u8(0xF); },
      [](u8 a, u8 b) { return u8((a == 0xF && b == 0xF) ? 0xF : 0x0); },
      [](u8, u8) { return u8(0x0); } },
  }};

  struct Res381 { u8 f; u8 p; u8 g; };

  // Group P/G (active LOW pins) from the per-bit vectors
  static inline u8 group_p(u8 pi) {
    return (pi == 0xF) ? 0 : 1;
  }

  static inline u8 group_g(u8 pi, u8 gi) {
    const int p3 = (pi >> 3) & 1, p2 = (pi >> 2) & 1, p1 = (pi >> 1) & 1;
    const int g3 = (gi >> 3) & 1, g2 = (gi >> 2) & 1, g1 = (gi >> 1) & 1, g0 = gi & 1;
    const int grp = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0);
    return grp ? 0 : 1;
  }

  static Res381 golden_381_slice(u8 a, u8 b, u8 cn, u8 s) {
    const Op381& op = kOps381[s & 7];
    const u8 pi = op.prop(a, b);
    const u8 gi = op.gen(a, b);
    Res381 r;
    r.f = op.result(a, b, cn & 1);
    r.p = group_p(pi);
    r.g = group_g(pi, gi);
    return r;
  }

  // ------------------------------------------------------------
  // 74382: slice model. Arithmetic keeps the actual 5-bit sum so
  // OVR can follow the datasheet identity OVR = Cn+3 ^ Cn+4 with
  // Cn+3 recovered from the full-adder identity
  //   sum[3] = x[3] ^ y[3] ^ Cn+3.
  // ------------------------------------------------------------
  struct Res382 { u8 f;
                  u8 ovr;
                  u8 cn4; };

  static Res382 golden_382_slice(u8 a, u8 b, u8 cn, u8 s) {
    Res382 r{0, 0, 0};
    cn &= 1;
    unsigned sum = 0;
    u8 a_op = 0, b_op = 0;
    bool arith = true;
    switch (s & 7) {
        case SEL_CLEAR:
            r.f = 0x0; r.cn4 = 1; arith = false;
            break;
        case SEL_B_SUB_A:
            a_op = u8(~a) & 0xF; b_op = b & 0xF;
            sum = unsigned(b_op) + a_op + cn;   // B + ~A + Cn
            break;
        case SEL_A_SUB_B:
            a_op = a & 0xF; b_op = u8(~b) & 0xF;
            sum = unsigned(a_op) + b_op + cn;   // A + ~B + Cn
            break;
        case SEL_ADD:
            a_op = a & 0xF; b_op = b & 0xF;
            sum = unsigned(a_op) + b_op + cn;   // A + B + Cn
            break;
        case SEL_XOR:
            r.f = u8((a ^ b) & 0xF);
            r.cn4 = (a == 0xF && b == 0x0) ? cn :
                    (a == 0xF && b == 0xF) ? u8(1) : u8(0);
            arith = false;
            break;
        case SEL_OR:
            r.f = u8((a | b) & 0xF);
            r.cn4 = (a == 0xF && b == 0xF) ? cn : u8(0);
            arith = false;
            break;
        case SEL_AND:
            r.f = u8((a & b) & 0xF);
            r.cn4 = (a == 0xF && b == 0xF) ? cn : (b == 0x0) ? u8(1) : u8(0);
            arith = false;
            break;
        case SEL_PRESET:
        default:
            r.f = 0xF;
            r.cn4 = (a == 0xF && b == 0xF) ? cn : u8(0);
            arith = false;
            break;
    }
    if (arith) {
        r.f   = u8(sum & 0xF);
        r.cn4 = u8((sum >> 4) & 1);
        const u8 cn3 = u8(((r.f >> 3) & 1) ^ ((a_op >> 3) & 1) ^ ((b_op >> 3) & 1));
        r.ovr = u8(cn3 ^ r.cn4);
    } else {
        r.ovr = r.cn4;   // per Truth Table: non-arithmetic OVR = Cn+4
    }
    return r;
  }

}  // namespace

// ------------------------------------------------------------
// DPI-C exports (SV imports live in tb/ref_model/golden_dpi.sv).
// ABI note: the interface uses plain int/int* (canonical DPI
// mapping for 32-bit 2-state values) instead of packed bit
// vectors, whose C representation is svBitVecVal* - the SV-side
// wrappers do the width masking/conversion.
// ------------------------------------------------------------
extern "C" {

  void alu_golden_381_cpp(int a, int b, int cn, int s, int* f, int* p, int* g) {
    const Res381 r = golden_381_slice(u8(a & 0xF), u8(b & 0xF), u8(cn & 1), u8(s & 7));
    *f = r.f; *p = r.p; *g = r.g;
  }

  void alu_golden_382_cpp(int a, int b, int cn, int s, int* f, int* ovr, int* cn4) {
    const Res382 r = golden_382_slice(u8(a & 0xF), u8(b & 0xF), u8(cn & 1), u8(s & 7));
    *f = r.f; *ovr = r.ovr; *cn4 = r.cn4;
  }

  // 4x74381 chain, 16-bit: carry Co = ~G | (~P & Cn) (pins active LOW)
  void alu_golden_381_w16_cpp(int a, int b, int cn, int s, int* f, int* co) {
    const u16 aw = u16(a & 0xFFFF), bw = u16(b & 0xFFFF);
    u8 c = u8(cn & 1);
    u16 res = 0;
    for (int i = 0; i < 4; i++) {
        const Res381 r = golden_381_slice(u8((aw >> (4 * i)) & 0xF),
                                          u8((bw >> (4 * i)) & 0xF), c, u8(s & 7));
        res |= u16(r.f & 0xF) << (4 * i);
        c = u8((!r.g) | ((!r.p) & c));
    }
    *f = res;
    *co = c;
  }

  // 4x74382 ripple chain, 16-bit: Cn+4 -> carry_in of the next slice;
  // chain OVR/Cn+4 come from the most significant slice
  void alu_golden_382_w16_cpp(int a, int b, int cn, int s, int* f, int* ovr, int* cn4) {
    const u16 aw = u16(a & 0xFFFF), bw = u16(b & 0xFFFF);
    u8 c = u8(cn & 1);
    u16 res = 0;
    *ovr = 0; *cn4 = 0;
    for (int i = 0; i < 4; i++) {
        const Res382 r = golden_382_slice(u8((aw >> (4 * i)) & 0xF),
                                          u8((bw >> (4 * i)) & 0xF), c, u8(s & 7));
        res |= u16(r.f & 0xF) << (4 * i);
        c = r.cn4;
        if (i == 3) { *ovr = r.ovr; *cn4 = r.cn4; }
    }
    *f = res;
  }

}  // extern "C"
