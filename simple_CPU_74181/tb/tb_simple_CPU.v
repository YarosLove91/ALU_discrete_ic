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
    reg [3:0] alu_sel;
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
        .alu_cout(alu_cout),

        .alu_mode(alu_mode),
        .alu_sel(alu_sel),
        .alu_b_imm(alu_b_imm),
        
        .reg_read_data1(reg_read_data1),
        .reg_read_data2(reg_read_data2),
        
        .alu_result(alu_result),
        
        .alu_nbo(alu_nbo),
        .alu_ngo(alu_ngo)
    );
    
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
        input [DATA_WIDTH-1:0] b_value;
        input string op_name;

        begin
            alu_sel = operation;
            alu_mode = mode;
            alu_cin = cin;
            alu_b_imm = b_value;
            @(posedge clk);
            #1;
            $display("Time %t: %s: A=%h, B=%h, Result=%h, Cout=%b", 
                     $time, op_name, reg_read_data1, 
                     (mode ? b_value : reg_read_data2), 
                     alu_result, alu_cout);
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
    
    // Основной тестовый процесс
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
        alu_sel = 0;
        alu_b_imm = 0;
        
        $display("=== Starting CPU Top Level Test ===");
        $display("Data Width: %d bits, Registers: %d", DATA_WIDTH, NUM_REGS);
        
        // Сброс
        #20 reset = 0;
        #10;
        
        // Тест 1: Инициализация регистров
        $display("\n=== Test 1: Register Initialization ===");
        write_register(2, 16'h1234);
        write_register(3, 16'h5678);
        write_register(4, 16'h9ABC);
        
        // Чтение регистров
        reg_read_addr1 = 2;
        reg_read_addr2 = 3;
        #1;
        $display("Reg2 = %h, Reg3 = %h", reg_read_data1, reg_read_data2);
        
        // Тест 2: Арифметические операции (режим 0)
        $display("\n=== Test 2: Arithmetic Operations ===");
        reg_read_addr1 = 2; // A = 1234
        reg_read_addr2 = 3; // B = 5678
        
        // Сложение
        execute_alu_operation(4'b1001, 0, 0, 0, "ADD");
        check_result(16'h1234 + 16'h5678, "Addition Test");
        
        // Вычитание
        execute_alu_operation(4'b0110, 0, 1, 0, "SUB");
        check_result(16'h1234 - 16'h5678, "Subtraction Test");
        
        // Тест 3: Логические операции (режим 1)
        $display("\n=== Test 3: Logical Operations ===");
        reg_read_addr1 = 2; // A = 1234
        
        // Логическое И с непосредственным значением
        execute_alu_operation(4'b1011, 1, 0, 16'h00FF, "AND Immediate");
        check_result(16'h1234 & 16'h00FF, "AND Test");
        
        // Логическое ИЛИ с непосредственным значением
        execute_alu_operation(4'b1110, 1, 0, 16'hFF00, "OR Immediate");
        check_result(16'h1234 | 16'hFF00, "OR Test");
        
        // Тест 4: Операции с переносами
        $display("\n=== Test 4: Carry Operations ===");
        write_register(5, 16'hFFFF);
        reg_read_addr1 = 5; // A = FFFF
        
        // Инкремент с переносом
        execute_alu_operation(4'b1100, 0, 0, 0, "INCREMENT");
        check_result(16'h0000, "Increment FFFF");
        if (!alu_cout) begin
            $display("ERROR: Carry out expected");
            $finish;
        
        // Тест 5: Комплексная операция
        $display("\n=== Test 5: Complex Operation ===");
        write_register(6, 16'h0005);
        write_register(7, 16'h0003);
        
        reg_read_addr1 = 6; // A = 5
        reg_read_addr2 = 7; // B = 3
        
        // (A + B) * 2
        execute_alu_operation(4'b1001, 0, 0, 0, "A + B");
        write_register(6, alu_result); // Сохраняем результат обратно в reg6
        
        execute_alu_operation(4'b1100, 0, 0, 0, "Shift Left (A + A)");
        check_result(16'h0010, "Complex Operation Test"); // (5+3)*2 = 16
        
        // Тест 6: Работа с флагами
        $display("\n=== Test 6: Flag Operations ===");
        write_register(6, 16'h0000);
        reg_read_addr1 = 6; // A = 0000
        
        execute_alu_operation(4'b0011, 0, 0, 0, "DECREMENT");
        check_result(16'hFFFF, "Decrement Zero");
        
        // Тест 7: Сброс системы
        $display("\n=== Test 7: System Reset ===");
        reset = 1;
        #10;
        reset = 0;
        #10;
        
        // Проверяем, что регистры сбросились
        reg_read_addr1 = 2;
        reg_read_addr2 = 3;
        #1;
        if (reg_read_data1 !== 0 || reg_read_data2 !== 0) begin
            $display("ERROR: Registers not reset properly");
            $finish;
        }
        $display("PASS: All registers reset to zero");
        
        $display("\n=== ALL TESTS PASSED! ===");
        #50 $finish;
    end
    
    // Мониторинг изменений
    always @(posedge clk) begin
        $display("--- CLK Edge ---");
        $display("  Reg1: %h, Reg2: %h", reg_read_data1, reg_read_data2);
        $display("  ALU Op: %b, Mode: %b, Result: %h", alu_sel, alu_mode, alu_result);
    end

endmodule