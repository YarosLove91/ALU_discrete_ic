module cpu_top
#(
    parameter DATA_WIDTH = 16,
    parameter NUM_REGS = 8,
    parameter ADDR_WIDTH = $clog2(NUM_REGS)
)
(
    input wire clk,
    input wire reset,
    input wire reg_write_enable,
    input wire [ADDR_WIDTH-1:0] reg_read_addr1,
    input wire [ADDR_WIDTH-1:0] reg_read_addr2,
    input wire [ADDR_WIDTH-1:0] reg_write_addr,
    input wire [DATA_WIDTH-1:0] reg_write_data,

    input wire alu_cin,            // Флаг переноса
    input wire alu_mode,           // Режим АЛУ: 0-арифметика, 1-логика
    input wire [3:0] alu_comm,      // Команда операции

    input wire b_source_sel,       // Выбор источника B: 0-регистр, 1-immediate
    input wire [DATA_WIDTH-1:0] alu_b_imm,  // Непосредственное значение для АЛУ

    output wire [DATA_WIDTH-1:0] reg_read_data1,
    output wire [DATA_WIDTH-1:0] reg_read_data2,
    output wire [DATA_WIDTH-1:0] alu_result,
    output wire alu_cout,
    output wire alu_nbo,
    output wire alu_ngo
);

    // Сигналы от регистрового файла к АЛУ
    wire [DATA_WIDTH-1:0] reg1_to_alu;
    wire [DATA_WIDTH-1:0] reg2_to_alu;
    
    // Регистровый файл
    param_reg_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_REGS(NUM_REGS)
    ) register_file (
        .clk(clk),                      // Тактирование
        .reset(reset),                  // Сброс
        .write_enable(reg_write_enable),// Разрешение записи в р-й файл
        .read_addr1(reg_read_addr1),    // Адрес первого операнда
        .read_addr2(reg_read_addr2),    // Адрес второго операнда
        .write_addr(reg_write_addr),    // Адрес ячейки памяти в которую ведется запись
        .write_data(reg_write_data),    // Записываемое значение
        .read_data1(reg1_to_alu),       // Считанный аргумент #1
        .read_data2(reg2_to_alu)        // Считанный аргумента #2
    );
    
    // Мультиплексор для выбора источника операнда B
    wire [DATA_WIDTH-1:0] alu_b = b_source_sel ? alu_b_imm : reg2_to_alu;
    
    // 16-битное АЛУ
    alu16 arithmetic_logic_unit (
        .a(reg1_to_alu),        // Операнд A или непосредственное значение
        .b(alu_b),              // Операнд B
        .Cin(alu_cin),          // Carry In
        .mode(alu_mode),        // Режим работы АЛУ
        .sel(alu_comm),         // Команда АЛУ
        .result(alu_result),    // Результат работы АЛУ
        .Cout(alu_cout),        // Флаг переноса
        .nBo(alu_nbo),              
        .nGo(alu_ngo)
    );
    
    // Выходные сигналы
    assign reg_read_data1 = reg1_to_alu;
    assign reg_read_data2 = reg2_to_alu;

endmodule