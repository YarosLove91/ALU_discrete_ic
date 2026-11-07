// ============================================================
// File    : alu_ds_tables.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Datasheet truth tables (golden data), included into alu_tb_pkg.
//
// Row layout: f - outputs F3..F0;
//   74381: x1 = G (active LOW), x2 = P (active LOW)
//   74382: x1 = OVR,           x2 = Cn+4
// Indexing: [sel][in_case], in_case = {cn, a_bit, b_bit},
//   a = a_bit ? 4'hF : 4'h0, b = b_bit ? 4'hF : 4'h0.
// For operations with Cn = X the rows are identical for both cn.
// Source: datasheets/74F381.pdf, datasheets/74F382.pdf
// ============================================================

typedef struct packed {
    bit [3:0] f;
    bit       x1;
    bit       x2;
} ds_row_t;

  function automatic ds_row_t ds381_row(int sel, int in_case);
    int ab;
    ab = in_case[1:0];
    case (sel)
      0: ds381_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};  // CLEAR: F=0, G=L, P=L
      1: case (in_case)                                // B MINUS A
            0: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
            1: ds381_row = '{f: 4'hE, x1: 1'b0, x2: 1'b0};
            2: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
            3: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
            4: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b0};
            5: ds381_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            6: ds381_row = '{f: 4'h1, x1: 1'b1, x2: 1'b1};
            7: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b0};
          endcase
      2: case (in_case)                                // A MINUS B
            0: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
            1: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
            2: ds381_row = '{f: 4'hE, x1: 1'b0, x2: 1'b0};
            3: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
            4: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b0};
            5: ds381_row = '{f: 4'h1, x1: 1'b1, x2: 1'b1};
            6: ds381_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            7: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b0};
          endcase
      3: case (in_case)                                // A PLUS B
            0: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
            1: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
            2: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
            3: ds381_row = '{f: 4'hE, x1: 1'b0, x2: 1'b0};
            4: ds381_row = '{f: 4'h1, x1: 1'b1, x2: 1'b1};
            5: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b0};
            6: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b0};
            7: ds381_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
          endcase
      4: case (ab)                                     // A XOR B (Cn=X)
            0: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
            1: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            2: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
            3: ds381_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
          endcase
      5: case (ab)                                     // A OR B (Cn=X)
            0: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
            1: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            2: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            3: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
          endcase
      6: case (ab)                                     // A AND B (Cn=X)
            0: ds381_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
            1: ds381_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
            2: ds381_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
            3: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
          endcase
      7: case (ab)                                     // PRESET (Cn=X)
            0: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            1: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            2: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            3: ds381_row = '{f: 4'hF, x1: 1'b1, x2: 1'b0};
          endcase
      default: ds381_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
    endcase
  endfunction : ds381_row

  function automatic ds_row_t ds382_row(int sel, int in_case);
    int ab;
    ab = in_case[1:0];
    case (sel)
      0: ds382_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};  // CLEAR: OVR=H, Cn+4=H
      1: case (in_case)                                // B MINUS A
            0: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            1: ds382_row = '{f: 4'hE, x1: 1'b0, x2: 1'b1};
            2: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
            3: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            4: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b1};
            5: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b1};
            6: ds382_row = '{f: 4'h1, x1: 1'b0, x2: 1'b0};
            7: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b1};
          endcase
      2: case (in_case)                                // A MINUS B
            0: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            1: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
            2: ds382_row = '{f: 4'hE, x1: 1'b0, x2: 1'b1};
            3: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            4: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b1};
            5: ds382_row = '{f: 4'h1, x1: 1'b0, x2: 1'b0};
            6: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b1};
            7: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b1};
          endcase
      3: case (in_case)                                // A PLUS B
            0: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
            1: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            2: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            3: ds382_row = '{f: 4'hE, x1: 1'b0, x2: 1'b1};
            4: ds382_row = '{f: 4'h1, x1: 1'b0, x2: 1'b0};
            5: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b1};
            6: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b1};
            7: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b1};
          endcase
      4: begin                                         // A XOR B
          case (ab)
            0: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
            1: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            3: ds382_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
            default: begin  // ab == 2: a=F, b=0 -> Cn+4 = Cn
              if (in_case[2])
                ds382_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
              else
                ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
            end
          endcase
      end
      5: begin                                         // A OR B
        case (ab)
          0: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
          1: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
          2: ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
          default: begin  // ab == 3: a=F, b=F -> OVR/Cn+4 = Cn
            if (in_case[2])
              ds382_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            else
              ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
          end
        endcase
      end
      6: begin                                         // A AND B
        case (ab)
          0: ds382_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
          1: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
          2: ds382_row = '{f: 4'h0, x1: 1'b1, x2: 1'b1};
          default: begin  // ab == 3: a=F, b=F -> OVR/Cn+4 = Cn
            if (in_case[2])
              ds382_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
            else
              ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
          end
        endcase
      end
      7: begin                                         // PRESET
        if (ab == 3 && in_case[2])
          ds382_row = '{f: 4'hF, x1: 1'b1, x2: 1'b1};
        else
          ds382_row = '{f: 4'hF, x1: 1'b0, x2: 1'b0};
      end
      default: ds382_row = '{f: 4'h0, x1: 1'b0, x2: 1'b0};
    endcase
  endfunction : ds382_row
