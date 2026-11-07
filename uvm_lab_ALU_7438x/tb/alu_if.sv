// ============================================================
// File    : alu_if.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// ALU interface (shared by the 74381 and 74382 families,
// width-parameterized).
//
//   a, b, s, cn  - stimuli (driver -> DUT)
//   f, p, g      - 74381 family outputs (P/G feed the 74182 CLA)
//   f, ovr, cn4  - 74382 family outputs (cn4 = Co on 74381_16)
//   valid        - qualification signal: the "inputs/outputs"
//                  pair is valid for one clock (TB protocol)
// ============================================================
  interface alu_if #(parameter int W = 4) (
    input logic clk,
    input logic rst
  );

    logic [W-1:0] a;
    logic [W-1:0] b;
    logic [2:0]   s;
    logic         cn;

    logic [W-1:0] f;
    logic         p;
    logic         g;
    logic         ovr;
    logic         cn4;

    logic         valid;

    initial begin
        a     = '0;
        b     = '0;
        s     = '0;
        cn    = '0;
        valid = '0;
    end

  endinterface : alu_if
