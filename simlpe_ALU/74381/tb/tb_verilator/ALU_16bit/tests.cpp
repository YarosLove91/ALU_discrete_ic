#include "test.h"
#include <iostream>
#include <fstream>
using std::endl;
using std::cout;
using std::cerr;


int a_plus_b_test(Valu_16_bit* alu_16_bit, 
					int& num_failed, 
					vluint64_t& vtime, 
					VerilatedVcdC* m_trace, 
					std::ofstream& log_file) {
	
	uint32_t expected_sum;    
	uint32_t result;
	bool expected_Cout;
	for (uint16_t a = 0; a < 100; a++) {
		for (uint16_t b = 0; b < 100; b++) {
			for (size_t Cin = 0; Cin < 2; Cin++) {
				
				// Set inputs
				alu_16_bit->A = a;
				alu_16_bit->B = b;
				alu_16_bit->Cn = Cin;
				alu_16_bit->S = 3;

				// Evaluate model
				alu_16_bit->eval();

#if VM_TRACE == 1 
	if( m_trace) m_trace->dump(vtime++);  
#endif
				expected_sum = (a + b + Cin);
				result = (alu_16_bit->Co == 1) ? alu_16_bit->F + (1 << 16) : alu_16_bit->F ;
				expected_Cout = (expected_sum >= 0x10000);

				if (result != expected_sum) {
					cout << "Sum test failed:" 
						<< "A = 0x" << a 
						<< ", B = 0x" << b 
						<< ", Cn = " << Cin 
						<< ", Res = " << result 
						<<  ", Sum = " << expected_sum 
					<< endl;
					log_file << "Sum test failed:" 
						<< " a = 0x" << a 
						<< ", b = 0x" << b 
						<< ", Cin = " << (int)Cin 
						<< ", Res = " << result 
						<<  ", Sum = " << expected_sum  
						<< ", Cout = " << (int)alu_16_bit->Co 
					<< endl;
					num_failed++;
				}
				if (alu_16_bit->Co != expected_Cout) {
					cout << "Cout test failed: a = 0x" << std::hex << a << ", b = 0x" << b << ", Cin = " << Cin << std::endl;
					log_file << "Cout test failed: a = 0x" << std::hex << a << ", b = 0x" << b << ", Cin = " << Cin << std::endl;
					num_failed++;
				}
			}
		}
	}
return 0;
}


int a_minus_b_test(	Valu_16_bit* alu_16_bit, 
					int& num_failed, 
					vluint64_t& vtime, 
					VerilatedVcdC* m_trace, 
					std::ofstream& log_file
					) {
						
	uint16_t expected_diff;    
	uint16_t result;
	bool expected_Cout;
	for (uint16_t a = 0; a < 100; a++) {
		for (uint16_t b = 0; b < 100; b++) {
			for (size_t Cin = 1; Cin < 2; Cin++) {
				
				// Set inputs
				alu_16_bit->A = a;
				alu_16_bit->B = b;
				alu_16_bit->Cn = Cin;
				alu_16_bit->S = 2; // 2 - код операции вычитания


				// Evaluate model
				alu_16_bit->eval();


#if VM_TRACE == 1
	if( m_trace) m_trace->dump(vtime++);
#endif
				expected_diff = a - b;
				result = alu_16_bit->F;

				if (result != expected_diff) {
					cout << "Diff test failed:" 
						<< "A = 0x" << a 
						<< ", B = 0x" << b 
						<< ", Cn = " << Cin 
						<< ", Res = " << result 
						<<  ", Diff = " << expected_diff 
					<< endl;
					log_file << "Diff test failed:" 
						<< " a = 0x" << a 
						<< ", b = 0x" << b 
						<< ", Cin = " << (int)Cin 
						<< ", Res = " << result 
						<<  ", Diff = " << expected_diff  
						<< ", Cout = " << (int)alu_16_bit->Co 
					<< endl;
					num_failed++;
				}
			}
		}
	}
return 0;
}


int b_minus_a_test(Valu_16_bit* alu_16_bit, 
					int& num_failed, 
					vluint64_t& vtime, 
					VerilatedVcdC* m_trace, 
					std::ofstream& log_file) {
	
	uint16_t expected_diff;    
	uint16_t result;
	bool expected_Cout;
	for (uint16_t a = 0; a < 100; a++) {
		for (uint16_t b = 0; b < 100; b++) {
			for (size_t Cin = 1; Cin < 2; Cin++) {
				
				// Set inputs
				alu_16_bit->A = a;
				alu_16_bit->B = b;
				alu_16_bit->Cn = Cin;
				alu_16_bit->S = 1; // 2 - код операции вычитания
				// Evaluate model
				alu_16_bit->eval();


#if VM_TRACE == 1
	if( m_trace) m_trace->dump(vtime++);
#endif
				expected_diff = b - a;
				result = alu_16_bit->F;

				if (result != expected_diff) {
					cout << "Diff test failed:" 
						<< "A = 0x" << a 
						<< ", B = 0x" << b 
						<< ", Cn = " << Cin 
						<< ", Res = " << result 
						<<  ", Diff = " << expected_diff 
					<< endl;
					log_file << "Diff test failed:" 
						<< " a = 0x" << a 
						<< ", b = 0x" << b 
						<< ", Cin = " << (int)Cin 
						<< ", Res = " << result 
						<<  ", Diff = " << expected_diff  
						<< ", Cout = " << (int)alu_16_bit->Co 
					<< endl;
					num_failed++;
				}
			}
		}
	}
return 0;
}