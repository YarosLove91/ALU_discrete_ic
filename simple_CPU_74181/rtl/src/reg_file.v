module param_reg_file
#(
    parameter DATA_WIDTH = 16,       // Разрядность данных
    parameter NUM_REGS   = 8,        // Количество регистров
    parameter ADDR_WIDTH = $clog2(NUM_REGS)  // Автоматический расчет разрядности адреса
)
(
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [ADDR_WIDTH-1:0] read_addr1,    // Адрес первого читаемого регистра
    input wire [ADDR_WIDTH-1:0] read_addr2,    // Адрес второго читаемого регистра
    input wire [ADDR_WIDTH-1:0] write_addr,    // Адрес записываемого регистра
    input wire [DATA_WIDTH-1:0] write_data,    // Данные для записи
    
    output wire [DATA_WIDTH-1:0] read_data1,   // Данные первого регистра
    output wire [DATA_WIDTH-1:0] read_data2    // Данные второго регистра
);

    // Проверка корректности параметров
    initial begin
        if (NUM_REGS <= 1) begin
            $display("Error: NUM_REGS must be at least 2, got %d", NUM_REGS);
            $finish;
        end
    end

    // Банк регистров
    reg [DATA_WIDTH-1:0] registers [0:NUM_REGS-1];
    
    // Асинхронное чтение с защитой от выхода за границы
    assign read_data1 = registers[read_addr1];
    assign read_data2 = registers[read_addr2];
    
    // Синхронная запись
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Сброс всех регистров в 0
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                registers[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (write_enable && (write_addr < NUM_REGS)) begin
            registers[write_addr] <= write_data;
        end
    end
    
    // Инициализация (для симуляции)
    initial begin
        for (i = 0; i < NUM_REGS; i = i + 1) begin
            registers[i] = {DATA_WIDTH{1'b0}};
        end
    end

endmodule