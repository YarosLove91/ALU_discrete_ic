module de10_lite
#(
    parameter WIDTH = 8  // Ширина данных (8 бит для АЛУ)
)
(
    input  [9:0] SW,       // 10 переключателей
    input  [1:0] KEY,      // 3 кнопки
    output [9:0] LEDR,     // 10 красных светодиодов
    output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    // Регистры для хранения операндов A и B (8 бит каждый)
    reg [7:0] a_reg = 0;
    reg [7:0] b_reg = 0;

    typedef enum logic [0:0] {
        MATH = 1'b0,  // Арифметический режим
        LOGIC = 1'b1  // Логический режим
    } state_t;

    state_t current_state = MATH;  // Начальное состояние автомата

    // Управление записью:
    // SW[9] - выбор операнда (0 - A, 1 - B)
    // SW[8] - выбор части (0 - младшая, 1 - старшая)
    // KEY[0] - запись (по нажатию кнопки)
    // KEY[1] - переключение режима работы АЛУ (логический/арифметический)

    // Сброс значений аргументов при нажатии KEY[0]
    always @(negedge KEY[0]) begin
        if (SW[9]) begin
            // Запись в операнд B
            if (SW[8]) b_reg[7:4] <= SW[3:0];  // Старшая часть
            else b_reg[3:0] <= SW[3:0];       // Младшая часть
        end else begin
            // Запись в операнд A
            if (SW[8]) a_reg[7:4] <= SW[3:0];  // Старшая часть
            else a_reg[3:0] <= SW[3:0];       // Младшая часть
        end
    end

    // Конечный автомат для переключения режима работы
    always @(negedge KEY[1]) begin
        case (current_state)
            MATH: current_state <= LOGIC;  // Переключение в логический режим
            LOGIC: current_state <= MATH; // Переключение в арифметический режим
        endcase
    end

    // Подключение 8-битного АЛУ
    wire [7:0] alu_result;  // Результат работы АЛУ
    wire alu_cout;          // Выходной перенос

    alu8 alu_inst (
        .a(a_reg),
        .b(b_reg),
        .Cin(0),       
        .mode(current_state),      // Тип операции управляется состоянием автомата
        .sel(SW[7:4]),      // Код операции (SW7-SW4)
        .result(alu_result),
        .Cout(alu_cout),
        .nBo(),            
        .nGo()            
    );

    // Отображение результата на светодиодах
    assign LEDR[7:0] = alu_result;  // Результат работы АЛУ
    assign LEDR[8] = alu_cout;      // Выходной перенос
    assign LEDR[9] = 0;             // Неиспользуемый светодиод выключен

    // Отображение результата на семисегментных индикаторах
    hex_display disp0 (.digit(alu_result[3:0]), .seven_segments(HEX0));  // Младший разряд результата
    hex_display disp1 (.digit(alu_result[7:4]), .seven_segments(HEX1));  // Старший разряд результата

    // Отображение операндов на семисегментных индикаторах
    hex_display disp2 (.digit(a_reg[3:0]), .seven_segments(HEX2));       // Младший разряд операнда A
    hex_display disp3 (.digit(a_reg[7:4]), .seven_segments(HEX3));       // Старший разряд операнда A
    hex_display disp4 (.digit(b_reg[3:0]), .seven_segments(HEX4));       // Младший разряд операнда B
    hex_display disp5 (.digit(b_reg[7:4]), .seven_segments(HEX5));       // Старший разряд операнда B

endmodule

module hex_display
(
    input      [3:0] digit,
    output reg [7:0] seven_segments
);

    always @*
        case (digit)
        4'h0: seven_segments = 8'b11000000;  // a b c d e f g h
        4'h1: seven_segments = 8'b11111001;
        4'h2: seven_segments = 8'b10100100;
        4'h3: seven_segments = 8'b10110000;
        4'h4: seven_segments = 8'b10011001;
        4'h5: seven_segments = 8'b10010010;
        4'h6: seven_segments = 8'b10000010;
        4'h7: seven_segments = 8'b11111000;
        4'h8: seven_segments = 8'b10000000;
        4'h9: seven_segments = 8'b10011000;
        4'hA: seven_segments = 8'b10001000;
        4'hB: seven_segments = 8'b10000011;
        4'hC: seven_segments = 8'b11000110;
        4'hD: seven_segments = 8'b10100001;
        4'hE: seven_segments = 8'b10000110;
        4'hF: seven_segments = 8'b10001110;
        default: seven_segments = 8'b11111111;
        endcase

endmodule
