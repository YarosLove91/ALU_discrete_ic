#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <random> 
#include <vector>
#include <string>

#include "alu16_obj/Valu16.h"

#ifdef VM_TRACE
#include <verilated_vcd_c.h>
#endif

//#define DEBUG_LOG

#define MAX_SIM_TIME 20
#define TEST_ITERATION 10'000'000
#define LOG_TO_FILE

#define ERROR "\033[1;31m"
#define PASS  "\033[1;32m"
#define NORM  "\033[0m"

#define SET_DUT_VALUE(a, b, cin, cmd, mode) \
	do { \
		set_test_design_values(ALU_dut, a, b, cin, cmd, mode); \
	} while(0)\

#define GET_DUT_VALUE() ({ \
	typeof(get_test_design_values(ALU_dut)) _val; \
	do { \
		_val = get_test_design_values(ALU_dut); \
	} while (0); \
	_val; \
})

#define CHECK_DUT_RESULT(expected, cmd, log_file, correct_tests, failed_tests) \
	do { \
		volatile int _result = GET_DUT_VALUE(); \
		check_result(expected, _result, cmd, log_file, correct_tests, failed_tests); \
	} while (0)


#define SET_AND_CHECK_DUT(value, op1, op2, arg1, arg2, expected, cmd, log_file, correct_tests, failed_tests) \
	do { \
		SET_DUT_VALUE(value, op1, op2, arg1, arg2); \
		ALU_dut->eval(); \
		CHECK_DUT_RESULT(expected, cmd, log_file, correct_tests, failed_tests); \
	} while (0)

//#############################################

#define SET_DUT_VALUE_STRUCT(ALU_dut, ALU_arg) \
	do { \
		set_test_design_values_struct(ALU_dut, ALU_arg); \
	} while(0)

#define GET_DUT_VALUE_STRUCT(ALU_dut, ALU_arg) ({ \
	get_test_design_values_struct(ALU_dut, ALU_arg); \
	ALU_arg; \
})

#define CHECK_DUT_RESULT_STRUCT(expected,\
								ALU_dut, ALU_arg, operation,\
								log_file, correct_tests, failed_tests)\
	do { \
		get_test_design_values_struct(ALU_dut, ALU_arg); \
		check_result(expected,\ 
					 ALU_arg.alu_Result,\ 
					 operation,\ 
					 log_file,\
					 correct_tests, failed_tests); \
	} while (0)

#define SET_AND_CHECK_DUT_STRUCT(ALU_dut,ALU_arg,\
								expected,operation,\
								log_file, correct_tests,\
								failed_tests) \
	do { \
		SET_DUT_VALUE_STRUCT(ALU_dut, ALU_arg); \
		ALU_dut->eval(); \
		CHECK_DUT_RESULT_STRUCT(expected,ALU_dut,ALU_arg, operation,log_file,\
								correct_tests,failed_tests); \
	} while (0)

// #define DATA_DUMP(vtime) \
//     do { \
//         if (defined (m_trace) && VM_TRACE==1) { \
//             m_trace->dump(vtime); \
//         } \
//     } while (0)


using ALU_DATA_t = int16_t;

vluint64_t sim_time = 0;

using std::cout;
using std::endl;

template <typename T>
struct alu_var{
	T alu_A;
	T alu_B;
	T alu_Result;
	uint8_t alu_Cin     :1;
	uint8_t alu_Cout    :1;
	uint8_t alu_cmd     :4;
	uint8_t alu_mode    :1;
	enum mode_type {Math=0, Logic=1} mode_type;
	enum carry_state_POS_level {NO_carry=1, EX_carry=0} carry_state;
	//enum carry_state_NEG_level {NO_carry, EX_carry} carry_state;
};

// Массив описаний операций
// M = H | C_in = X
// const char* logic_operation_descriptions[] = {
// 	"~a",		// S3 = L S2 = L S1 = L S0 = L  	№0x00		
// 	"~(a|b)",	// S3 = L S2 = L S1 = L S0 = H  	№0x01
// 	"~ab",		// S3 = L S2 = L S1 = H S0 = L  	№0x02
// 	"logic 0",	// S3 = L S2 = L S1 = H S0 = H  	№0x03
// 	"~(AB)",	// S3 = L S2 = H S1 = L S0 = L  	№0x04
// 	"~B",		// S3 = L S2 = H S1 = L S0 = H  	№0x05
// 	"A^B",		// S3 = L S2 = H S1 = H S0 = 0  	№0x06
// 	"A~B",		// S3 = L S2 = H S1 = H S0 = H  	№0x07
// 	"~A|B",		// S3 = H S2 = L S1 = L S0 = L  	№0x08
// 	"~(A^B)",	// S3 = H S2 = L S1 = L S0 = H  	№0x09
// 	"B",		// S3 = H S2 = L S1 = H S0 = L  	№0x0A
// 	"AB",		// S3 = H S2 = L S1 = H S0 = H  	№0x0B
// 	"LOGIC 1",	// S3 = H S2 = H S1 = L S0 = L  	№0x0C
// 	"A|~B",		// S3 = H S2 = H S1 = L S0 = H  	№0x0D
// 	"A|B",		// S3 = H S2 = H S1 = H S0 = L  	№0x0E
// 	"A"			// S3 = H S2 = H S1 = H S0 = H  	№0x0F
// };

// const char* math_operation_descriptions[] = {
//     "a + carry",			// S3 = L S2 = L S1 = L S0 = L  	№0x00	
//     "(A + B) PLUS CARRY",	// S3 = L S2 = L S1 = L S0 = H  	№0x01
//     "(A + !B) PLUS CARRY",	// S3 = L S2 = L S1 = H S0 = L  	№0x02
//     "MINUS 1 PLUS CARRY",	// S3 = L S2 = L S1 = H S0 = H  	№0x03
//     "A PLUS A!B",			// S3 = L S2 = H S1 = L S0 = L  	№0x04
//     "(A+B) PLUS A!B PLUS 1",	// S3 = L S2 = H S1 = L S0 = H  	№0x05
//     "A MINUS B MINUS CARRY",	// S3 = L S2 = H S1 = H S0 = 0  	№0x06
//     "A~B MINUS CARRY",		// S3 = L S2 = H S1 = H S0 = H  	№0x07
//     "A PLUS AB PLUS CARRY",	// S3 = H S2 = L S1 = L S0 = L  	№0x08
//     "A PLUS B",				// S3 = H S2 = L S1 = L S0 = H  	№0x09
//     "(A+!B) PLUS AB",		// S3 = H S2 = L S1 = H S0 = L  	№0x0A
//     "AB MINUS CARRY",		// S3 = H S2 = L S1 = H S0 = H  	№0x0B
//     "A PLUS A PLUS CARRY",	// S3 = H S2 = H S1 = L S0 = L  	№0x0C
//     "(A+B) PLUS A PLUS 1",	// S3 = H S2 = H S1 = L S0 = H  	№0x0D
//     "(A+!B) PLUS A PLUS 1", // S3 = H S2 = H S1 = H S0 = L  	№0x0E
//     "A MINUS 1"				// S3 = H S2 = H S1 = H S0 = H  	№0x0F
// };

// Массив описания логических операций
// M = H | C_in = X
std::vector<std::string> logic_operation_descriptions = {
    "~a",			// S3 = L S2 = L S1 = L S0 = L  	№0x00		
    "~(a|b)",		// S3 = L S2 = L S1 = L S0 = H  	№0x01
    "~ab",			// S3 = L S2 = L S1 = H S0 = L  	№0x02
    "logic 0",		// S3 = L S2 = L S1 = H S0 = H  	№0x03
    "~(AB)",		// S3 = L S2 = H S1 = L S0 = L  	№0x04
    "~B",			// S3 = L S2 = H S1 = L S0 = H  	№0x05
    "A^B",			// S3 = L S2 = H S1 = H S0 = 0  	№0x06
    "A~B",			// S3 = L S2 = H S1 = H S0 = H  	№0x07
    "~A|B",			// S3 = H S2 = L S1 = L S0 = L  	№0x08
    "~(A^B)",		// S3 = H S2 = L S1 = L S0 = H  	№0x09
    "B",			// S3 = H S2 = L S1 = H S0 = L  	№0x0A
    "AB",			// S3 = H S2 = L S1 = H S0 = H  	№0x0B
    "LOGIC 1",		// S3 = H S2 = H S1 = L S0 = L  	№0x0C
    "A|~B",			// S3 = H S2 = H S1 = L S0 = H  	№0x0D
    "A|B",			// S3 = H S2 = H S1 = H S0 = L  	№0x0E
    "A"				// S3 = H S2 = H S1 = H S0 = H  	№0x0F
};
// Массив описания математических операций для Positive logic
// M = L | C_in = 0 or C_in = 1
std::vector<std::string> math_operation_descriptions = {
    "a + carry",			// S3 = L S2 = L S1 = L S0 = L  	№0x00	
    "(A + B) PLUS CARRY",	// S3 = L S2 = L S1 = L S0 = H  	№0x01
    "(A + !B) PLUS CARRY",	// S3 = L S2 = L S1 = H S0 = L  	№0x02
    "MINUS 1 PLUS CARRY",	// S3 = L S2 = L S1 = H S0 = H  	№0x03
    "A PLUS A!B",			// S3 = L S2 = H S1 = L S0 = L  	№0x04
    "(A+B) PLUS A!B PLUS 1",	// S3 = L S2 = H S1 = L S0 = H  	№0x05
    "A MINUS B MINUS CARRY",	// S3 = L S2 = H S1 = H S0 = 0  	№0x06
    "A~B MINUS CARRY",		// S3 = L S2 = H S1 = H S0 = H  	№0x07
    "A PLUS AB PLUS CARRY",	// S3 = H S2 = L S1 = L S0 = L  	№0x08
    "A PLUS B",				// S3 = H S2 = L S1 = L S0 = H  	№0x09
    "(A+!B) PLUS AB",		// S3 = H S2 = L S1 = H S0 = L  	№0x0A
    "AB MINUS CARRY",		// S3 = H S2 = L S1 = H S0 = H  	№0x0B
    "A PLUS A PLUS CARRY",	// S3 = H S2 = H S1 = L S0 = L  	№0x0C
    "(A+B) PLUS A PLUS 1",	// S3 = H S2 = H S1 = L S0 = H  	№0x0D
    "(A+!B) PLUS A PLUS 1", // S3 = H S2 = H S1 = H S0 = L  	№0x0E
    "A MINUS 1"				// S3 = H S2 = H S1 = H S0 = H  	№0x0F
};

// Тип функции для вычисления результата операции
using LogicOperation = std::function<ALU_DATA_t(ALU_DATA_t, ALU_DATA_t)>;

// Вектор функций для каждой операции ALU
std::vector<LogicOperation> logic_operations = {
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return ~alu_A; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return ~(alu_A | alu_B); 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return (~alu_A) & alu_B; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return 0; 
	}, // logic 0
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return ~(alu_A & alu_B); 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return ~alu_B; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return alu_A ^ alu_B; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return alu_A & (~alu_B); 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return (~alu_A) | alu_B; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return ~(alu_A ^ alu_B); 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return alu_B; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return alu_A & alu_B; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return -1; 
	}, // LOGIC 1
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return alu_A | (~alu_B); 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return alu_A | alu_B; 
	},
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B) { 
		return alu_A; 
	}
};

// Тип функции для вычисления результата операции
using MathOperation = std::function<ALU_DATA_t(ALU_DATA_t, ALU_DATA_t, ALU_DATA_t)>;

inline ALU_DATA_t carry_correction_p (ALU_DATA_t carry_in){
    return carry_in == 1 ? 0 : 1;
}
using MathOperationStruct = std::function<ALU_DATA_t(alu_var<ALU_DATA_t>)>;

// // Вектор функций для каждой операции ALU
std::vector<MathOperationStruct> math_operations_STRUCT = {
	// S3 = L S2 = L S1 = L S0 = L  		0x00
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return ALU_arg.alu_A + carry_correction_p(ALU_arg.alu_Cin) ;         
	},
	// S3 = L S2 = L S1 = L S0 = H  		0x01
	[](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A | ALU_arg.alu_B) + carry_correction_p(ALU_arg.alu_Cin);
	},
	// S3 = L S2 = L S1 = H S0 = L  		0x02
	[](alu_var<ALU_DATA_t> ALU_arg) { 
            return ((ALU_arg.alu_A) | (~ALU_arg.alu_B)) + carry_correction_p(ALU_arg.alu_Cin); 
	},
	// S3 = L S2 = L S1 = H S0 = H  		0x03
	[](alu_var<ALU_DATA_t> ALU_arg) { 
            return ALU_arg.alu_Cin ? -1 : 0;
	},
	// S3 = L S2 = H S1 = L S0 = L  		0x04
	[](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A + (ALU_arg.alu_A & (~ALU_arg.alu_B))) + carry_correction_p(ALU_arg.alu_Cin);
	},
	// S3 = L S2 = H S1 = L S0 = H  		0x05
	[](alu_var<ALU_DATA_t> ALU_arg) {
            return (ALU_arg.alu_A | ALU_arg.alu_B) + (ALU_arg.alu_A & (~ALU_arg.alu_B)) + carry_correction_p(ALU_arg.alu_Cin);
	},
	// S3 = L S2 = H S1 = H S0 = 0  		0x06
	[](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A - ALU_arg.alu_B) - ALU_arg.alu_Cin;
	},
	// S3 = L S2 = H S1 = H S0 = H  		0x07
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A & (~ALU_arg.alu_B)) - ALU_arg.alu_Cin;
	},
	// S3 = H S2 = L S1 = L S0 = L  		0x08
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A + (ALU_arg.alu_A & ALU_arg.alu_B) + carry_correction_p(ALU_arg.alu_Cin));
	},
	// S3 = H S2 = L S1 = L S0 = H  		0x09
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A + ALU_arg.alu_B) + carry_correction_p(ALU_arg.alu_Cin); 
	},
	// S3 = H S2 = L S1 = H S0 = L  		0x0A
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A | (~ALU_arg.alu_B)) + (ALU_arg.alu_A & ALU_arg.alu_B) + carry_correction_p(ALU_arg.alu_Cin); 
	},
	// S3 = H S2 = L S1 = H S0 = H  		0x0B
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A & ALU_arg.alu_B) - ALU_arg.alu_Cin;
	},
	// S3 = H S2 = H S1 = L S0 = L  		0x0C
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A + ALU_arg.alu_A + carry_correction_p(ALU_arg.alu_Cin));
	},
	// S3 = H S2 = H S1 = L S0 = H  		0x0D
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A | ALU_arg.alu_B) + ALU_arg.alu_A + carry_correction_p(ALU_arg.alu_Cin); 
        },
	// S3 = H S2 = H S1 = H S0 = L  		0x0E
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A | (~ALU_arg.alu_B)) + ALU_arg.alu_A + carry_correction_p(ALU_arg.alu_Cin) ;
	},
	// S3 = H S2 = H S1 = H S0 = H  		0x0F
    [](alu_var<ALU_DATA_t> ALU_arg) { 
            return (ALU_arg.alu_A - ALU_arg.alu_Cin); 
	}
};

// Вектор функций для каждой операции ALU
std::vector<MathOperation> math_operations = {
	// S3 = L S2 = L S1 = L S0 = L  		0x00
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return alu_A + carry_correction_p(carry_in) ;         
        },
	// S3 = L S2 = L S1 = L S0 = H  		0x01
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A | alu_B) + carry_correction_p(carry_in);
        },
	// S3 = L S2 = L S1 = H S0 = L  		0x02
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return ((alu_A) | (~alu_B)) + carry_correction_p(carry_in); 
        },
	// S3 = L S2 = L S1 = H S0 = H  		0x03
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return carry_in ? -1 : 0;
        },
	// S3 = L S2 = H S1 = L S0 = L  		0x04
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A + (alu_A & (~alu_B))) + carry_correction_p(carry_in);
        },
	// S3 = L S2 = H S1 = L S0 = H  		0x05
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) {
            return (alu_A | alu_B) + (alu_A & (~alu_B)) + carry_correction_p(carry_in);
        },
	// S3 = L S2 = H S1 = H S0 = 0  		0x06
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A - alu_B) - carry_in;
        },
	// S3 = L S2 = H S1 = H S0 = H  		0x07
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A & (~alu_B)) - carry_in;
        },
	// S3 = H S2 = L S1 = L S0 = L  		0x08
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A + (alu_A & alu_B) + carry_correction_p(carry_in));
        },
	// S3 = H S2 = L S1 = L S0 = H  		0x09
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A + alu_B) + carry_correction_p(carry_in); 
        },
	// S3 = H S2 = L S1 = H S0 = L  		0x0A
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A | (~alu_B)) + (alu_A & alu_B) + carry_correction_p(carry_in); 
        },
	// S3 = H S2 = L S1 = H S0 = H  		0x0B
	[](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A & alu_B) - carry_in;
        },
	// S3 = H S2 = H S1 = L S0 = L  		0x0C
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B,  ALU_DATA_t carry_in) { 
            return (alu_A + alu_A + carry_correction_p(carry_in));
        },
	// S3 = H S2 = H S1 = L S0 = H  		0x0D
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A | alu_B) + alu_A + carry_correction_p(carry_in); 
        },
	// S3 = H S2 = H S1 = H S0 = L  		0x0E
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A | (~alu_B)) + alu_A + carry_correction_p(carry_in);
        },
	// S3 = H S2 = H S1 = H S0 = H  		0x0F
    [](ALU_DATA_t alu_A, ALU_DATA_t alu_B, ALU_DATA_t carry_in) { 
            return (alu_A - carry_in); 
        }
};

template <typename T>
T getExpectedLogicResult(uint8_t alu_cmd, T alu_A, T alu_B) {
	switch (alu_cmd) {
		case 0b0000: return ~alu_A;
		case 0b0001: return ~(alu_A | alu_B);
		case 0b0010: return (~alu_A) & alu_B;
		case 0b0011: return 0; // logic 0
		case 0b0100: return ~(alu_A & alu_B);
		case 0b0101: return ~alu_B;
		case 0b0110: return alu_A ^ alu_B;
		case 0b0111: return alu_A & (~alu_B);
		case 0b1000: return (~alu_A) | alu_B;
		case 0b1001: return ~(alu_A ^ alu_B);
		case 0b1010: return alu_B;
		case 0b1011: return alu_A & alu_B;
		case 0b1100: return -1; // LOGIC 1
		case 0b1101: return alu_A | (~alu_B);
		case 0b1110: return alu_A | alu_B;
		case 0b1111: return alu_A;
		default: return 0; // Неопределенная операция
	}
}

// void check_result(int16_t expected, int16_t actual, std::string operation, std::ofstream& log_file) {
//     if (expected != actual) {
//     std::cout << "\033[1;31mError: Expected result " << expected 
// 			<< " but got " << actual << " for operation " << operation << std::endl;
//         log_file << "Error: Expected result " << expected << " but got " 
// 		<< actual << " for operation " << operation << std::endl;
//     } else {
//         std::cout << "\033[1;32mResult matches ! Expected value for operation " << operation << std::endl;
//         log_file << "Result matches expected value for operation " << operation << ": expected " << expected 
// 		<< ", actual " << actual << std::endl;
//     }
// }

	void check_result(ALU_DATA_t expected, 
					ALU_DATA_t actual, 
					std::string operation, 
					std::ofstream& log_file, 
					size_t & correct_tests, 
					size_t & failed_tests) {
		if (expected != actual) {
			std::cout 
				<< ERROR << "Error: Expected result " << expected 
				<< " but got " << actual 
				<< " for operation " << operation 
				<< NORM
			<< std::endl;
			
			log_file << "Error: Expected result " << expected 
                <<	" but got " << actual 
				<< " for operation " << operation 
			<< std::endl;
			
			failed_tests++; // Увеличиваем счетчик неудачных тестов
		} else {
#ifdef DEBUG_LOG
		std::cout 
			<< PASS << "Result matches expected value for operation " << operation 
			<< ": expected " << expected 
			<< ", actual " << actual 
			<< NORM
		<< std::endl;
		
		log_file << "Result matches expected value for operation " << operation 
			<< ": expected " << expected 
			<< ", actual " << actual 
		<< std::endl;
#endif
		correct_tests++; // Увеличиваем счетчик правильно выполненных тестов
		}
	}

	void set_test_design_values(Valu16* ALU_dut, 
								int16_t A, 
								int16_t B, 
								uint8_t Cin, 
								uint8_t mode, 
								uint8_t sel) {
		ALU_dut->a      = A;
		ALU_dut->b      = B;
		ALU_dut->Cin    = Cin;
		ALU_dut->mode   = mode;
		ALU_dut->sel    = sel;
	}

	void set_test_design_values_struct(Valu16* ALU_dut,
									alu_var<ALU_DATA_t>& ALU_arg
									){
		ALU_dut->a      = ALU_arg.alu_A;
		ALU_dut->b      = ALU_arg.alu_B;
		ALU_dut->Cin    = ALU_arg.alu_Cin;
		ALU_dut->sel    = ALU_arg.alu_cmd;
		ALU_dut->mode   = ALU_arg.alu_mode;
	}

	ALU_DATA_t get_test_design_values_struct(Valu16* ALU_dut,
											alu_var<ALU_DATA_t>& ALU_arg) {
		ALU_arg.alu_Result = ALU_dut->result;
		return ALU_arg.alu_Result;
	}

	ALU_DATA_t get_test_design_values(Valu16* ALU_dut){
		return ALU_dut->result;
	}

	template <typename T>
	class RND_gen {
		public:
			RND_gen() {
				std::random_device device;
				twister.seed(device());
			}
			T getRandom(T min_val, T max_val) {
				std::uniform_int_distribution<T> range(min_val, max_val);
				return range(twister);
			}
			T getRandomMinMax (){
				std::uniform_int_distribution<T> range(std::numeric_limits<T>::min(), 
													   std::numeric_limits<T>::max());
				return range(twister);
			}

			T getRandomBit (){ // New function to generate random 0 or 1
                std::uniform_int_distribution<T> range(0, 1);
            return range(twister);
			}
		private:
			std::mt19937 twister;
	};


	int main(int argc, char** argv, char** env) {
		cout << "Launch test! " << endl;
		Verilated::commandArgs(argc, argv);

		std::ofstream log_file("test_results.log", std::ios_base::out | std::ios_base::trunc);
		if (!log_file.is_open()) {
			std::cerr << "File test_results.log open failure!" << std::endl;
			exit(EXIT_FAILURE);
		}

		Valu16 *ALU_dut = new Valu16;

#if VM_TRACE==1
	cout << "VCD waveforms will be saved!\n" << endl;
	Verilated::traceEverOn(true);		
	std::unique_ptr<VerilatedVcdC> m_trace(new VerilatedVcdC);
        if (m_trace) {
            ALU_dut->trace(m_trace.get(), 10);
            m_trace->open("alu16_waveform.vcd");
        }
#endif

	vluint64_t vtime = 0;
	int clock {};
	size_t correct_tests {};
	size_t failed_tests {};

	RND_gen <ALU_DATA_t>RND;
	alu_var<ALU_DATA_t> ALU_arg;
	
	// Тест логических функции.
	// Активный уровень - ВЫСОКИЙ
	// Test 1
	//cout << "\nGroup test #1. Logic mode" << endl;


	for (size_t i = 0; i < TEST_ITERATION; i++){

		ALU_arg.alu_A = RND.getRandomMinMax();
		ALU_arg.alu_B = RND.getRandomMinMax();   

		ALU_arg.alu_mode = ALU_arg.mode_type::Logic;
		for (size_t op = 0; op < logic_operations.size(); ++op) {
			ALU_arg.alu_cmd = op;
			ALU_arg.alu_Cin = RND.getRandomBit() ;
			SET_AND_CHECK_DUT_STRUCT(ALU_dut,
									ALU_arg,
									logic_operations[op](ALU_arg.alu_A, 
														ALU_arg.alu_B),
									logic_operation_descriptions[op], 
									log_file,
									correct_tests,
									failed_tests);

#if VM_TRACE==1
	if( m_trace) m_trace->dump( vtime );
#endif
			//DATA_DUMP(vtime);
			vtime++;
		}
	
	//cout << "\nGroup test #2.1 Math mode POSITIVE logic level without Carry_in" << endl;

        //ALU_arg.alu_A = RND.getRandom(INT16_MIN, INT16_MAX);
        //ALU_arg.alu_B = RND.getRandom(INT16_MIN, INT16_MAX);  

        ALU_arg.alu_Cin = ALU_arg.carry_state_POS_level::NO_carry ;
        ALU_arg.alu_mode = ALU_arg.mode_type::Math;
        
        for (size_t op = 0; op < math_operations_STRUCT.size(); ++op) {
            ALU_arg.alu_cmd = op;
			SET_AND_CHECK_DUT_STRUCT(ALU_dut,
									ALU_arg,
									math_operations_STRUCT[op](ALU_arg),
									math_operation_descriptions[op], 
									log_file,
									correct_tests,
									failed_tests);

#if VM_TRACE==1
	if( m_trace )
		m_trace->dump( vtime );
#endif
		
		//DATA_DUMP(vtime);
			vtime++;
        }
	//cout << "\nGroup test #2.2 Math mode POSITIVE logic level with Carry_in" << endl;

		ALU_arg.alu_Cin = ALU_arg.carry_state_POS_level::EX_carry ;
        for (size_t op = 0; op < logic_operations.size(); ++op) {
            ALU_arg.alu_cmd = op;
			SET_AND_CHECK_DUT_STRUCT(ALU_dut,
									ALU_arg,
									math_operations_STRUCT[op](ALU_arg),
									math_operation_descriptions[op], 
									log_file,
									correct_tests,
									failed_tests);
#if VM_TRACE==1
	if( m_trace )
		m_trace->dump( vtime );
#endif
			//DATA_DUMP(vtime);
            vtime++;
        }

	//cout << "\nGroup test #3.1 Math mode NEGATIVE logic level without Carry_in" << endl;

        //ALU_arg.alu_A = RND.getRandom(INT16_MIN, INT16_MAX) * -1;
        //ALU_arg.alu_B = RND.getRandom(INT16_MIN, INT16_MAX) * -1;  

		ALU_arg.alu_A = ~ALU_arg.alu_A ;
		ALU_arg.alu_B = ~ALU_arg.alu_B ;

        ALU_arg.alu_Cin = ~ALU_arg.carry_state_POS_level::NO_carry ;
        ALU_arg.alu_mode = ALU_arg.mode_type::Math;
        
        for (size_t op = 0; op < logic_operations.size(); ++op) {
            ALU_arg.alu_cmd = op;
			SET_AND_CHECK_DUT_STRUCT(ALU_dut,
									ALU_arg,
									math_operations_STRUCT[op](ALU_arg),
									math_operation_descriptions[op], 
									log_file,
									correct_tests,
									failed_tests);
#if VM_TRACE==1
	if( m_trace )
		m_trace->dump( vtime );
#endif
			//DATA_DUMP(vtime);
            vtime++;
        }
		//cout << "\nGroup test #3.2 Math mode NEGATIVE logic level with Carry_in" << endl;
		ALU_arg.alu_Cin = !(ALU_arg.carry_state_POS_level::EX_carry) ;

        for (size_t op = 0; op < logic_operations.size(); ++op) {
            ALU_arg.alu_cmd = op;
			SET_AND_CHECK_DUT_STRUCT(ALU_dut,
									ALU_arg,
									math_operations[op](ALU_arg.alu_A, ALU_arg.alu_B, ALU_arg.alu_Cin),
									math_operation_descriptions[op], 
									log_file,
									correct_tests,
									failed_tests);
#if VM_TRACE==1
	if( m_trace )
		m_trace->dump( vtime );
#endif
		//DATA_DUMP(vtime);
            vtime++;
        }
	}

	ALU_dut->final();
	log_file.close();

	std::cout << "\nTest summary:\n"
		<< PASS << "Correct tests: \t" << correct_tests
		<< ERROR << "\nFailed tests: \t" << failed_tests << std::endl;

#if VM_TRACE==1
	if( m_trace )
		m_trace->close();
#endif
	delete ALU_dut;
	exit(EXIT_SUCCESS);
}