// ============================================================
// File    : golden_382.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// 74382 golden (reference) model, included into alu_tb_pkg.
//
// Specification formulas:
//   F    - operation result;
//   Cn+4 - carry output (ripple expansion);
//   OVR  = Cn+3 ^ Cn+4 for arithmetic operations (verbatim
//          definition from the 74F382 datasheet), OVR = Cn+4
//          for the remaining functions (per Truth Table).
// The 16-bit ripple chain wrapper cascades four 4-bit slices:
// Cn+4 of slice i drives carry_in of slice i+1; chain OVR/Cn+4
// are taken from the most significant slice.
// ============================================================

// ---- 74382 slice (4-bit) ----
function automatic void golden_382(
    input  bit [3:0] a,
    input  bit [3:0] b,
    input  bit       cn,
    input  bit [2:0] s,
    output bit [3:0] f,
    output bit       ovr,
    output bit       cn4
);
    bit [4:0] sum;
    bit [3:0] a_op, b_op;  // actual addends of the 5-bit sum
    bit       cn3;         // carry into the MSB (Cn+3)
    sum = 5'd0; a_op = 4'd0; b_op = 4'd0; cn3 = 1'b0;
    case (alu_op_e'(s))
        OP_CLEAR: begin
            f = 4'h0; cn4 = 1'b1;
        end
        OP_B_SUB_A: begin
            a_op = ~a; b_op = b;
            sum = {1'b0, b_op} + {1'b0, a_op} + {4'b0, cn};
            f = sum[3:0]; cn4 = sum[4];
        end
        OP_A_SUB_B: begin
            a_op = a; b_op = ~b;
            sum = {1'b0, a_op} + {1'b0, b_op} + {4'b0, cn};
            f = sum[3:0]; cn4 = sum[4];
        end
        OP_ADD: begin
            a_op = a; b_op = b;
            sum = {1'b0, a_op} + {1'b0, b_op} + {4'b0, cn};
            f = sum[3:0]; cn4 = sum[4];
        end
        OP_XOR: begin
            f = a ^ b;
            cn4 = (a == 4'hF && b == 4'h0) ? cn :
                  (a == 4'hF && b == 4'hF) ? 1'b1 : 1'b0;
        end
        OP_OR: begin
            f = a | b;
            cn4 = (a == 4'hF && b == 4'hF) ? cn : 1'b0;
        end
        OP_AND: begin
            f = a & b;
            cn4 = (a == 4'hF && b == 4'hF) ? cn : (b == 4'h0) ? 1'b1 : 1'b0;
        end
        OP_PRESET: begin
            f = 4'hF;
            cn4 = (a == 4'hF && b == 4'hF) ? cn : 1'b0;
        end
        default: begin
            f = 4'h0; cn4 = 1'b0;
        end
    endcase
    // OVR: arithmetic operations -> Cn+3 ^ Cn+4 (datasheet definition);
    // cn3 is recovered from the full-adder identity:
    //   sum[3] = a_op[3] ^ b_op[3] ^ cn3
    if (s == OP_B_SUB_A || s == OP_A_SUB_B || s == OP_ADD) begin
        cn3 = sum[3] ^ a_op[3] ^ b_op[3];
        ovr = cn3 ^ cn4;
    end
    else begin
        ovr = cn4;
    end
endfunction : golden_382

  // ---- 4x74382 ripple chain (16-bit, Cn+4 -> Cn of the next slice) ----
  function automatic void golden_382_w16(
    input  bit [15:0] a,
    input  bit [15:0] b,
    input  bit        cn,
    input  bit [2:0]  s,
    output bit [15:0] f,
    output bit        ovr,
    output bit        cn4
  );
    bit [3:0] fi;
    bit       oi, ci, c;
    c = cn;
    ovr = 1'b0; cn4 = 1'b0;
    for (int i = 0; i < 4; i++) begin
      golden_382(a[i*4 +: 4], b[i*4 +: 4], c, s, fi, oi, ci);
      f[i*4 +: 4] = fi;
      c = ci;
      if (i == 3) begin      // chain outputs come from the MSB slice
        ovr = oi;
        cn4 = ci;
      end
    end
  endfunction : golden_382_w16
