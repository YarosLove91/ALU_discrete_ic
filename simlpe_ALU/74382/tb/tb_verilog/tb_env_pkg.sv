package tb_env_pkg;

`define STRINGIFY(x) `"x`"

//--------------------------tb params-------------------------
localparam SEL_MAX          = 2**(SELECT_W) - 1            ;
localparam INPUTS_NUM       = 3                            ; // port_a, port_b, carry_in
localparam INPUTS_CASES_NUM = 2**INPUTS_NUM                ;

// inputs cases is a 3bit variable in form of {Cn, An, Bn}
// inputs' indexes for inputs cases
localparam PORT_B_IDX = 0;
localparam PORT_A_IDX = 1;
localparam CARRY_IDX  = 2;

// software model comparison test
localparam TB_ALU_CHAIN_W    = alu_74382_pkg::UINT_16_W;
localparam TB_ALU_W          = alu_74382_pkg::ORIG_OPERAND_W;
localparam TB_ALU_QTY        = TB_ALU_CHAIN_W / TB_ALU_W;
localparam TEST_VECTOR_SIZE  = `DEF_TEST_VECTOR_SIZE;

`ifdef SW_MODEL_COMP_TEST
localparam TB_OPERAND_W     = TB_ALU_CHAIN_W;
localparam TB_RESULT_W      = TB_ALU_CHAIN_W;
`else
localparam TB_OPERAND_W     = TB_ALU_W;
localparam TB_RESULT_W      = TB_OPERAND_W;
`endif

`ifdef DEF_SW_TEST_OP
localparam string SW_TEST_OP = `STRINGIFY(`DEF_SW_TEST_OP);
`endif

// convenience constants
localparam ALL_HIGH         = {TB_OPERAND_W{1'b1}};
localparam ALL_LOW          = {TB_OPERAND_W{1'b0}};

localparam FILE_TST_VECTOR    = "tb/tst_vector.txt";
localparam FILE_PORT_A        = "tb/port_a.txt";
localparam FILE_PORT_B        = "tb/port_b.txt";
localparam FILE_PORT_CARRY    = "tb/carry.txt";
localparam FILE_GOLDEN_CARRY  = "tb/carry_golden.txt";
localparam FILE_GOLDEN_RESULT = "tb/result_golden.txt";


//--------------------------typedefs--------------------------
typedef struct packed {
    logic                    carry_in ; // MSB
    logic [TB_OPERAND_W-1:0] port_a   ;
    logic [TB_OPERAND_W-1:0] port_b   ; // LSB
} t_inputs;

typedef struct packed {
    logic [TB_RESULT_W-1:0] result   ; // MSB
    logic                   overflow ;
    logic                   carry_out; // LSB
} t_outputs;

typedef struct {
    logic                       carry_in[TEST_VECTOR_SIZE] ;
    logic [TB_ALU_CHAIN_W-1:0]  port_a[TEST_VECTOR_SIZE]   ;
    logic [TB_ALU_CHAIN_W-1:0]  port_b[TEST_VECTOR_SIZE]   ;
    logic [TB_ALU_CHAIN_W-1:0]  result[TEST_VECTOR_SIZE]   ;
    logic                       overflow[TEST_VECTOR_SIZE] ;
    logic                       carry_out[TEST_VECTOR_SIZE];
} t_tst_vector;

typedef t_outputs t_exp_table[SEL_MAX][INPUTS_CASES_NUM];


//-------------------------functions--------------------------
function logic [TB_OPERAND_W - 1:0] extend_bit (input logic in_bit);
    extend_bit = {TB_OPERAND_W{in_bit}};
endfunction : extend_bit


function t_exp_table exp_table();
    logic [INPUTS_NUM-1:0] in_case_logic;
    for (int sel_case = 0; sel_case < SEL_MAX; sel_case++) begin
        case(sel_case)
            OP_CLEAR:
                begin
                    for (int in_case = 0; in_case < INPUTS_CASES_NUM; in_case++) begin
                        exp_table[sel_case][in_case].result = 'd0;
                        exp_table[sel_case][in_case].overflow = 'd1;
                        exp_table[sel_case][in_case].carry_out = 'd1;
                    end
                end
            OP_B_SUB_A:
                begin
                    //                        F[3:0]    OVR   Cout
                    exp_table[sel_case][0] = {ALL_HIGH, 1'b0, 1'b0};
                    exp_table[sel_case][1] = { 4'b1110, 1'b0, 1'b1};
                    exp_table[sel_case][2] = { ALL_LOW, 1'b0, 1'b0};
                    exp_table[sel_case][3] = {ALL_HIGH, 1'b0, 1'b0};

                    exp_table[sel_case][4] = { ALL_LOW, 1'b0, 1'b1};
                    exp_table[sel_case][5] = {ALL_HIGH, 1'b0, 1'b1};
                    exp_table[sel_case][6] = { 4'b0001, 1'b0, 1'b0};
                    exp_table[sel_case][7] = { ALL_LOW, 1'b0, 1'b1};
                end
            OP_A_SUB_B:
                begin
                    //                        F[3:0]    OVR   Cout
                    exp_table[sel_case][0] = {ALL_HIGH, 1'b0, 1'b0};
                    exp_table[sel_case][1] = { ALL_LOW, 1'b0, 1'b0};
                    exp_table[sel_case][2] = { 4'b1110, 1'b0, 1'b1};
                    exp_table[sel_case][3] = {ALL_HIGH, 1'b0, 1'b0};

                    exp_table[sel_case][4] = { ALL_LOW, 1'b0, 1'b1};
                    exp_table[sel_case][5] = { 4'b0001, 1'b0, 1'b0};
                    exp_table[sel_case][6] = {ALL_HIGH, 1'b0, 1'b1};
                    exp_table[sel_case][7] = { ALL_LOW, 1'b0, 1'b1};
                end
            OP_ADD:
                begin
                    //                        F[3:0]    OVR   Cout
                    exp_table[sel_case][0] = { ALL_LOW, 1'b0, 1'b0};
                    exp_table[sel_case][1] = {ALL_HIGH, 1'b0, 1'b0};
                    exp_table[sel_case][2] = {ALL_HIGH, 1'b0, 1'b0};
                    exp_table[sel_case][3] = { 4'b1110, 1'b0, 1'b1};

                    exp_table[sel_case][4] = { 4'b0001, 1'b0, 1'b0};
                    exp_table[sel_case][5] = { ALL_LOW, 1'b0, 1'b1};
                    exp_table[sel_case][6] = { ALL_LOW, 1'b0, 1'b1};
                    exp_table[sel_case][7] = {ALL_HIGH, 1'b0, 1'b1};
                end
            OP_XOR:
                begin
                    for (int in_case = 0; in_case < INPUTS_CASES_NUM; in_case++) begin
                        in_case_logic = in_case;
                        casez (in_case_logic)
                            //                                       F[3:0]    OVR   Cout
                            3'b?00 : exp_table[sel_case][in_case] = { ALL_LOW, 1'b0, 1'b0};
                            3'b?01 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b010 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b?11 : exp_table[sel_case][in_case] = { ALL_LOW, 1'b1, 1'b1};
                            3'b110 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b1, 1'b1};
                            default: /* default */;
                        endcase
                    end
                end
            OP_OR:
                begin
                    for (int in_case = 0; in_case < INPUTS_CASES_NUM; in_case++) begin
                        in_case_logic = in_case;
                        casez (in_case_logic)
                            //                                       F[3:0]    OVR   Cout
                            3'b?00 : exp_table[sel_case][in_case] = { ALL_LOW, 1'b0, 1'b0};
                            3'b?01 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b?10 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b011 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b111 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b1, 1'b1};
                            default: /* default */;
                        endcase
                    end
                end
            OP_AND:
                begin
                    for (int in_case = 0; in_case < INPUTS_CASES_NUM; in_case++) begin
                        in_case_logic = in_case;
                        casez (in_case_logic)
                            //                                       F[3:0]    OVR   Cout
                            3'b?00 : exp_table[sel_case][in_case] = { ALL_LOW, 1'b1, 1'b1};
                            3'b?01 : exp_table[sel_case][in_case] = { ALL_LOW, 1'b0, 1'b0};
                            3'b?10 : exp_table[sel_case][in_case] = { ALL_LOW, 1'b1, 1'b1};
                            3'b011 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b111 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b1, 1'b1};
                            default: /* default */;
                        endcase
                    end
                end
            OP_PRESET:
                begin
                    for (int in_case = 0; in_case < INPUTS_CASES_NUM; in_case++) begin
                        in_case_logic = in_case;
                        casez (in_case_logic)
                            //                                       F[3:0]    OVR   Cout
                            3'b?00 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b?01 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b?10 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b011 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b0, 1'b0};
                            3'b111 : exp_table[sel_case][in_case] = {ALL_HIGH, 1'b1, 1'b1};
                            default: /* default */;
                        endcase
                    end
                end
            default : /* default */;
        endcase
    end
endfunction : exp_table


function t_tst_vector get_test_vector();
    t_tst_vector res;
    
    logic                       carry_in[TEST_VECTOR_SIZE] ;
    logic [TB_ALU_CHAIN_W-1:0]  port_a[TEST_VECTOR_SIZE]   ;
    logic [TB_ALU_CHAIN_W-1:0]  port_b[TEST_VECTOR_SIZE]   ;
    logic [TB_ALU_CHAIN_W-1:0]  result[TEST_VECTOR_SIZE]   ;
    logic                       carry_out[TEST_VECTOR_SIZE];

    $readmemh(FILE_PORT_A, port_a);
    $readmemh(FILE_PORT_B, port_b);
    $readmemh(FILE_PORT_CARRY, carry_in);
    $readmemh(FILE_GOLDEN_CARRY, carry_out);
    $readmemh(FILE_GOLDEN_RESULT, result);

    // $display("port_a[0] = %d", port_a[0]);

    res.port_a = port_a;
    res.port_b = port_b;
    res.carry_in = carry_in;
    res.carry_out = carry_out;
    res.result = result;

    return res;
endfunction : get_test_vector


//------------------global variables and signals--------------------
logic [SELECT_W-1:0]    sel;
logic [TB_RESULT_W-1:0] result   ;
logic                   overflow ;
logic                   carry_out;

t_inputs  inputs;
t_outputs outputs;

t_outputs exp_out  ;
int       err_cnt  ;

t_exp_table expected_table = exp_table();

string available_tests[] = 
{
"DATASHEET_VECTORS_TEST", 
"DUMMY_OVF_TEST", 
"SW_MODEL_COMP_TEST"
};

endpackage : tb_env_pkg