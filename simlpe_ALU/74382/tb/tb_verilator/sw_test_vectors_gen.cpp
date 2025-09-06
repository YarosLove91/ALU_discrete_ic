#include "sw_test_vectors_gen.h"

int main(int argc, char* argv[])
{
    t_test_config test_cfg;

    print_avalaible();
    if (argc == 0)
        test_cfg = get_test();
    else
    {
        test_cfg.test = argv[1];
        std::istringstream ss(argv[2]);
        ss >> test_cfg.vector_size;
    }

    std::cout << ">>>> Chosen test: " << test_cfg.test << std::endl;

    // variables for test vectors generation
    std::vector<bool> carry_in;
    std::vector<bool> carry_out;
    std::vector<uint16_t> u_port_a, u_port_b;
    std::vector<uint32_t> u_result;
    std::vector<int16_t> port_a, port_b;
    std::vector<int32_t> result;

    for (size_t i = 0; i < test_cfg.vector_size; i++)
    {
        
        if(test_cfg.test == "a+b")
        {
            u_port_a.push_back(random(0x0, 0xFFFF));
            u_port_b.push_back(random(0x0, 0xFFFF));
            carry_in.push_back(random(0, 1));
            
            u_result.push_back(u_port_a[i] + u_port_b[i] + (uint16_t)carry_in[i]);
            carry_out.push_back(u_result[i] >> 16);
        }
        else if (test_cfg.test == "a-b")
        {
            port_a.push_back(random(0x0, 0xFFFF));
            port_b.push_back(random(0x0, 0xFFFF));
            carry_in.push_back(1);
            result.push_back(port_a[i] - port_b[i]);
        }
        else if(test_cfg.test == "b-a")
        {
            port_a.push_back(random(0x0, 0xFFFF));
            port_b.push_back(random(0x0, 0xFFFF));
            carry_in.push_back(1);
            result.push_back(port_b[i] - port_a[i]);
        }
        else
        {
            std::cout << "There is no such test!" << std::endl;
            return 1;
        }
    }

    if(test_cfg.test == "a+b")
    {
        write_vector(u_port_a, FILE_PORT_A);
        write_vector(u_port_b, FILE_PORT_B);
        write_vector(u_result, FILE_GOLDEN_RESULT);
    }
    else
    {
        write_vector(port_a, FILE_PORT_A);
        write_vector(port_b, FILE_PORT_B);
        write_vector(result, FILE_GOLDEN_RESULT);
    }
    write_vector(carry_in,  FILE_PORT_CARRY);
    write_vector(carry_out, FILE_GOLDEN_CARRY);
}

template<typename T, typename Allocator>
void write_vector(const std::vector<T, Allocator> &w_vector, std::string filename)
{
    // files writing streams
    std::ofstream out_stream;
    out_stream.open(filename);

    for (int i = 0; i < w_vector.size(); i++)
    {
        out_stream << std::hex << w_vector[i] << std::endl;
    }

    out_stream.close();
}

template<typename T>
T random(T range_from, T range_to)
{
    std::random_device                  rand_dev;
    std::mt19937                        generator(rand_dev());
    std::uniform_int_distribution<T>    distr(range_from, range_to);
    return distr(generator);
}

void print_avalaible()
{
    std::cout << "Avalaible tests:" << std::endl;
    std::cout << "a+b" << std::endl;
    std::cout << "a-b" << std::endl;
    std::cout << "b-a" << std::endl;
}

t_test_config get_test()
{
    t_test_config test_cfg;
    std::cout << "Choose test: ";
    std::cin >> test_cfg.test;
    std::cout << "Choose test vector size: ";
    std::cin >> test_cfg.vector_size;

    return test_cfg;
}