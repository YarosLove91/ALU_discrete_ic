// ============================================================
// File    : alu_ref_model.sv
// Author  : M.YarosLove <yoruk91@gmail.com>
// Project : UVM verification lab for 74381/74382 ALUs (Verilator)
// ------------------------------------------------------------
// Reference model (predictor): receives a transaction carrying
// the DUT inputs and actual outputs from the TLM FIFO, computes
// the expected values with the package golden functions
// (golden_381/golden_382 and their 16-bit chain wrappers) and
// forwards it to the scoreboard.
//
// For 16-bit chains, arithmetic operations are additionally
// cross-checked against direct 17-bit arithmetic (golden-model
// self-check protecting it from typos).
// ============================================================
  class alu_ref_model extends uvm_component;
    `uvm_component_utils(alu_ref_model)

    uvm_get_port      #(alu_transaction) in_port;
    uvm_analysis_port #(alu_transaction) ap;

    function new(string name = "alu_ref_model", uvm_component parent = null);
      super.new(name, parent);
      in_port = new("in_port", this);
      ap      = new("ap", this);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
      alu_transaction tr;
      super.run_phase(phase);
      forever begin
        in_port.get(tr);
        predict(tr);
        ap.write(tr);
      end
    endtask : run_phase

    // Fill the exp_* fields of the transaction from its inputs
    function void predict(alu_transaction tr);
      case (DUT_KIND)
        DUT_381_4: begin
            golden_381 (tr.a[3:0],
                        tr.b[3:0],
                        tr.cn,
                        tr.s,
                        tr.exp_f[3:0],
                        tr.exp_p,
                        tr.exp_g);
        end
        DUT_382_4: begin
            golden_382 (tr.a[3:0],
                        tr.b[3:0],
                        tr.cn,
                        tr.s,
                        tr.exp_f[3:0],
                        tr.exp_ovr,
                        tr.exp_cn4);
        end
        DUT_381_16: begin
          golden_381_w16(tr.a, tr.b, tr.cn, tr.s, tr.exp_f, tr.exp_cn4);
          xcheck_arith_16(tr);
        end
        DUT_382_16: begin
          golden_382_w16(tr.a, tr.b, tr.cn, tr.s, tr.exp_f, tr.exp_ovr, tr.exp_cn4);
          xcheck_arith_16(tr);
        end
      endcase
    endfunction : predict

    // Cross-check: chain golden model vs direct 17-bit arithmetic
    // (arithmetic operations only)
    function void xcheck_arith_16(alu_transaction tr);
      bit [15:0] ea, eb;
      bit [16:0] sum;
      bit        cn_msb;
      bit        is_add, is_bsub, is_asub;
      is_add  = (tr.s == OP_ADD);
      is_bsub = (tr.s == OP_B_SUB_A);
      is_asub = (tr.s == OP_A_SUB_B);

      if (!is_add && !is_bsub && !is_asub) begin
        return;
      end

      if (is_add) begin
        ea = tr.a;  eb = tr.b;
      end else if (is_bsub) begin
        ea = ~tr.a; eb = tr.b;   // b + ~a + cn
      end else begin
        ea = tr.a;  eb = ~tr.b;  // a + ~b + cn
      end

      sum = {1'b0, ea} + {1'b0, eb} + {16'b0, tr.cn};

      if (tr.exp_f !== sum[15:0] || tr.exp_cn4 !== sum[16]) begin
        g_refmodel_errors++;
        `uvm_error({get_type_name(), ".XCHK_SUM"},
            $sformatf("16-bit golden model self-check failed: %s | chain f=%0h co=%0b, arithmetic f=%0h co=%0b",
                tr.inputs2str(),
                tr.exp_f,
                tr.exp_cn4,
                sum[15:0],
                sum[16]))
      end
      if (FAM_382) begin
        // OVR = Cn+15 ^ Cn+16 (carry into MSB ^ carry out)
        cn_msb = sum[15] ^ ea[15] ^ eb[15];
        if (tr.exp_ovr !== (cn_msb ^ sum[16])) begin
          g_refmodel_errors++;
          `uvm_error({get_type_name(), ".XCHK_OVR"},
              $sformatf("16-bit golden OVR self-check failed: %s | chain ovr=%0b, arithmetic ovr=%0b",
                  tr.inputs2str(),
                  tr.exp_ovr,
                  cn_msb ^ sum[16]))
        end
      end
    endfunction : xcheck_arith_16

  endclass : alu_ref_model
