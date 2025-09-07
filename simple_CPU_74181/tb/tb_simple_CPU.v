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
        #20 reset = 0;
        #10;
        
        // Запуск тестов по порядку
        -> test_start;
        
        // Ожидание завершения всех тестов
        @(test10_done);
        
        $display("\n=== ALL TESTS PASSED! ===");
        #50 $finish;
    end
    
    // Тест 1: Инициализация регистров
    initial begin
        @(test_start);
        $display("\n=== Test 1: Register Initialization ===");
        
        write_register(0, 16'h0000);
        write_register(1, 16'h0001);
        write_register(2, 16'h1234);
        write_register(3, 16'h5678);
        write_register(4, 16'h9ABC);
        
        // Чтение регистров
        reg_read_addr1 = 2;
        reg_read_addr2 = 3;
        #1;
        $display("Reg2 = %h, Reg3 = %h", reg_read_data1, reg_read_data2);
        
        -> test1_done;
    end
    
    // Тест 2: Арифметические операции
    initial begin
        @(test1_done);
        $display("\n=== Test 2: Arithmetic Operations (mode=Math) ===");
        
        reg_read_addr1 = 2; // A = 1234
        reg_read_addr2 = 3; // B = 5678
        
        // Сложение (B из регистра)
        execute_alu_operation(4'b1001, 0, 0, 0, 0, "ADD (register B)");
        check_result(16'h68ac, "Addition Test"); // Исправлено ожидаемое значение
        
        // Вычитание (B из регистра)
        execute_alu_operation(4'b0110, 0, 1, 0, 0, "SUB (register B)");
        check_result(16'h1234 - 16'h5678, "Subtraction Test");
        
        // Сложение с immediate значением
        execute_alu_operation(4'b1001, 0, 0, 1, 16'h0005, "ADD (immediate B=5)");
        check_result(16'h1239, "Addition Immediate Test"); // Исправлено ожидаемое значение
        
        -> test2_done;
    end
    
    // Тест 3: Логические операции
    initial begin
        @(test2_done);
        $display("\n=== Test 3: Logical Operations (mode=Logic) ===");
        
        reg_read_addr1 = 2; // A = 1234
        
        // Логическое И с непосредственным значением
        execute_alu_operation(4'b1011, 1, 0, 1, 16'h00FF, "AND Immediate");
        check_result(16'h1234 & 16'h00FF, "AND Test");
        
        // Логическое ИЛИ с непосредственным значением
        execute_alu_operation(4'b1110, 1, 0, 1, 16'hFF00, "OR Immediate");
        check_result(16'h1234 | 16'hFF00, "OR Test");
        
        // Логическое И с регистром
        reg_read_addr2 = 4; // B = 9ABC
        execute_alu_operation(4'b1011, 1, 0, 0, 0, "AND Register");
        check_result(16'h1234 & 16'h9ABC, "AND Register Test");
        
        -> test3_done;
    end
    
    // Тест 4: Сравнение режимов
    initial begin
        @(test3_done);
        $display("\n=== Test 4: Mode Comparison ===");
        
        // Арифметическое И (mode=0)
        execute_alu_operation(4'b1011, 0, 0, 1, 16'h00FF, "Arithmetic 'AND'");
        $display("Note: This should be addition, not AND (mode=Math)");
        
        // Логическое И (mode=1)
        execute_alu_operation(4'b1011, 1, 0, 1, 16'h00FF, "Logical AND");
        check_result(16'h1234 & 16'h00FF, "Logical AND Test");
        
        -> test4_done;
    end
    
    // Тест 5: Операции с переносами
    initial begin
        @(test4_done);
        $display("\n=== Test 5: Carry Operations ===");
        
        write_register(5, 16'hFFFF);
        reg_read_addr1 = 5; // A = FFFF
        
        // Инкремент с переносом
        execute_alu_operation(4'b1100, 0, 0, 1, 16'h0001, "INCREMENT");
        check_result(16'h0000, "Increment FFFF");
        if (!alu_cout) begin
            $display("ERROR: Carry out expected");
            $finish;
        end
        $display("PASS: Carry out detected");
        
        -> test5_done;
    end
    
    // Тест 6: Декремент
    initial begin
        @(test5_done);
        $display("\n=== Test 6: Decrement Operation ===");
        
        write_register(6, 16'h0000);
        reg_read_addr1 = 6; // A = 0000
        execute_alu_operation(4'b0011, 0, 0, 1, 16'h0001, "DECREMENT");
        check_result(16'hFFFF, "Decrement Zero");
        
        -> test6_done;
    end
    
    // Тест 7: Сдвиг/удвоение
    initial begin
        @(test6_done);
        $display("\n=== Test 7: Shift/Double Operation ===");
        
        write_register(7, 16'h0007);
        reg_read_addr1 = 7; // A = 0007
        execute_alu_operation(4'b1100, 1, 0, 1, 0, "SHIFT LEFT/DOUBLE");
        $display("Logical shift left result: %h", alu_result);
        
        -> test7_done;
    end
    
    // Тест 8: Комплексная операция
    initial begin
        @(test7_done);
        $display("\n=== Test 8: Complex Operation ===");
        
        write_register(6, 16'h0005);
        write_register(7, 16'h0003);
        
        reg_read_addr1 = 6; // A = 5
        reg_read_addr2 = 7; // B = 3
        
        // (A + B) * 2
        execute_alu_operation(4'b1001, 0, 0, 0, 0, "A + B");
        write_register(6, alu_result);
        
        reg_read_addr1 = 6;
        execute_alu_operation(4'b1100, 0, 0, 1, 0, "Shift Left (A + A)");
        check_result(16'h0010, "Complex Operation Test");
        
        -> test8_done;
    end
    
    // Тест 9: Сброс системы
    initial begin
        @(test8_done);
        $display("\n=== Test 9: System Reset ===");
        
        reset = 1;
        #10;
        reset = 0;
        #10;
        
        // Проверяем сброс регистров
        reg_read_addr1 = 2;
        reg_read_addr2 = 3;
        #1;
        if (reg_read_data1 !== 0 || reg_read_data2 !== 0) begin
            $display("ERROR: Registers not reset properly");
            $finish;
        end
        $display("PASS: All registers reset to zero");
        
        -> test9_done;
    end
    
    // Тест 10: Групповые сигналы переноса
    initial begin
        @(test9_done);
        $display("\n=== Test 10: Group Carry Signals ===");
        
        write_register(2, 16'hFFFF);
        reg_read_addr1 = 2;
        
        execute_alu_operation(4'b1001, 0, 0, 1, 16'h0001, "ADD to check carry signals");
        $display("Group signals: nBo=%b, nGo=%b", alu_nbo, alu_ngo);
        
        -> test10_done;
    end

endmodule