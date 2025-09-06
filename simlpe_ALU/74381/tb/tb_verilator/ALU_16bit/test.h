#include <stdlib.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "alu_16_bit/Valu_16_bit.h"

#pragma once

int a_plus_b_test(Valu_16_bit* alu_16_bit, int& num_failed, vluint64_t& vtime, VerilatedVcdC* m_trace, std::ofstream& log_file);
int b_minus_a_test(Valu_16_bit* alu_16_bit, int& num_failed, vluint64_t& vtime, VerilatedVcdC* m_trace, std::ofstream& log_file);
int a_minus_b_test(Valu_16_bit* alu_16_bit, int& num_failed, vluint64_t& vtime, VerilatedVcdC* m_trace, std::ofstream& log_file);
