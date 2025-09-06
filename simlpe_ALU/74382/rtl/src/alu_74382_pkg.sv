package alu_74382_pkg;

//---------------------alu module real params-----------------
localparam SELECT_W = 3;
localparam ORIG_OPERAND_W = 4;
localparam ORIG_RESULT_W  = 4;

//------------------------alu chain params--------------------
localparam UINT_16_W = 16;

//--------------------------typedefs--------------------------
typedef enum logic [SELECT_W - 1:0] {
	OP_CLEAR = 0,
	OP_B_SUB_A,
	OP_A_SUB_B,
	OP_ADD,
	OP_XOR,
	OP_OR,
	OP_AND,
	OP_PRESET
} e_operation;

endpackage : alu_74382_pkg