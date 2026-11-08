// ============================================================
// File    : golden_dpi.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// DPI-C bridge to the C++ golden model (dpi/alu_golden_dpi.cpp,
// table-driven after classic_ALU/74181_16bit/tb_verilator/
// tb_alu_16.cpp) and model-selection wrappers.
//
// Layers:
//   alu_golden_*_cpp - raw DPI imports, plain int ABI (canonical
//                      mapping; packed bit vectors would require
//                      svBitVecVal* on the C side)
//   golden_*_cpp     - bit-typed wrappers with width masking
//   golden_*_sel     - model selectors: USE_CPP_REF config bit
//                      (alu_cfg_pkg) picks SV (0) or C++ (1)
// The environment calls only the *_sel functions; the sanity
// test checks both models via golden_* and golden_*_cpp.
// Requires golden_381.sv / golden_382.sv to be included first.
// ============================================================

  import "DPI-C" function void alu_golden_381_cpp(
    input  int a, input  int b, input  int cn, input  int s,
    output int f, output int p, output int g
  );

  import "DPI-C" function void alu_golden_382_cpp(
      input  int a, input  int b, input  int cn, input  int s,
      output int f, output int ovr, output int cn4
  );

  import "DPI-C" function void alu_golden_381_w16_cpp(
    input  int a, input  int b, input  int cn, input  int s,
    output int f, output int co
  );

  import "DPI-C" function void alu_golden_382_w16_cpp(
    input  int a, input  int b, input  int cn, input  int s,
    output int f, output int ovr, output int cn4
  );

  // ---- bit-typed wrappers over the raw int-ABI DPI imports ----

  function automatic void golden_381_cpp(
    input  bit [3:0] a,
    input  bit [3:0] b,
    input  bit       cn,
    input  bit [2:0] s,
    output bit [3:0] f,
    output bit       p,
    output bit       g
  );
    int fi, pi, gi;
    alu_golden_381_cpp(int'(a), int'(b), int'(cn), int'(s), fi, pi, gi);
    f = fi[3:0];
    p = pi[0];
    g = gi[0];
  endfunction : golden_381_cpp

  function automatic void golden_382_cpp(
    input  bit [3:0] a,
    input  bit [3:0] b,
    input  bit       cn,
    input  bit [2:0] s,
    output bit [3:0] f,
    output bit       ovr,
    output bit       cn4
  );
    int fi, oi, ci;
    alu_golden_382_cpp(int'(a), int'(b), int'(cn), int'(s), fi, oi, ci);
    f   = fi[3:0];
    ovr = oi[0];
    cn4 = ci[0];
  endfunction : golden_382_cpp

  function automatic void golden_381_w16_cpp(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cn,
    input  bit [2:0]  s,
    output bit [15:0] f,
    output bit        co
  );
    int fi, ci;
    alu_golden_381_w16_cpp(int'(a), int'(b), int'(cn), int'(s), fi, ci);
    f  = fi[15:0];
    co = ci[0];
  endfunction : golden_381_w16_cpp

  function automatic void golden_382_w16_cpp(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cn,
    input  bit [2:0]  s,
    output bit [15:0] f,
    output bit        ovr,
    output bit        cn4
  );
    int fi, oi, ci;
    alu_golden_382_w16_cpp(int'(a), int'(b), int'(cn), int'(s), fi, oi, ci);
    f   = fi[15:0];
    ovr = oi[0];
    cn4 = ci[0];
  endfunction : golden_382_w16_cpp

// ---- model selectors: SV golden (default) or C++ DPI golden ----

  function automatic void golden_381_sel(
    input  bit [3:0] a,
    input  bit [3:0] b,
    input  bit       cn,
    input  bit [2:0] s,
    output bit [3:0] f,
    output bit       p,
    output bit       g
  );
    if (USE_CPP_REF)
      golden_381_cpp(a, b, cn, s, f, p, g);
    else
      golden_381(a, b, cn, s, f, p, g);
  endfunction : golden_381_sel

  function automatic void golden_382_sel(
    input  bit [3:0] a,
    input  bit [3:0] b,
    input  bit       cn,
    input  bit [2:0] s,
    output bit [3:0] f,
    output bit       ovr,
    output bit       cn4
  );
    if (USE_CPP_REF)
      golden_382_cpp(a, b, cn, s, f, ovr, cn4);
    else
      golden_382(a, b, cn, s, f, ovr, cn4);
  endfunction : golden_382_sel

  function automatic void golden_381_w16_sel(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cn,
    input  bit [2:0]  s,
    output bit [15:0] f,
    output bit        co
  );
    if (USE_CPP_REF)
      golden_381_w16_cpp(a, b, cn, s, f, co);
    else
      golden_381_w16(a, b, cn, s, f, co);
  endfunction : golden_381_w16_sel

  function automatic void golden_382_w16_sel(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cn,
    input  bit [2:0]  s,
    output bit [15:0] f,
    output bit        ovr,
    output bit        cn4
  );
    if (USE_CPP_REF)
      golden_382_w16_cpp(a, b, cn, s, f, ovr, cn4);
    else
      golden_382_w16(a, b, cn, s, f, ovr, cn4);
  endfunction : golden_382_w16_sel
