`include "params.vh"  // Правильный относительный путь

module test_cpu_top;

    // Параметры
    localparam DATA_WIDTH = 16;
    localparam NUM_REGS = 8;
    localparam ADDR_WIDTH = $clog2(NUM_REGS);
    
    // Тактовый сигнал
    reg clk;
    always #5 clk = ~clk;
    
    // Сигналы управления
    reg reset;
    reg reg_write_enable;
    reg [ADDR_WIDTH-1:0] reg_read_addr1;
    reg [ADDR_WIDTH-1:0] reg_read_addr2;
    reg [ADDR_WIDTH-1:0] reg_write_addr;
    reg [DATA_WIDTH-1:0] reg_write_data;
    reg alu_cin;
    reg alu_mode;
    reg b_source_sel;
    reg [3:0] alu_comm;
    reg [DATA_WIDTH-1:0] alu_b_imm;
    
    // Выходные сигналы
    wire [DATA_WIDTH-1:0] reg_read_data1;
    wire [DATA_WIDTH-1:0] reg_read_data2;
    wire [DATA_WIDTH-1:0] alu_result;
    wire alu_cout;
    wire alu_nbo;
    wire alu_ngo;
    
    // DUT
    cpu_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .reg_write_enable(reg_write_enable),
        .reg_read_addr1(reg_read_addr1),
        .reg_read_addr2(reg_read_addr2),

        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data),
        
        .alu_cin(alu_cin),
        .alu_mode(alu_mode),
        .b_source_sel(b_source_sel),
        .alu_comm(alu_comm),
        .alu_b_imm(alu_b_imm),
        
        .reg_read_data1(reg_read_data1),
        .reg_read_data2(reg_read_data2),

        .alu_result(alu_result),
        .alu_cout(alu_cout),
        .alu_nbo(alu_nbo),
        .alu_ngo(alu_ngo)
    );
    
    // ==================== COVERAGE TRACKING ====================
    // Coverage structures
    typedef struct {
        bit [3:0] alu_op_covered;
        bit mode_covered [0:1];
        bit b_source_covered [0:1];
        bit carry_in_covered [0:1];
        bit register_accessed [0:NUM_REGS-1];
        bit test_scenario_covered [1:12];
    } coverage_t;
    
    coverage_t coverage;
    
    // Coverage collection tasks
    task track_alu_operation;
        input [3:0] opcode;
        input mode;
        input b_source;
        input carry_in;
        input [ADDR_WIDTH-1:0] reg_addr;
        begin
            // Track ALU operations
            coverage.alu_op_covered[opcode] = 1;
            coverage.mode_covered[mode] = 1;
            coverage.b_source_covered[b_source] = 1;
            coverage.carry_in_covered[carry_in] = 1;
            
            // Track register access
            if (reg_addr < NUM_REGS) begin
                coverage.register_accessed[reg_addr] = 1;
            end
        end
    endtask
    
    task track_test_scenario;
        input integer test_num;
        begin
            if (test_num >= 1 && test_num <= 12) begin
                coverage.test_scenario_covered[test_num] = 1;
            end
        end
    endtask
    
    function void print_coverage_report;
        integer total_alu_ops, covered_alu_ops;
        integer total_modes, covered_modes;
        integer total_b_sources, covered_b_sources;
        integer total_carry_ins, covered_carry_ins;
        integer total_registers, covered_registers;
        integer total_tests, covered_tests;
        real alu_coverage, mode_coverage, b_source_coverage;
        real carry_coverage, reg_coverage, test_coverage;
        begin
            $display("\n=== COVERAGE REPORT ===");
            
            // ALU operations coverage
            total_alu_ops = 16;
            covered_alu_ops = $countones(coverage.alu_op_covered);
            alu_coverage = (real'(covered_alu_ops) / real'(total_alu_ops)) * 100;
            $display("ALU Operations: %0d/%0d (%0.1f%%)", covered_alu_ops, total_alu_ops, alu_coverage);
            $display("  Covered ops: %b", coverage.alu_op_covered);
            
            // Mode coverage
            total_modes = 2;
            covered_modes = coverage.mode_covered[0] + coverage.mode_covered[1];
            mode_coverage = (real'(covered_modes) / real'(total_modes)) * 100;
            $display("Modes: %0d/%0d (%0.1f%%)", covered_modes, total_modes, mode_coverage);
            
            // B source coverage
            total_b_sources = 2;
            covered_b_sources = coverage.b_source_covered[0] + coverage.b_source_covered[1];
            b_source_coverage = (real'(covered_b_sources) / real'(total_b_sources)) * 100;
            $display("B Sources: %0d/%0d (%0.1f%%)", covered_b_sources, total_b_sources, b_source_coverage);
            
            // Carry in coverage
            total_carry_ins = 2;
            covered_carry_ins = coverage.carry_in_covered[0] + coverage.carry_in_covered[1];
            carry_coverage = (real'(covered_carry_ins) / real'(total_carry_ins)) * 100;
            $display("Carry Inputs: %0d/%0d (%0.1f%%)", covered_carry_ins, total_carry_ins, carry_coverage);
            
            // Register coverage
            total_registers = NUM_REGS;
            covered_registers = $countones(coverage.register_accessed);
            reg_coverage = (real'(covered_registers) / real'(total_registers)) * 100;
            $display("Registers: %0d/%0d (%0.1f%%)", covered_registers, total_registers, reg_coverage);
            $display("  Accessed: %b", coverage.register_accessed);
            
            // Test scenario coverage
            total_tests = 12;
            covered_tests = $countones(coverage.test_scenario_covered);
            test_coverage = (real'(covered_tests) / real'(total_tests)) * 100;
            $display("Test Scenarios: %0d/%0d (%0.1f%%)", covered_tests, total_tests, test_coverage);
            $display("  Completed: %b", coverage.test_scenario_covered);
            
            // Overall coverage
            $display("=== OVERALL COVERAGE SUMMARY ===");
            $display("Functional Coverage: %0.1f%%", 
                    (alu_coverage + mode_coverage + b_source_coverage + 
                     carry_coverage + reg_coverage + test_coverage) / 6.0);
        end
    endfunction
    
    // Initialize coverage
    task initialize_coverage;
        begin
            coverage.alu_op_covered = 0;
            coverage.mode_covered[0] = 0;
            coverage.mode_covered[1] = 0;
            coverage.b_source_covered[0] = 0;
            coverage.b_source_covered[1] = 0;
            coverage.carry_in_covered[0] = 0;
            coverage.carry_in_covered[1] = 0;
            coverage.register_accessed = 0;
            coverage.test_scenario_covered = 0;
        end
    endtask
    // ==================== END COVERAGE TRACKING ====================
    
    // Waveform dump
    initial begin
        $dumpfile("cpu_test.vcd");
        $dumpvars(0, test_cpu_top);
        $dumpvars(1, dut);
    end
    
    // Events для синхронизации тестов
    event test_start, test_complete;
    event test1_done, test2_done, test3_done, test4_done, test5_done;
    event test6_done, test7_done, test8_done, test9_done, test10_done;
    event test11_done, test12_done;

    task read_register_s;
        input [ADDR_WIDTH-1:0] reg_addr;
        output [DATA_WIDTH-1:0] reg_value;
        begin
            // Устанавливаем адрес для чтения
            reg_read_addr1 = reg_addr;
            // Ждем такт для обновления выходов регистрового файла
            @(posedge clk);
            #1;
            // Получаем значение
            reg_value = reg_read_data1;
            $display("Time %t: READ REG %s = %h", $time, get_reg_name(reg_addr), reg_value);
            
            // Track register access
            if (reg_addr < NUM_REGS) begin
                coverage.register_accessed[reg_addr] = 1;
            end
        end
    endtask

    task read_register;
        input [ADDR_WIDTH-1:0] reg_addr;
        output [DATA_WIDTH-1:0] reg_value;
        begin
            // Устанавливаем адрес для чтения
            reg_read_addr1 = reg_addr;
            // Ждем такт для обновления выходов регистрового файла
            @(posedge clk);
            #1;
            reg_value = reg_read_data1;
            
            // Track register access
            if (reg_addr < NUM_REGS) begin
                coverage.register_accessed[reg_addr] = 1;
            end
        end
    endtask

    task write_register;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        begin
            reg_write_addr = addr;
            reg_write_data = data;
            reg_write_enable = 1;
            @(posedge clk);
            #1;
            reg_write_enable = 0;
            $display("Time %t: Write %h to %s", $time, data, get_reg_name(addr));
            
            // Track register access
            if (addr < NUM_REGS) begin
                coverage.register_accessed[addr] = 1;
            end
        end
    endtask

    // Новая версия execute_alu_operation, совместимая с макросами из params.vh
    task execute_alu_operation;
        input [ADDR_WIDTH-1:0] src_reg1;    // Операнд A (всегда из регистра)
        input [ADDR_WIDTH-1:0] src_reg2;    // Операнд B (если выбран регистр)
        input [ADDR_WIDTH-1:0] dst_reg;     // Регистр для результата
        input [4:0] operation;              // Комбинированная операция АЛУ {mode, op}
        input carry_in;                     // Входной перенос
        input b_sel;                        // 0-B из регистра, 1-B из immediate
        input [DATA_WIDTH-1:0] b_value;     // Immediate значение для B
        input string op_name;               // Имя операции для отладки
        
        begin
            // Устанавливаем адреса регистров
            reg_read_addr1 = src_reg1;
            reg_read_addr2 = src_reg2;

            // Декодируем комбинированную команду
            alu_mode = `GET_ALU_MODE(operation);  // mode из бита [4]
            alu_comm = `GET_ALU_OP(operation);    // operation из битов [3:0]
            
            // Устанавливаем управляющие сигналы АЛУ
            alu_cin = carry_in;
            b_source_sel = b_sel;
            alu_b_imm = b_value;
            
            // Track coverage
            track_alu_operation(`GET_ALU_OP(operation), `GET_ALU_MODE(operation), 
                               b_sel, carry_in, dst_reg);
            
            // Ждем такт для стабилизации сигналов
            @(posedge clk);
            #1;
        
            // Сохраняем результат в регистр-приемник
            write_register(dst_reg, alu_result);
            
            // Вывод результатов
            string b_source_info = b_sel ? 
                $sformatf("IMM=%h", b_value) : 
                $sformatf("%s=%h", get_reg_name(src_reg2), reg_read_data2);
            
            $display("Time %t: %s: %s=%h, %s, Mode=%s, Cin=%s, Result=%h, Cout=%s → %s", 
                    $time, op_name,
                    get_reg_name(src_reg1), reg_read_data1,
                    b_source_info,
                    (alu_mode ? "Logic" : "Math"),
                    (carry_in ? "YES" : "NO"),
                    alu_result,
                    (alu_cout ? "YES" : "NO"),
                    get_reg_name(dst_reg));
        end
    endtask
    
    task check_result;
        input [ADDR_WIDTH-1:0] reg_addr;
        input [DATA_WIDTH-1:0] expected_value;
        input expected_cout;
        input check_cout_enable;
        input string test_name;
        
        reg [DATA_WIDTH-1:0] actual_value;
        begin
            // Читаем значение из регистра
            read_register(reg_addr, actual_value);
            
            // Проверяем основное значение
            if (actual_value !== expected_value) begin
                $display("==================================================================");
                $display("Time %t: ✗ CRITICAL ERROR IN TEST: %s", $time, test_name);
                $display("REGISTER VALUE MISMATCH !");
                $display("  Register: %s", get_reg_name(reg_addr));
                $display("  Expected: %h", expected_value);
                $display("  Actual:   %h", actual_value);
                $display("  Difference: %h", actual_value ^ expected_value);
                $display("==================================================================");
                $finish;
            end
            
            // Проверяем Cout, если включено
            if (check_cout_enable && alu_cout !== expected_cout) begin
                $display("==================================================================");
                $display("Time %t: ✗ CRITICAL ERROR IN TEST: %s", $time, test_name);
                $display("CARRY FLAG MISMATCH!");
                $display("  Expected Cout: %s", (expected_cout ? "YES" : "NO"));
                $display("  Actual Cout:   %s", (alu_cout ? "YES" : "NO"));
                $display("  Register %s = %h", get_reg_name(reg_addr), actual_value);
                $display("==================================================================");
                $finish;
            end
            
            // Вывод успеха
            $display("Time %t: ✓ PASS %s: %s = %h%s", 
                    $time, test_name, get_reg_name(reg_addr), actual_value,
                    check_cout_enable ? $sformatf(", Cout = %s", (alu_cout ? "YES" : "NO")) : "");
        end
    endtask

    // TODO: Проверить. В настоящий момент не проверялось

    function check_alu_flags;
        input expected_cout;
        input expected_nbo;
        input expected_ngo;
        input string test_name;
        begin
            if (alu_cout === expected_cout && 
                alu_nbo === expected_nbo && 
                alu_ngo === expected_ngo) begin
                $display("Time %t: ✓ PASS %s: Flags Cout=%s, NBO=%s, NGO=%s", 
                        $time, test_name,
                        (alu_cout ? "YES" : "NO"),
                        (alu_nbo ? "YES" : "NO"), 
                        (alu_ngo ? "YES" : "NO"));
                check_alu_flags = 1;
            end else begin
                $display("Time %t: ✗ FLAGS FAIL %s:", $time, test_name);
                $display("  Expected: Cout=%s, NBO=%s, NGO=%s",
                        (expected_cout ? "YES" : "NO"),
                        (expected_nbo ? "YES" : "NO"), 
                        (expected_ngo ? "YES" : "NO"));
                $display("  Actual:   Cout=%s, NBO=%s, NGO=%s",
                        (alu_cout ? "YES" : "NO"),
                        (alu_nbo ? "YES" : "NO"), 
                        (alu_ngo ? "YES" : "NO"));
                check_alu_flags = 0;
            end
        end
    endfunction

    function string get_reg_name;
        input [ADDR_WIDTH-1:0] addr;
        begin
            case(addr)
                0: get_reg_name = "R0";
                1: get_reg_name = "R1";
                2: get_reg_name = "R2";
                3: get_reg_name = "R3";
                4: get_reg_name = "R4";
                5: get_reg_name = "R5";
                6: get_reg_name = "R6";
                7: get_reg_name = "R7";
                default: get_reg_name = $sformatf("R%0d", addr);
            endcase
        end
    endfunction

    // Тест 1: Сброс и начальная инициализация
    task test_reset;
        begin
            $display("\n=== Starting Test 1: Reset ===");
            track_test_scenario(1);
            
            // Применяем сброс
            reset = 1;
            @(posedge clk);
            #1;
            reset = 0;
            
            // Проверяем, что регистры сброшены в 0
            for (int i = 0; i < NUM_REGS; i++) begin
                reg_read_addr1 = i;
                @(posedge clk);
                #1;
                if (reg_read_data1 !== 0) begin
                    $display("Time %t: ✗ RESET FAIL: %s = %h (expected 0)", 
                            $time, get_reg_name(i), reg_read_data1);
                    $finish;
                end
            end
            
            $display("Time %t: ✓ All registers reset to 0", $time);
            -> test1_done;
        end
    endtask

    // Тест 2: Запись и чтение регистров
    task test_register_rw;
        begin
            $display("\n=== Starting Test 2: Register Read/Write ===");
            track_test_scenario(2);
            
            // Записываем тестовые значения в регистры
            write_register(REG_R1, 16'h1234);
            write_register(REG_R2, 16'h5678);
            write_register(REG_R3, 16'h9ABC);
            
            // Читаем и проверяем значения
            `CHECK(REG_R1, 16'h1234, "Register Write R1");
            `CHECK(REG_R2, 16'h5678, "Register Write R2");
            `CHECK(REG_R3, 16'h9ABC, "Register Write R3");
            
            // Проверяем, что другие регистры остались 0
            `CHECK(REG_R4, 16'h0000, "Register R4 unchanged");
            `CHECK(REG_R5, 16'h0000, "Register R5 unchanged");
            
            -> test2_done;
        end
    endtask

    // Тест 3: Простое сложение
    task test_simple_add;
        begin
            $display("\n=== Starting Test 3: Simple Addition ===");
            track_test_scenario(3);
            
            // Подготавливаем операнды
            write_register(REG_R1, 16'h0005);
            write_register(REG_R2, 16'h0003);
            
            // Выполняем сложение: R3 = R1 + R2
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_A_PLUS_B, 
                    CARRY_IN_DISABLED, 
                    "ADD");
            
            // Проверяем результат
            `CHECK_COUT(REG_R3, 16'h0008, CARRY_OUT_DISABLED, "Simple Addition");
            
            -> test3_done;
        end
    endtask

    // Тест 4: Сложение с переносом
    task test_add_with_carry;
        begin
            $display("\n=== Starting Test 4: Addition with Carry ===");
            track_test_scenario(4);
            
            // Подготавливаем операнды
            write_register(REG_R1, 16'h0005);
            write_register(REG_R2, 16'h0003);
            
            // Выполняем сложение с переносом: R3 = R1 + R2 + Cin
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_A_PLUS_B_PLUS_CARRY, 
                    CARRY_IN_ENABLED, 
                    "ADD with Carry");
            
            // Проверяем результат
            `CHECK_COUT(REG_R3, 16'h0009, CARRY_OUT_DISABLED, "Addition with Carry");
            
            -> test4_done;
        end
    endtask

    // Тест 5: Сложение с переполнением
    task test_add_overflow;
        begin
            $display("\n=== Starting Test 5: Addition with Overflow ===");
            track_test_scenario(5);
            
            // Подготавливаем операнды для переполнения
            write_register(REG_R1, 16'hFFFF);
            write_register(REG_R2, 16'h0001);
            
            // Выполняем сложение: R3 = R1 + R2
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_A_PLUS_B, 
                    CARRY_IN_DISABLED, 
                    "ADD Overflow");
            
            // Проверяем результат и перенос
            `CHECK_COUT(REG_R3, 16'h0000, CARRY_OUT_ENABLED, "Addition with Overflow");
            
            -> test5_done;
        end
    endtask

    // Тест 6: Вычитание
    task test_subtract;
        begin
            $display("\n=== Starting Test 6: Subtraction ===");
            track_test_scenario(6);
            
            // Подготавливаем операнды
            write_register(REG_R1, 16'h0008);
            write_register(REG_R2, 16'h0003);
            
            // Выполняем вычитание: R3 = R1 - R2
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_A_MINUS_B_MINUS_CARRY, 
                    CARRY_IN_ENABLED, // Для вычитания нужен Cin=0
                    "SUB");
            
            // Проверяем результат
            `CHECK_COUT(REG_R3, 16'h0005, CARRY_OUT_ENABLED, "Subtraction");
            
            -> test6_done;
        end
    endtask

    // Тест 7: Вычитание с заёмом
    task test_subtract_with_borrow;
        begin
            $display("\n=== Starting Test 7: Subtraction with Borrow ===");
            track_test_scenario(7);
            
            // Подготавливаем операнды
            write_register(REG_R1, 16'h0008);
            write_register(REG_R2, 16'h0003);
            
            // Выполняем вычитание с заёмом: R3 = R1 - R2 - ~Cin
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_A_MINUS_B_MINUS_CARRY, 
                    CARRY_IN_DISABLED, // Cin=1 для вычитания с заёмом
                    "SUB with Borrow");
            
            // Проверяем результат
            `CHECK_COUT(REG_R3, 16'h0004, CARRY_OUT_ENABLED, "Subtraction with Borrow");
            
            -> test7_done;
        end
    endtask

    // Тест 8: Инкремент
    task test_increment;
        begin
            $display("\n=== Starting Test 8: Increment ===");
            track_test_scenario(8);
            
            // Подготавливаем операнд
            write_register(REG_R1, 16'h0005);
            
            // Выполняем инкремент: R2 = R1 + 1
            `ALU_IMM(REG_R1, 
                    REG_R2, 
                    OP_A_PLUS_B, 
                    CARRY_IN_DISABLED, 
                    16'h0001, 
                    "INC");
            
            // Проверяем результат
            `CHECK_COUT(REG_R2, 16'h0006, CARRY_OUT_DISABLED, "Increment");
            
            -> test8_done;
        end
    endtask

    // Тест 9: Декремент
    task test_decrement;
        begin
            $display("\n=== Starting Test 9: Decrement ===");
            track_test_scenario(9);
            
            // Подготавливаем операнд
            write_register(REG_R1, 16'h0005);
            
            // Выполняем декремент: R2 = R1 - 1
            `ALU_IMM(REG_R1, 
                    REG_R2, 
                    OP_A_MINUS_B_MINUS_CARRY, 
                    CARRY_IN_ENABLED, 
                    16'h0001, 
                    "DEC");
            
            // Проверяем результат
            `CHECK_COUT(REG_R2, 16'h0004, CARRY_OUT_ENABLED, "Decrement");
            
            -> test9_done;
        end
    endtask

    // Тест 10: Побитовое И
    task test_and;
        begin
            $display("\n=== Starting Test 10: Bitwise AND ===");
            track_test_scenario(10);
            
            // Подготавливаем операнды
            write_register(REG_R1, 16'hF0F0);
            write_register(REG_R2, 16'h0F0F);
            
            // Выполняем AND: R3 = R1 & R2
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_A_AND_B, 
                    CARRY_IN_DISABLED, 
                    "AND");
            
            // Проверяем результат
            `CHECK(REG_R3, 16'h0000, "Bitwise AND");
            
            -> test10_done;
        end
    endtask

    // Тест 11: Побитовое ИЛИ
    task test_or;
        begin
            $display("\n=== Starting Test 11: Bitwise OR ===");
            track_test_scenario(11);
            
            // Подготавливаем операнды
            write_register(REG_R1, 16'hF0F0);
            write_register(REG_R2, 16'h0F0F);
            
            // Выполняем OR: R3 = R1 | R2
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_A_OR_B, 
                    CARRY_IN_DISABLED, 
                    "OR");
            
            // Проверяем результат
            `CHECK(REG_R3, 16'hFFFF, "Bitwise OR");
            
            -> test11_done;
        end
    endtask

    // Тест 12: Побитовое XOR
    task test_xor;
        begin
            $display("\n=== Starting Test 12: Bitwise XOR ===");
            track_test_scenario(12);
            
            // Подготавливаем операнды
            write_register(REG_R1, 16'hF0F0);
            write_register(REG_R2, 16'h0F0F);
            
            // Выполняем XOR: R3 = R1 ^ R2
            `ALU_REG(REG_R1, REG_R2, 
                    REG_R3, 
                    OP_XOR, 
                    CARRY_IN_DISABLED, 
                    "XOR");
            
            // Проверяем результат
            `CHECK(REG_R3, 16'hFFFF, "Bitwise XOR");
            
            -> test12_done;
        end
    endtask

    // Основной тестовый процесс
    initial begin
        // Инициализация
        clk = 0;
        reset = 0;
        reg_write_enable = 0;
        reg_read_addr1 = 0;
        reg_read_addr2 = 0;
        reg_write_addr = 0;
        reg_write_data = 0;
        alu_cin = 0;
        alu_mode = 0;
        b_source_sel = 0;
        alu_comm = 0;
        alu_b_imm = 0;
        
        // Инициализация coverage
        initialize_coverage();
        
        // Ждем немного перед началом тестов
        #10;
        
        // Запускаем тесты последовательно
        test_reset();
        test_register_rw();
        test_simple_add();
        test_add_with_carry();
        test_add_overflow();
        test_subtract();
        test_subtract_with_borrow();
        test_increment();
        test_decrement();
        test_and();
        test_or();
        test_xor();
        
        // Ждем завершения всех тестов
        wait(test12_done.triggered);
        
        // Печатаем отчет о покрытии
        print_coverage_report();
        
        $display("\n=== ALL TESTS COMPLETED SUCCESSFULLY! ===");
        $display("Time %t: Simulation finished", $time);
        $finish;
    end

endmodule