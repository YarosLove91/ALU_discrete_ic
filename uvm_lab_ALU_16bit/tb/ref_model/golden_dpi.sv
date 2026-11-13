// ============================================================
// File    : golden_dpi.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// DPI-C bridge to the C++ golden model (dpi/alu_golden_dpi.cpp,
// table-driven after classic_ALU/74181_16bit/tb/tb_verilator/
// tb_alu_16.cpp) and model-selection wrapper.
//
// Layers:
//   alu_golden_alu16_cpp - raw DPI import, plain int ABI
//                          (canonical mapping; packed bit vectors
//                          would require svBitVecVal* on the C side)
//   golden_alu16_cpp     - bit-typed wrapper with width masking
//   golden_alu16_sel     - model selector: USE_CPP_REF config bit
//                          (alu_cfg_pkg) picks SV (0) or C++ (1)
// The environment calls only the *_sel function.
// Requires golden_alu16.sv to be included first.
// ============================================================

  import "DPI-C" function void alu_golden_alu16_cpp(
    input  int a, input  int b, input  int cin, input  int mode, input  int sel,
    output int result
  );

  // ---- bit-typed wrapper over the raw int-ABI DPI import ----

  function automatic void golden_alu16_cpp(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cin,
    input  bit        mode,
    input  bit [3:0]  sel,
    output bit [15:0] result
  );
    int r;
    alu_golden_alu16_cpp(int'(a), int'(b), int'(cin), int'(mode), int'(sel), r);
    result = r[15:0];
  endfunction : golden_alu16_cpp

  // ---- model selector: SV golden (default) or C++ DPI golden ----

  function automatic void golden_alu16_sel(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cin,
    input  bit        mode,
    input  bit [3:0]  sel,
    output bit [15:0] result
  );
    if (USE_CPP_REF)
      golden_alu16_cpp(a, b, cin, mode, sel, result);
    else
      golden_alu16(a, b, cin, mode, sel, result);
  endfunction : golden_alu16_sel
