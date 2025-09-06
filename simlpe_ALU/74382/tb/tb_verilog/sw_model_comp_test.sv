import alu_74382_pkg::*;
import tb_env_pkg::*;

task sw_model_comp_test();

t_tst_vector test_vector;

begin
    $display(">>>> Software model comparison test start...");

    test_vector = get_test_vector();

    if (SW_TEST_OP == "a-b")
        sel = OP_A_SUB_B;    
    else if (SW_TEST_OP == "b-a")
        sel = OP_B_SUB_A;    
    else
        sel = OP_ADD;
    
    for (int i = 0; i < TEST_VECTOR_SIZE; i++) begin

        inputs.carry_in = test_vector.carry_in[i];
        inputs.port_a   = test_vector.port_a[i];
        inputs.port_b   = test_vector.port_b[i];

        #1;

        if (test_vector.result[i] != outputs.result)
            err_cnt++;

        // for subtraction test we don't check carry out
        if (sel == OP_ADD) begin
            if (test_vector.carry_out[i] != outputs.carry_out)
                err_cnt++;
        end

        if (err_cnt == 0)
            $display("Vector[%d] - [OK]", i);
        else begin
            $display("Vector[%d] - [FAIL]", i);
            $display("inputs    | port_a:%h, port_b: %h, carry_in: %h", inputs.port_a,
                                                                        inputs.port_b, 
                                                                        inputs.carry_in);
            $display("result    | expected: %h, actual: %h", test_vector.result[i],    outputs.result);
            $display("carry_out | expected: %h, actual: %h", test_vector.carry_out[i], outputs.carry_out);
            $finish;
            // $display("overflow  | expected: %b, actual: %b", test_vector[i].overflow,  outputs.overflow);
        end
    end
end
endtask : sw_model_comp_test