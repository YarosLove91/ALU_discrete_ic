module test_reg_file
#(
    parameter DATA_WIDTH = 16,
    parameter NUM_REGS   = 8,
    parameter ADDR_WIDTH = $clog2(NUM_REGS)
)();

    // Тестовые сигналы
    reg clk;
    reg reset;
    reg write_enable;
    reg [ADDR_WIDTH-1:0] read_addr1, read_addr2, write_addr;
    reg [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data1, read_data2;
    
    // Ожидаемые значения для проверки
    reg [DATA_WIDTH-1:0] expected_values [0:NUM_REGS-1];
    
    // DUT
    param_reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    // Генерация тактового сигнала
    always #5 clk = ~clk;
    
    // Функция для проверки считанных значений
    function automatic void check_read_values(
        input [ADDR_WIDTH-1:0] addr1,
        input [ADDR_WIDTH-1:0] addr2,
        input string test_name
    );
        begin
            if (read_data1 !== expected_values[addr1]) begin
                $display("ERROR in %s: Reg%d expected %h, got %h", 
                         test_name, addr1, expected_values[addr1], read_data1);
                $finish;
            end else begin
                $display("PASS: %s - Reg%d = %h", test_name, addr1, read_data1);
            end
            
            if (read_data2 !== expected_values[addr2]) begin
                $display("ERROR in %s: Reg%d expected %h, got %h", 
                         test_name, addr2, expected_values[addr2], read_data2);
                $finish;
            end else begin
                $display("PASS: %s - Reg%d = %h", test_name, addr2, read_data2);
            end
        end
    endfunction
    
    // Функция для записи и немедленной проверки
    task automatic write_and_check(
        input [ADDR_WIDTH-1:0] addr,
        input [DATA_WIDTH-1:0] data,
        input string test_name
    );
        begin
            write_enable = 1;
            write_addr = addr;
            write_data = data;
            expected_values[addr] = data;  // Обновляем ожидаемое значение
            
            #10;  // Ждем запись
            write_enable = 0;
            
            // Проверяем, что записалось правильно
            read_addr1 = addr;
            read_addr2 = addr;  // Читаем тот же регистр двумя портами
            #1;
            
            if (read_data1 !== data || read_data2 !== data) begin
                $display("ERROR in %s: Write failed to reg%d", test_name, addr);
                $display("  Expected: %h, Read1: %h, Read2: %h", 
                         data, read_data1, read_data2);
                $finish;
            end else begin
                $display("PASS: %s - Wrote %h to reg%d", test_name, data, addr);
            end
        end
    endtask
    
    // Инициализация expected_values
    integer i;
    initial begin
        for (i = 0; i < NUM_REGS; i = i + 1) begin
            expected_values[i] = {DATA_WIDTH{1'b0}};
        end
    end
    
    // Основной тестовый процесс
    initial begin
        // Инициализация
        clk = 0;
        reset = 1;
        write_enable = 0;
        read_addr1 = 0;
        read_addr2 = 0;
        write_addr = 0;
        write_data = 0;
        
        $display("=== Starting Test for %d registers, %d-bit data ===", NUM_REGS, DATA_WIDTH);
        $display("Address Width: %d bits", ADDR_WIDTH);
        
        // Тест 1: Сброс
        #10 reset = 0;
        #10;
        $display("\n=== Test 1: Reset ===");
        read_addr1 = 0;
        read_addr2 = 1;
        #1;
        check_read_values(0, 1, "Reset Test");
        
        // Тест 2: Запись в разные регистры
        $display("\n=== Test 2: Writing to registers ===");
        write_and_check(0,  16'h1234, "Write to reg0");
        write_and_check(3,  16'hABCD, "Write to reg3");
        write_and_check(1,  16'h5678, "Write to reg1");
        write_and_check(7,  16'hDEAD, "Write to reg7");
        
        if (NUM_REGS > 8) begin
            write_and_check(12, 16'hBEEF, "Write to reg12");
        end
        
        // Тест 3: Одновременное чтение разных регистров
        $display("\n=== Test 3: Simultaneous read ===");
        read_addr1 = 0;
        read_addr2 = 3;
        #1;
        check_read_values(0, 3, "Simultaneous Read 0 and 3");
        
        read_addr1 = 1;
        read_addr2 = 7;
        #1;
        check_read_values(1, 7, "Simultaneous Read 1 and 7");
        
        // Тест 4: Запись с выключенным write_enable
        $display("\n=== Test 4: Write with disabled enable ===");
        write_addr = 2;
        write_data = 16'h5555;  // Попытка записи
        write_enable = 0;       // Но enable выключен
        #10;
        
        read_addr1 = 2;
        read_addr2 = 2;
        #1;
        // Должен остаться 0 (не измениться)
        if (read_data1 !== 0 || read_data2 !== 0) begin
            $display("ERROR: Register changed without write enable!");
            $finish;
        end else begin
            $display("PASS: Register unchanged without write enable");
        end
        
        // Тест 5: Перезапись регистра
        $display("\n=== Test 5: Overwrite register ===");
        write_and_check(3, 16'h9999, "Overwrite reg3");
        
        // Проверяем, что другие регистры не изменились
        read_addr1 = 0;
        read_addr2 = 1;
        #1;
        check_read_values(0, 1, "Other registers unchanged");
        
        // Тест 6: Запись во все регистры по очереди
        $display("\n=== Test 6: Write to all registers ===");
        for (i = 0; i < NUM_REGS; i = i + 1) begin
            write_and_check(i[ADDR_WIDTH-1:0], (16'h1000 + i), $sformatf("Write to reg%d", i));
        end
        
        // Тест 7: Чтение всех регистров
        $display("\n=== Test 7: Read all registers ===");
        for (i = 0; i < NUM_REGS; i = i + 1) begin
            read_addr1 = i[ADDR_WIDTH-1:0];
            #1;
            if (read_data1 !== (16'h1000 + i)) begin
                $display("ERROR: Reg%d expected %h, got %h", i, (16'h1000 + i), read_data1);
                $finish;
            end
        end
        $display("PASS: All registers read correctly");
        
        // Тест 8: Проверка после такта
        $display("\n=== Test 8: Operation across clock edges ===");
        write_enable = 1;
        write_addr = 4;
        write_data = 16'h7777;
        @(posedge clk);  // Ждем rising edge
        #1;
        write_enable = 0;
        
        read_addr1 = 4;
        #1;
        if (read_data1 !== 16'h7777) begin
            $display("ERROR: Clock edge write failed");
            $finish;
        end else begin
            $display("PASS: Write on clock edge successful");
        end
        
        $display("\n=== ALL TESTS PASSED for %d registers ===", NUM_REGS);
        #10 $finish;
    end
    
    // Мониторинг для отладки
    always @(posedge clk) begin
        $display("CLK: time=%t, write_enable=%b, write_addr=%d, write_data=%h", 
                $time, write_enable, write_addr, write_data);
    end

endmodule