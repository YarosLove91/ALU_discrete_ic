// ============================================================
// File    : top_alu_16.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 16-bit 74181+74182 ALU (Verilator)
// ------------------------------------------------------------
// DUT top: 16-bit ALU cascade based on four 74181 blocks and
// the 74182 carry-lookahead generator. Same cascade as the
// checked classic_ALU/74181_16bit/rtl/top/top_alu_16.v
// (A_bar = a, B_bar = b, result = F_bar, no data inversion),
// plus the half_carry / overflow flag outputs.
//
// Signal convention (74181 datasheet):
//   Cin/Cout/half_carry - active LOW (1 = no carry);
//   Cout       = carry_local[3] (C_out of the MSB 74181);
//   half_carry = carry_ic[0] (Cnx from the CLA, active LOW:
//                0 = carry from bit 3 into bit 4);
//   overflow   - signed overflow, sign-based scheme
//                (mode = 0 only; B is inverted for the
//                subtractive sel set 0010/0110/1010/1110).
// ============================================================
module alu16 (
  input  logic [15:0] a,
  input  logic [15:0] b,
  input  logic Cin,
  input  logic mode,
  input  logic [3:0] sel,
  output logic [15:0] result,
  output logic Cout,
  output logic nBo,
  output logic nGo,
  output logic half_carry, // half-carry flag (bit 3 -> bit 4, active LOW)
  output logic overflow    // signed overflow flag
);

  logic [2:0] carry_ic;
  logic [3:0] nGG;
  logic [3:0] nGP;
  logic [3:0] carry_local;
  logic [15:0] alu_f_bar;

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : alu_gen
      alu_74181 alu_inst (
        .C_in(i == 0 ? Cin : carry_ic[i-1]),
        .Select(sel),
        .Mode(mode),
        .A_bar(a[4*i +: 4]),
        .B_bar(b[4*i +: 4]),
        .CP_bar(nGP[i]),
        .CG_bar(nGG[i]),
        .C_out(carry_local[i]),
        .Equal(),
        .F_bar(alu_f_bar[4*i +: 4])
      );
    end
  endgenerate

  assign result = alu_f_bar;
  assign Cout   = carry_local[3];

  cla_74182 cla_inst (
    .Cn(Cin),
    .nPB(nGP),
    .nGB(nGG),
    .PBo(nBo),
    .GBo(nGo),
    .Cnx(carry_ic[0]),
    .Cny(carry_ic[1]),
    .Cnz(carry_ic[2])
  );

  assign half_carry = carry_ic[0];

  logic [15:0] b_eff;
  always_comb begin
    case (sel)
      4'b0010, 4'b0110, 4'b1010, 4'b1110: b_eff = ~b;
      default:                            b_eff =  b;
    endcase
  end
  assign overflow = (!mode) ? ((a[15] == b_eff[15]) && (result[15] != a[15])) : 1'b0;

endmodule : alu16
