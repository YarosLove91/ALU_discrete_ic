#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <cstdint>
#include <ctime>
#include <sstream>
// #include <format>
#include <vector>
#include <random>

#define TEST_VECTOR_SIZE (100u)
#define FILE_TST_VECTOR ("tb/tst_vector.txt")
#define FILE_PORT_A ("tb/port_a.txt")
#define FILE_PORT_B ("tb/port_b.txt")
#define FILE_PORT_CARRY ("tb/carry.txt")
#define FILE_GOLDEN_CARRY ("tb/carry_golden.txt")
#define FILE_GOLDEN_RESULT ("tb/result_golden.txt")
#define BITS_15_TO_12_MASK (0xF000)

typedef struct t_test_config
{
    std::string test;
    unsigned int vector_size;
} t_test_config;

template<typename T, typename Allocator>
void write_vector(const std::vector<T, Allocator> &w_vector, std::string filename);

template<typename T>
T random(T range_from, T range_to);

void print_avalaible();


t_test_config get_test();