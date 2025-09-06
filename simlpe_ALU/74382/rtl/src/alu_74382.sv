import alu_74382_pkg::*;

module alu_74382 #(parameter
    OPERAND_W = ORIG_OPERAND_W,
    RESULT_W  = ORIG_RESULT_W
) (
    input  logic [ SELECT_W-1:0] sel      ,
    input  logic                 carry_in ,
    input  logic [OPERAND_W-1:0] port_a   ,
    input  logic [OPERAND_W-1:0] port_b   ,
    output logic [ RESULT_W-1:0] result   ,
    output logic                 overflow ,
    output logic                 carry_out
);

localparam RESULT_EXT_W = RESULT_W + 1;
localparam ALL_HIGH = {OPERAND_W{1'b1}};
localparam ALL_LOW = {OPERAND_W{1'b0}};

logic [OPERAND_W    - 1:0] gen_carry;
logic [OPERAND_W    - 1:0] prop_carry;
logic [OPERAND_W    - 1:0] gen_carry_sum;
logic [OPERAND_W    - 1:0] port_a_act_high, port_b_act_high;
logic [OPERAND_W    - 1:0] port_a_sub, port_b_sub;
logic [OPERAND_W    - 1:0] all_carrys;
logic [RESULT_EXT_W - 1:0] result_ext;

always_comb begin : ports_for_overflow
    port_a_act_high = carry_in ? port_a : ~port_a;
    port_b_act_high = carry_in ? port_b : ~port_b;
end

always_comb begin : inv_ports_for_sub
    port_a_sub = (sel == OP_A_SUB_B) ?  port_a : ~port_a;
    port_b_sub = (sel == OP_A_SUB_B) ? ~port_b :  port_b;
end

always_comb begin : result_calc
    result_ext = 0;
    case(sel)
        OP_CLEAR:
            result_ext = 'd0;

        OP_B_SUB_A:
            result_ext = port_b_sub + port_a_sub + carry_in;
            
        OP_A_SUB_B:
            result_ext = port_a_sub + port_b_sub + carry_in;

        OP_ADD:
            result_ext = port_a + port_b + carry_in;

        OP_XOR:
            result_ext = port_a ^ port_b;

        OP_OR:
            result_ext = port_a | port_b;

        OP_AND:
            result_ext = port_a & port_b;

        OP_PRESET:
            result_ext = {RESULT_EXT_W{1'b1}};

        default:
            result_ext = 'd0;
    endcase // sel
end

always_comb result = result_ext[RESULT_W - 1:0];

always_comb begin : overflow_calc
    case(sel)
        OP_B_SUB_A:
            begin
                if ( (-$signed(port_a_act_high)) > 0 && $signed(port_b_act_high) > 0 )
                    overflow = ($signed(result) < 0) ? 'd1 : 'd0;

                else if ( (-$signed(port_a_act_high)) < 0 && $signed(port_b_act_high) < 0 )
                    overflow = ($signed(result) > 0) ? 'd1 : 'd0;  

                else
                    overflow = 'd0;
            end
        OP_A_SUB_B:
            begin
                if ( $signed(port_a_act_high) > 0 && (-$signed(port_b_act_high)) > 0 )
                    overflow = ($signed(result) < 0) ? 'd1 : 'd0;
                
                else if ( $signed(port_a_act_high) < 0 && (-$signed(port_b_act_high)) < 0 )
                    overflow = ($signed(result) > 0) ? 'd1 : 'd0;                    
                
                else
                    overflow = 'd0;
            end
        OP_ADD:
            begin
                if ( ($signed(port_a) > 0) && ($signed(port_b) > 0) )
                    overflow = ($signed(result) < 0) ? 'd1 : 'd0;
                
                else if ( $signed(port_a) < 0 && $signed(port_b) < 0 )
                    overflow = ($signed(result) > 0) ? 'd1 : 'd0;                    
                
                else
                    overflow = 'd0;
            end
        default:
            overflow = carry_out;
    endcase // sel
end

always_comb begin : gen_prop_carry
    for (int i = 0; i < OPERAND_W; i++) begin
        gen_carry[i] = port_a[i] & port_b[i];
        prop_carry[i] = port_a[i] | port_b[i];
    end

    gen_carry_sum[0] = gen_carry[0];

    for (int i = 1; i < OPERAND_W; i++) begin
        gen_carry_sum[i] = gen_carry[i] | (prop_carry[i] & gen_carry_sum[i-1]);
    end 
end

always_comb begin : carry_out_calc
    case(sel)
        OP_CLEAR:
            carry_out = 'd1;

        OP_B_SUB_A:
            carry_out = result_ext[RESULT_EXT_W - 1];
        
        OP_A_SUB_B:
            carry_out = result_ext[RESULT_EXT_W - 1];
        
        OP_ADD:
            carry_out = gen_carry_sum[OPERAND_W - 1] | ((&prop_carry) & carry_in);

        OP_XOR:
            begin
                if (port_a == ALL_HIGH && port_b == ALL_LOW)
                    carry_out = carry_in;
                else if (port_a == ALL_HIGH && port_b == ALL_HIGH)
                    carry_out = 'd1;
                else
                    carry_out = 'd0;
            end

        OP_OR:
            begin
                if (port_a == ALL_HIGH && port_b == ALL_HIGH)
                    carry_out = carry_in;
                else
                    carry_out = 'd0;
            end

        OP_AND:
            begin
                if (port_a == ALL_HIGH && port_b == ALL_HIGH)
                    carry_out = carry_in;
                else
                    carry_out = (port_b == ALL_LOW) ? 'd1 : 'd0;
            end

        OP_PRESET:
            begin
                if (port_a == ALL_HIGH && port_b == ALL_HIGH)
                    carry_out = carry_in;
                else
                    carry_out = 'd0;
            end

        default:
            carry_out = 'd0;
    endcase
end

endmodule : alu_74382