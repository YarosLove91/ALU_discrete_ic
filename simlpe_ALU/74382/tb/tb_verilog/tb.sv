import alu_74382_pkg::*;
import tb_env_pkg::*;

module tb;

`ifdef SW_MODEL_COMP_TEST
alu_chain #(
    .ALU_CHAIN_W(TB_ALU_CHAIN_W),
    .ALU_W      (TB_ALU_W      )
) dut_alu_chain (
    .sel         (sel              ),
    .ch_carry_in (inputs.carry_in  ),
    .ch_port_a   (inputs.port_a    ),
    .ch_port_b   (inputs.port_b    ),
    .ch_result   (outputs.result   ),
    .ch_overflow (outputs.overflow ),
    .ch_carry_out(outputs.carry_out)
);
`else
alu_74382 #(
    .OPERAND_W(TB_OPERAND_W),
    .RESULT_W (TB_RESULT_W )
) dut_alu (
    .sel      (sel              ),
    .carry_in (inputs.carry_in  ),
    .port_a   (inputs.port_a    ),
    .port_b   (inputs.port_b    ),
    .result   (outputs.result   ),
    .overflow (outputs.overflow ),
    .carry_out(outputs.carry_out)
);
`endif

//--------testcases' tasks includes---------
`ifdef DATASHEET_VECTORS_TEST
    `include "ds_vectors_tst.sv"
`elsif DUMMY_OVF_TEST
    `include "dummy_ovf_test.sv"
`elsif SW_MODEL_COMP_TEST
`endif

//---------------test body------------------
initial begin
    $dumpfile("logs/vlt_dump.vcd");
    $dumpvars();
    err_cnt = 0;

    `ifdef DATASHEET_VECTORS_TEST
        ds_vectors_test();

    `elsif DUMMY_OVF_TEST
        dummy_ovf_test();

    `elsif SW_MODEL_COMP_TEST
        sw_model_comp_test();
    
    `else
        err_cnt++;

        $display(">>>> There is no such test!");
        $display("Available tests:");
        for (int i = 0; i < available_tests.size(); i++) begin
            $display("%s", available_tests[i]);
        end
        $display("\n");
    `endif

    $display(">>>>TEST END");
    if (err_cnt)
        $display(">>>>FAIL\n");
    else
        $display(">>>>SUCCESS\n");
    $finish;
end

endmodule : tb