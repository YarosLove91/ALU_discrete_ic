import alu_74382_pkg::*;
import tb_env_pkg::*;

task ds_vectors_test();
begin
    $display(">>>> Datasheet vectors test start...",);
    for (int sel_case = 0; sel_case < SEL_MAX; sel_case++) begin
        sel = sel_case[SELECT_W - 1:0];
        for (int in_case = 0; in_case < INPUTS_CASES_NUM; in_case++) begin
    
            inputs.carry_in = in_case[CARRY_IDX];
            inputs.port_a = extend_bit(in_case[PORT_A_IDX]);
            inputs.port_b = extend_bit(in_case[PORT_B_IDX]);
            
            #1;
    
            exp_out = expected_table[sel_case][in_case];
    
            if (exp_out == outputs) begin
                $display("SEL: %b, IN_CASE: %b - [OK]", sel_case[SELECT_W - 1:0], in_case[2:0]);
            end else begin
                err_cnt++;
                $display("SEL: %b, IN_CASE: %b - [FAIL]", sel_case[SELECT_W - 1:0], in_case[2:0]);
                $display("inputs    | sel: %b, port_a:%b, port_b: %b, carry_in: %b", sel, inputs.port_a, inputs.port_b, inputs.carry_in);
                $display("result    | expected: %b, actual: %b", exp_out.result,    outputs.result);
                $display("carry_out | expected: %b, actual: %b", exp_out.carry_out, outputs.carry_out);
                $display("overflow  | expected: %b, actual: %b", exp_out.overflow,  outputs.overflow);
            end
        end
    end
end
endtask : ds_vectors_test