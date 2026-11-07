// ============================================================
// File    : golden_381.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// 74381 golden (reference) model, included into alu_tb_pkg.
//
// Specification formulas:
//   F - operation result;
//   P/G - group propagate/generate outputs (active LOW) for the
//   74182 carry-lookahead generator:
//     P = ~(&pi)
//     G = ~(gi3 | pi3&gi2 | pi3&pi2&gi1 | pi3&pi2&pi1&gi0)
//   pi/gi - per-bit propagate/generate of the selected operation.
// The 16-bit chain wrapper cascades four 4-bit slices with
//   Co = ~G | (~P & Cn)
// ============================================================

  // ---- 74381 slice (4-bit) ----
  function automatic void golden_381(
    input  bit [3:0] a,
    input  bit [3:0] b,
    input  bit       cn,
    input  bit [2:0] s,
    output bit [3:0] f,
    output bit       p,   // pin P (active LOW)
    output bit       g    // pin G (active LOW)
  );
    bit [3:0] pi, gi;
    bit [4:0] sum;
    case (alu_op_e'(s))
      OP_CLEAR: begin
        f = 4'h0; pi = 4'hF; gi = 4'hF;
      end
      OP_B_SUB_A: begin
        sum = {1'b0, b} + {1'b0, ~a} + {4'b0, cn};
        f = sum[3:0]; pi = ~a | b; gi = ~a & b;
      end
      OP_A_SUB_B: begin
        sum = {1'b0, a} + {1'b0, ~b} + {4'b0, cn};
        f = sum[3:0]; pi = a | ~b; gi = a & ~b;
      end
      OP_ADD: begin
        sum = {1'b0, a} + {1'b0, b} + {4'b0, cn};
        f = sum[3:0]; pi = a | b; gi = a & b;
      end
      OP_XOR: begin
        f = a ^ b;
        // per the truth table: A=0, B=F suppresses propagate
        pi = (a == 4'h0 && b == 4'hF) ? 4'h0 : (a | b);
        gi = a & b;
      end
      OP_OR: begin
        f = a | b;
        pi = (a == 4'hF && b == 4'hF) ? 4'hF : 4'h0;
        gi = 4'h0;
      end
      OP_AND: begin
        f = a & b;
        if ((a == 4'h0 && b == 4'h0) || (a == 4'hF && b == 4'h0)) begin
          pi = 4'hF; gi = 4'hF;
        end
        else if (a == 4'h0 && b == 4'hF) begin
          pi = 4'h0; gi = 4'h0;
        end
        else begin
          pi = 4'hF; gi = 4'h0;
        end
      end
      OP_PRESET: begin
        f = 4'hF;
        pi = (a == 4'hF && b == 4'hF) ? 4'hF : 4'h0;
        gi = 4'h0;
      end
      default: begin
        f = 4'h0; pi = 4'h0; gi = 4'h0;
      end
    endcase
    p = ~(&pi);
    g = ~(gi[3] | (pi[3] & gi[2]) |
          (pi[3] & pi[2] & gi[1]) |
          (pi[3] & pi[2] & pi[1] & gi[0]));
  endfunction : golden_381

  // ---- 4x74381 chain (16-bit, carry via P/G lookahead formula) ----
  function automatic void golden_381_w16(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cn,
    input  bit [2:0]  s,
    output bit [15:0] f,
    output bit        co
);
    bit [3:0] fi;
    bit       pi, gi, c;
    c = cn;
    for (int i = 0; i < 4; i++) begin
      golden_381(a[i*4 +: 4], b[i*4 +: 4], c, s, fi, pi, gi);
      f[i*4 +: 4] = fi;
      c = ~gi | (~pi & c);   // Co = ~G | (~P & Cn) - expansion formula
    end
    co = c;
  endfunction : golden_381_w16
