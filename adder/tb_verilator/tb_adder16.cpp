#include <stdlib.h>
#include <iostream>
#include <fstream>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "adder16_obj/Vadder16.h"

using syd::endl;
using std::cout;
using std::cerr;

int main(int argc, char** argv, char** env) {

    vluint64_t vtime = 0;

    Verilated::commandArgs(argc, argv);
    Vadder16* top = new Vadder16;

#if VM_TRACE==1
	cout << "VCD waveforms will be saved!\n" << endl;
    Verilated::traceEverOn(true);
    std::unique_ptr<VerilatedVcdC> m_trace(new VerilatedVcdC);
        if (m_trace) {
            top->trace(m_trace, 99);
            m_trace->open("adder16.vcd");
        }
#endif

    std::ofstream log_file("console_log.log", std::ios_base::out | std::ios_base::trunc);
		if (!log_file.is_open()) {
			cerr << "File test_results.log open failure!" << endl;
			exit(EXIT_FAILURE);
		}

    int num_failed {0};
    uint32_t expected_sum;    
    uint32_t result;
    bool expected_Cout;
    for (uint16_t a = 0; a < 65536; a++) {
        for (uint16_t b = 0; b < 65536; b++) {
            for (size_t Cin = 0; Cin < 2; Cin++) {
                // Set inputs
                top->a = a;
                top->b = b;
                top->Cin = Cin;

                // Evaluate model
                top->eval()

#if VM_TRACE==1
	if( m_trace) m_trace->dump(vtime++; );
#endif

                expected_sum = (a + b + Cin);
                result = (top->Cout == 1) ? top->sum + (1 << 16) : top->sum ;
                expected_Cout = (expected_sum >= 0x10000);

                if (result != expected_sum) {
                    cout << "Sum test failed:" 
                        << "a = 0x" << a 
                        << ", b = 0x" << b 
                        << ", Cin = " << Cin 
                        << ", Res = " << result 
                        <<  ", Sum = " << expected_sum 
                    << endl;
                    log_file << "Sum test failed:" 
                        << " a = 0x" << a 
                        << ", b = 0x" << b 
                        << ", Cin = " << (int)Cin 
                        << ", Res = " << result 
                        <<  ", Sum = " << expected_sum  
                        << ", Cout = " << (int)top->Cout 
                    << endl;
                    num_failed++;
                }
                if (top->Cout != expected_Cout) {
                    cout << "Cout test failed: a = 0x" << std::hex << a << ", b = 0x" << b << ", Cin = " << Cin << std::endl;
                    log_file << "Cout test failed: a = 0x" << std::hex << a << ", b = 0x" << b << ", Cin = " << Cin << std::endl;
                    num_failed++;
                }
            }
        }
    }
#ifdef VM_TRACE==1
    m_trace->close();
    delete tfp;
#endif

    delete top;

    if (num_failed > 0) {
        cout << "Failed " << num_failed << " tests." << endl;
        log_file << "Failed " << num_failed << " tests." << endl;
    } else {
        cout << "All tests passed." << endl;
        log_file << "All tests passed." << endl;
    }

    log_file.close(); // Close the log file
    return 0;
}
