#include <stdlib.h>
#include <iostream>
#include <fstream>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "adder32_obj/Vadder32.h"

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vadder32* top = new Vadder32;

    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("adder32.vcd");

    std::ofstream logFile("console_log.txt"); // Create a log file

    int num_failed = 0;
    int clk = 0;

    for (uint32_t a = 0; a < 1000; a++) {
        for (uint32_t b = 0; b < 1000; b++) {
            for (int8_t Cin = 0; Cin < 2; Cin++) {
                // Set inputs
                top->a = a;
                top->b = b;
                top->Cin = Cin;

                // Evaluate model
                top->eval(); // <--- Вызов eval() здесь

                uint64_t expected_sum = (a + b + Cin);

                uint64_t result = (top->Cout == 1) ? top->sum + (1 << 32) : top->sum ;

                // uint32_t result = {0};
                // if (top->Cout == 1)
                //     result = top->sum + (1 << 16);
                // else 
                //     result = top->sum;


                bool expected_Cout = (expected_sum >= 0x100000000);
                clk++;
                tfp->dump(clk++); // increment clock
                // Check if the test failed
                if (result != expected_sum) {
                    std::cout << "Sum test failed: a = 0x" << a << ", b = 0x" << b << ", Cin = " << Cin << ", Res = " << result <<  ", Sum = " << expected_sum << std::endl;
                    logFile << "Sum test failed: a = 0x" << a << ", b = 0x" << b << ", Cin = " << (int)Cin << ", Res = " << result <<  ", Sum = " << expected_sum  << ", Cout = " << (int)top->Cout << std::endl;
                    num_failed++;
                }
                if (top->Cout != expected_Cout) {
                    std::cout << "Cout test failed: a = 0x" << std::hex << a << ", b = 0x" << b << ", Cin = " << Cin << std::endl;
                    logFile << "Cout test failed: a = 0x" << std::hex << a << ", b = 0x" << b << ", Cin = " << Cin << std::endl;
                    num_failed++;
                }
            }
        }
    }

    tfp->close();
    delete tfp;
    delete top;

    if (num_failed > 0) {
        std::cout << "Failed " << num_failed << " tests." << std::endl;
        logFile << "Failed " << num_failed << " tests." << std::endl;
    } else {
        std::cout << "All tests passed." << std::endl;
        logFile << "All tests passed." << std::endl;
    }

    logFile.close(); // Close the log file

    return 0;
}
