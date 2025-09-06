import alu_74382_pkg::*;
import tb_env_pkg::*;

task dummy_ovf_test;
begin
    $display(">>>> Dummy overflow test start...");
    sel = OP_ADD;

    inputs.carry_in = 0;
    inputs.port_a   = 'd6;
    inputs.port_b   = 'd6;
            
    #1;
    //         F[3:0]   OVR   Cout
    exp_out = {4'b1100, 1'b1, 1'b0};

    if (exp_out == outputs) begin
        $display("ADD OVF POS - [OK]");
    end else begin
        err_cnt++;
        $display("ADD OVF POS - [FAIL]");
        $display("inputs    | sel: %b, port_a:%b, port_b: %b, carry_in: %b", sel, inputs.port_a, inputs.port_b, inputs.carry_in);
        $display("result    | expected: %b, actual: %b", exp_out.result,    outputs.result);
        $display("result_ext| %b", dut_alu.result_ext);
        $display("carry_out | expected: %b, actual: %b", exp_out.carry_out, outputs.carry_out);
        $display("overflow  | expected: %b, actual: %b", exp_out.overflow,  outputs.overflow);
    end

    inputs.carry_in = 0;
    inputs.port_a   = -6;
    inputs.port_b   = -6;

    #1;

    //         F[3:0]   OVR   Cout
    exp_out = {4'b0100, 1'b1, 1'b1};

    if (exp_out == outputs) begin
        $display("ADD OVF NEG - [OK]");
    end else begin
        err_cnt++;
        $display("ADD OVF NEG - [FAIL]");
        $display("inputs    | sel: %b, port_a:%b, port_b: %b, carry_in: %b", sel, inputs.port_a, inputs.port_b, inputs.carry_in);
        $display("inputs    | port_a_sub: %b, port_b_sub: %b", dut_alu.port_a_sub, dut_alu.port_a_sub);
        $display("result    | expected: %b, actual: %b", exp_out.result,    outputs.result);
        $display("result_ext| %b", dut_alu.result_ext);
        $display("carry_out | expected: %b, actual: %b", exp_out.carry_out, outputs.carry_out);
        $display("overflow  | expected: %b, actual: %b", exp_out.overflow,  outputs.overflow);
    end

    sel = OP_A_SUB_B;

    inputs.carry_in = 1; // act high
    inputs.port_a   = 6;
    inputs.port_b   = -6;
            
    #1;
    //         F[3:0]   OVR   Cout
    exp_out = {4'b1100, 1'b1, 1'b0};

    if (exp_out == outputs) begin
        $display("A-B OVF POS - [OK]");
    end else begin
        err_cnt++;
        $display("ADD OVF POS - [FAIL]");
        $display("inputs    | sel: %b, port_a:%b, port_b: %b, carry_in: %b", sel, inputs.port_a, inputs.port_b, inputs.carry_in);
        $display("result    | expected: %b, actual: %b", exp_out.result,    outputs.result);
        $display("result_ext| %b", dut_alu.result_ext);
        $display("carry_out | expected: %b, actual: %b", exp_out.carry_out, outputs.carry_out);
        $display("overflow  | expected: %b, actual: %b", exp_out.overflow,  outputs.overflow);
    end

    inputs.carry_in = 1; // act high
    inputs.port_a   = -6;
    inputs.port_b   = 6;
            
    #1;
    //         F[3:0]   OVR   Cout
    exp_out = {4'b0100, 1'b1, 1'b1};

    if (exp_out == outputs) begin
        $display("A-B OVF NEG - [OK]");
    end else begin
        err_cnt++;
        $display("ADD OVF NEG - [FAIL]");
        $display("inputs    | sel: %b, port_a:%b, port_b: %b, carry_in: %b", sel, inputs.port_a, inputs.port_b, inputs.carry_in);
        $display("result    | expected: %b, actual: %b", exp_out.result,    outputs.result);
        $display("result_ext| %b", dut_alu.result_ext);
        $display("carry_out | expected: %b, actual: %b", exp_out.carry_out, outputs.carry_out);
        $display("overflow  | expected: %b, actual: %b", exp_out.overflow,  outputs.overflow);
    end
end
endtask : dummy_ovf_test