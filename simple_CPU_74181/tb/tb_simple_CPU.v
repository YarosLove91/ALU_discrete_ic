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
    event test11_done, test12_done; // Добавлены новые события для логических тестов
    
    // Helper functions для лучшей читаемости
    function string get_mode_name;
        input mode;
        begin
            get_mode_name = (mode == 0) ? "Math" : "Logic";
        end
    endfunction
    
    function string get_b_source_name;
        input sel;
        begin
            get_b_source_name = (sel == 0) ? "Register" : "Immediate";
        end
    endfunction
    
    // Task для записи в регистр
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
            $display("Time %t: Write %h to reg%d", $time, data, addr);
        end
    endtask
    
    // Task для выполнения операции АЛУ
    task execute_alu_operation;
        input [3:0] operation;
        input mode;
        input cin;
        input b_sel;
        input [DATA_WIDTH-1:0] b_value;
        input string op_name;
        begin
            alu_comm = operation;
            alu_mode = mode;
            alu_cin = cin;
            b_source_sel = b_sel;
            alu_b_imm = b_value;
            @(posedge clk);
            #1;
            $display("Time %t: %s: A=%h, B=%h, Mode=%s, Cin=%b, Result=%h, Cout=%b", 
                     $time, op_name, reg_read_data1, 
                     (b_sel ? b_value : reg_read_data2),
                     get_mode_name(mode), cin, alu_result, alu_cout);
        end
    endtask
    
    // Task для проверки результата
    task check_result;
        input [DATA_WIDTH-1:0] expected;
        input string test_name;
        begin
            if (alu_result !== expected) begin
                $display("ERROR in %s: Expected %h, Got %h", 
                         test_name, expected, alu_result);
                $finish;
            end else begin
                $display("PASS: %s - Result %h", test_name, alu_result);
            end
        end
    endtask
    
    // Основной тестовый процесс - координатор
    initial begin
        // Инициализация
        clk = 0;
        reset = 1;
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
        
        $display("=== Starting CPU Top Level Test ===");
        $display("Data Width: %d bits, Registers: %d", DATA_WIDTH, NUM_REGS);
        
        // Сброс
        #10 reset = 0;
        #10;
        
        // Запуск тестов по порядку
        -> test_start;
        
        // Ожидание завершения всех тестов
        @(test4_done);
        
        $display("\n=== ALL TESTS PASSED! ===");
        #50 $finish;
    end
    
    // Тест 1: Инициализация регистров для логических операций
    initial begin
        @(test_start);
        $display("\n=== Register Initialization for Logic Tests ===");
        
        write_register(REG_R1, TEST_VAL_1);  // Test pattern 1
        write_register(REG_R2, TEST_VAL_2);  // Test pattern 2  
        write_register(REG_R3, TEST_MASK_LOW_ONES);  // Mask for AND
        write_register(REG_R4, TEST_MASK_HIGH_ONES);  // Mask for OR
        write_register(REG_R5, TEST_MASK_ONES_EVENS);  // Pattern for XOR
        write_register(REG_R6, TEST_MASK_ONES_ODDS );  // Pattern for complement
        
        $display("\n=== Test 1: Logic operations ===");
        $display("\n=== Test 1.1: AND Operations (mode=Logic) ===");

        reg_read_addr1 = REG_R1; // A = 1234
        
        // AND с immediate значением
        execute_alu_operation(4'b1011, 1, 0, 1, TEST_MASK_LOW_ONES, "AND Immediate 00FF");
        check_result(16'h1234 & 16'h00FF, "AND Immediate Test");
        
        // AND с регистром
        reg_read_addr2 = 3; // B = 00FF
        execute_alu_operation(4'b1011, 1, 0, 0, 0, "AND Register");
        check_result(16'h1234 & 16'h00FF, "AND Register Test");
        
        // AND с полной маской
        execute_alu_operation(4'b1011, 1, 0, 1, TEST_ONES, "AND Full Mask");
        check_result(16'h1234, "AND Full Mask Test");
        
        // AND с нулевой маской
        execute_alu_operation(4'b1011, 1, 0, 1, TEST_ZERO, "AND Zero Mask");
        check_result(16'h0000, "AND Zero Mask Test");
        
        $display("\n=== Test 1.2: OR Operations (mode=Logic) ===");
        
        reg_read_addr1 = REG_R1; // A = 1234
        
        // OR с immediate значением
        execute_alu_operation(4'b1110, 1, 0, 1, TEST_MASK_HIGH_ONES, "OR Immediate FF00");
        check_result(16'h1234 | 16'hFF00, "OR Immediate Test");
        
        // OR с регистром
        reg_read_addr2 = REG_R4; // B = FF00
        execute_alu_operation(4'b1110, 1, 0, 0, 0, "OR Register");
        check_result(16'h1234 | 16'hFF00, "OR Register Test");
        
        // OR с нулевой маской
        execute_alu_operation(4'b1110, 1, 0, 1, TEST_ZERO, "OR Zero Mask");
        check_result(16'h1234, "OR Zero Mask Test");
        
        // OR с полной маской
        execute_alu_operation(4'b1110, 1, 0, 1, TEST_ONES, "OR Full Mask");
        check_result(16'hFFFF, "OR Full Mask Test");
        
        $display("\n=== Test 1.3: Other Logic Operations ===");
        
        // XOR операция
        reg_read_addr1 = REG_R5; // A = AAAA
        execute_alu_operation(4'b0110, 1, 0, 1, 16'h5555, "XOR with 5555");
        check_result(16'hAAAA ^ 16'h5555, "XOR Test");
        
        // NOT операция (XOR с FFFF)
        execute_alu_operation(4'b0110, 1, 0, 1, TEST_ONES, "NOT (XOR with FFFF)");
        check_result(~16'hAAAA, "NOT Test");
        
        $display("\n=== Test 1.4: Carry in Logic Operations ===");

        // Проверка что переносы не влияют на логические операции
        reg_read_addr1 = REG_R1; // A = 1234
        execute_alu_operation(4'b1011, 1, 1, 1, TEST_MASK_LOW_ONES, "AND with Cin=1");
        check_result(16'h1234 & 16'h00FF, "AND with Carry Test");
        if (alu_cout !== 1'b0) begin
            $display("ERROR: Carry should not be set in logic mode");
            $finish;
        end
        $display("PASS: Carry correctly not set in logic mode");
        
        -> test1_done;
    end

    // Тест 2: Арифметические операции
    initial begin
        @(test1_done);
        $display("\n=== Register Initialization for Arithmetic Tests ===");
        
        write_register(REG_R0, TEST_ZERO);
        write_register(REG_R1, 16'h0001);
        write_register(REG_R2, TEST_VAL_1);
        write_register(REG_R3, TEST_VAL_2);
        write_register(REG_R4, 16'h9ABC);
        
        reg_read_addr1 = REG_R2; // A = 1234
        reg_read_addr2 = REG_R3; // B = 5678
        
        $display("Reg2 = %h, Reg3 = %h", reg_read_data1, reg_read_data2);
        $display("\n=== Test 2: Arithmetic Operations (mode=Math) ===");
        
        // Сложение
        execute_alu_operation(4'b1001, 0, 1, 0, 0, "ADD without carry"); // Cin=1 -> без переноса
        check_result(16'h68ac, "Addition without carry");
        
        execute_alu_operation(4'b1001, 0, 0, 0, 0, "ADD with carry"); // Cin=0 -> с переносом
        check_result(16'h68ad, "Addition with carry");
        
        // Проверим другие простые сложения
        write_register(REG_R7, 16'h0001);
        reg_read_addr1 = REG_R7; // A = 0001
        reg_read_addr2 = REG_R7; // B = 0001
        
        execute_alu_operation(4'b1001, 0, 1, 0, 0, "1 + 1 without carry");
        check_result(16'h0002, "1 + 1 without carry");
        
        execute_alu_operation(4'b1001, 0, 0, 0, 0, "1 + 1 with carry");
        check_result(16'h0003, "1 + 1 with carry");
        
        // Вычитание - С заемом (borrow) - нужен перенос!
        reg_read_addr1 = REG_R2; // A = 1234
        reg_read_addr2 = REG_R3; // B = 5678
        execute_alu_operation(4'b0110, 0, 0, 0, 0, "SUB with borrow"); // Cin=0 -> с переносом
        check_result(16'h1234 - 16'h5678, "Subtraction Test");

        execute_alu_operation(4'b0110, 0, 1, 0, 0, "SUB without borrow"); // Cin=1 -> без переноса
        check_result((16'h1234 - 16'h5678)-1, "Subtraction Test");

        // Сложение с immediate значением - без переноса
        execute_alu_operation(4'b1001, 0, 1, 1, 16'h0005, "ADD immediate without carry");
        check_result(16'h1239, "Addition Immediate Test");
        
        // Сложение с immediate значением - с переносом
        execute_alu_operation(4'b1001, 0, 0, 1, 16'h0005, "ADD immediate without carry");
        check_result(16'h1239+1'b1, "Addition Immediate Test");

        -> test2_done;
    end
    
    // Тест 3: Сравнение режимов (оригинальный тест 4)
    initial begin
        @(test2_done);
        $display("\n=== Test 3: Mode Comparison ===");
        
        write_register(REG_R2, TEST_VAL_1);
        write_register(REG_R5, TEST_MASK_LOW_ONES);

        reg_read_addr1 = REG_R2; // A = 1234
        reg_read_addr2 = REG_R5; // B = 00FF

        // Арифметическое И (mode=0) с переносом
        execute_alu_operation(4'b1011, 0, 0, 1, 16'h00FF, "Arithmetic 'AB - 1'");
        check_result(16'h1234 & 16'h00FF, "Logical AND Test");

        // Арифметическое И (mode=0) без переноса
        execute_alu_operation(4'b1011, 0, 3, 1, 16'h00FF, "Arithmetic 'AB - 1'");
        check_result((16'h1234 & 16'h00FF)-1, "Logical AND Test");
        
        // В логических инструкциях переносы не учитываются
        // Логическое И (mode=1) с переносом
        execute_alu_operation(4'b1011, 1, 0, 1, 16'h00FF, "Logical AND");
        check_result(16'h1234 & 16'h00FF, "Logical AND Test");
        
        // Логическое ИЛИ без переноса
        execute_alu_operation(4'b1011, 1, 1, 1, 16'h00FF, "Logical AND");
        check_result(16'h1234 & 16'h00FF, "Logical AND Test");

        // Логическое ИЛИ-НЕ без переноса
        execute_alu_operation(4'b0100, 1, 0, 1, 16'h00FF, "Logical AND");
        check_result(~(16'h1234 & 16'h00FF), "Logical AND Test");
        
        // Логическое ИЛИ-НЕ без переноса
        execute_alu_operation(4'b0100, 1, 1, 1, 16'h00FF, "Logical AND");
        check_result(~(16'h1234 & 16'h00FF), "Logical AND Test");

        -> test3_done;
    end

    // Тест 4: Операции с переносами
    initial begin
        @(test3_done);
    
        $display("\n=== Test 4: Carry Operations ===");
        
        write_register(REG_R5, TEST_ONES);
        reg_read_addr1 = REG_R5; // A = FFFF
        
        // Инкремент: FFFF + 1 = 0000 (без дополнительного +1 от Cin)
        execute_alu_operation(4'b1001, 0, 1, 1, 16'h0001, "INCREMENT"); // Cin=1 -> без переноса
        check_result(16'h0000, "Increment FFFF");
        if (alu_cout) begin
            $display("ERROR: Carry out expected");
            $finish;
        end
        $display("PASS: Carry out detected");

        // Инкремент: FFFF + 1 = 0000 (с дополнительным +1 от Cin)
        execute_alu_operation(4'b1001, 0, 0, 1, 16'h0001, "INCREMENT"); // Cin=1 -> без переноса
        check_result(16'h0001, "Increment FFFF");
        if (alu_cout) begin
            $display("ERROR: Carry out expected");
            $finish;
        end

        -> test4_done;
    end
    /*
    // Тест 5: Декремент
    initial begin
        @(test4_done);
        $display("\n=== Test 5: Decrement Operation ===");
        
        write_register(6, 16'h0000);
        reg_read_addr1 = 6; // A = 0000
        
        // Декремент: 0000 - 1 = FFFF
        // Используем операцию вычитания 4'b0110 с immediate значением 1
        // Для вычитания: Cin=0 -> с переносом (A - B)
        execute_alu_operation(4'b0110, 0, 0, 1, 16'h0001, "DECREMENT");
        check_result(16'hFFFF, "Decrement Zero");
        
        -> test5_done;
    end
    
    // Тест 6: Сдвиг/удвоение - диагностика
    initial begin
        @(test5_done);
        $display("\n=== Test 6: Shift/Double Operation Diagnostics ===");
        
        write_register(6, 16'h0013);
        write_register(7, 16'h0007);
        
        reg_read_addr1 = 7;     // A = 0007
        reg_read_addr2 = 6;     // B = 0013

        $display("Testing command 4'b1100 in different modes:");
        
        // Логический режим (M=1) - должно быть 1
        execute_alu_operation(4'b1100, 1, 0, 1, 16'h0000, "4'b1100 Logic mode");
        check_result(16'hFFFF, "Logic mode: 1");            // 1
        
        // Арифметический режим (M=0) - должно быть 2A
        execute_alu_operation(4'b1100, 0, 1, 1, 16'h0000, "4'b1100 Math mode");
        check_result(16'h000E, "Math mode: A+A = 2A"); // (7+0)+7 = E (14)
        
        // Проверим другие команды для сдвига
        execute_alu_operation(4'b1111, 1, 0, 1, 0, "4'b1111 Logic mode");
        check_result(16'h0007, "Logic mode: = A"); // (7+0)+7 = E (14)
        
        execute_alu_operation(4'b1010, 1, 1, 0, reg_read_addr2, "4'b1010 Logic mode");
        check_result(16'h0013, "Logic mode: = B"); // (7+0)+7 = E (14)

        //$display("4'b1010 Logic result: %h (need to check table)", alu_result);
        
        // Правильный способ удвоения через сложение
        //execute_alu_operation(4'b1001, 0, 1, 1, 16'h0007, "Double via A + A");
        //check_result(16'h000E, "7 + 7 = E (14)");
        
        -> test6_done;
    end
    
    // Тест 7: Комплексная операция - проверка команды 4'b1100
    initial begin
        @(test6_done);
        
        $display("\n=== Test 7: Complex Operation ===");
        
        write_register(6, 16'h0005);
        write_register(7, 16'h0003);
        
        reg_read_addr1 = 6; // A = 5
        reg_read_addr2 = 7; // B = 3
        
        // (A + B) - обычное сложение
        execute_alu_operation(4'b1001, 0, 0, 0, 0, "A + B");
        write_register(6, alu_result); // 5 + 3 + 1 = 9 (т.к. Cin=0 добавляет +1)
        
        // Проверка команды 4'b1100 в двух режимах:
        reg_read_addr1 = 6; // A = 9
        
        // Режим 1: Cin=0 -> A + A + 1
        execute_alu_operation(4'b1100, 0, 0, 1, 0, "A + A + 1 (Cin=0)");
        check_result(16'h0013, "A + A + 1 Test"); // 9 + 9 + 1 = 19 (0013)
        
        // Режим 2: Cin=1 -> A + A  
        execute_alu_operation(4'b1100, 0, 1, 1, 0, "A + A (Cin=1)");
        check_result(16'h0012, "A + A Test"); // 9 + 9 = 18 (0012)
        
        // Для оригинального теста используем A + A (удвоение)
        check_result(16'h0012, "Complex Operation Test");

        -> test7_done;
    end
*/
endmodule


/*
    // Тест 7: Операция удвоения (A + A) - разными методами
    initial begin
        @(test6_done);
        $display("\n=== Test 7: Doubling Operation ===");
        
        // Тестируем удвоение разными командами
        write_register(1, 16'h0005);
        write_register(2, 16'h0009);
        
        $display("Testing various doubling methods:");
        
        // Метод 1: Через сложение A + A (команда 4'b1001)
        reg_read_addr1 = 1; // A = 5
        execute_alu_operation(4'b1001, 0, 1, 1, 16'h0005, "A + A via ADD"); // Cin=1 -> без переноса
        check_result(16'h000A, "5 + 5 = A");
        
        // Метод 2: Через команду 4'b1100 - (A + B) + A с B=0
        reg_read_addr1 = 1; // A = 5
        execute_alu_operation(4'b1100, 0, 1, 1, 16'h0000, "(A+0)+A via 4'b1100"); // Cin=1, B=0
        check_result(16'h000A, "(5+0)+5 = A");
        
        // Метод 3: Через команду 4'b1100 - (A + B) + A с B=5 (другое значение)
        reg_read_addr1 = 2; // A = 9
        execute_alu_operation(4'b1100, 0, 1, 1, 16'h0005, "(A+5)+A via 4'b1100"); // Cin=1, B=5
        check_result(16'h0017, "(9+5)+9 = 17"); // (9+5)+9 = 23 (0017)
        
        -> test7_done;
    end
    
    // Тест 8: Комплексная операция - оригинальный тест
    initial begin
        @(test7_done);
        $display("\n=== Test 8: Complex Operation ===");
        
        write_register(6, 16'h0005);
        write_register(7, 16'h0003);
        
        reg_read_addr1 = 6; // A = 5
        reg_read_addr2 = 7; // B = 3
        
        // (A + B) - через команду сложения 4'b1001
        execute_alu_operation(4'b1001, 0, 1, 0, 0, "A + B via 4'b1001"); // Cin=1 -> без переноса
        write_register(6, alu_result); // 5 + 3 = 8
        
        // Удвоение - через команду 4'b1100 с B=0: (A + 0) + A = A + A
        reg_read_addr1 = 6; // A = 8
        execute_alu_operation(4'b1100, 0, 1, 1, 16'h0000, "A + A via 4'b1100"); // Cin=1, B=0
        check_result(16'h0010, "Complex Operation Test"); // (8+0)+8 = 16 (0010)
        
        -> test8_done;
    end

*/