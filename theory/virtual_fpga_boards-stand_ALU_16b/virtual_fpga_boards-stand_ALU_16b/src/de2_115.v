module de2_115(
    input  [17:0] SW,       // 18 переключателей
    input  [3:0]  KEY,      // 4 кнопки (используем только KEY[0])
    output [17:0] LEDR,     // 18 красных светодиодов
    output [8:0]  LEDG,     // 9 зеленых светодиодов (используем только LEDG[0])
    output [6:0]  HEX0, HEX1, HEX2, HEX3,
    output [6:0]  HEX4, HEX5, HEX6, HEX7
);
    // Регистры для хранения операндов A и B (16 бит каждый)
    reg [15:0] a_reg = 0;
    reg [15:0] b_reg = 0;
    
    // Управление записью:
    // SW[9] - выбор операнда (0 - A, 1 - B)
    // SW[10] - выбор части (0 - младшая, 1 - старшая)
    // KEY[0] - запись (по нажатию кнопки)
    
    // Сброс значений аргументов при нажатии KEY[1] и KEY[2]
    always @(negedge KEY[1]) begin
        a_reg <= 16'b0;
    end

    always @(negedge KEY[2]) begin
        b_reg <= 16'b0;
    end
    // Запись данных при нажатии KEY[0]
    always @(negedge KEY[0]) begin
        if (SW[9]) begin
            // Запись в операнд B
            if (SW[10]) b_reg[15:8] <= SW[7:0];
            else b_reg[7:0] <= SW[7:0];
        end else begin
            // Запись в операнд A
            if (SW[10]) a_reg[15:8] <= SW[7:0];
            else a_reg[7:0] <= SW[7:0];
        end
    end
    
    // Подключение 16-битного АЛУ
    wire [15:0] alu_result;
    wire alu_cout;
    
    alu16 alu_inst(
        .a(a_reg),
        .b(b_reg),
        .Cin(SW[8]),       // CarryIn (SW[8])
        .mode(SW[15]),      // Тип операции (SW[15])
        .sel(SW[14:11]),    // Код операции (SW[14:11])
        .result(alu_result),
        .Cout(alu_cout),
        .nBo(),            
        .nGo()            
    );

    assign LEDR[15:0] = alu_result;  // Результат на красных светодиодах
    assign LEDR[17:16] = 0;      // Неиспользуемые светодиоды выключены
    
    assign LEDG[0] = alu_cout;       // CarryOut на зеленый светодиод
    assign LEDG[8:1] = 0;         // Остальные зеленые светодиоды выключены

    hex_display disp0(.digit(alu_result[3:0]),   .seven_segments(HEX0));
    hex_display disp1(.digit(alu_result[7:4]),   .seven_segments(HEX1));
    hex_display disp2(.digit(alu_result[11:8]),  .seven_segments(HEX2));
    hex_display disp3(.digit(alu_result[15:12]), .seven_segments(HEX3));
    assign HEX4 = 8'b11111111;
    assign HEX5 = 8'b11111111;
    assign HEX6 = 8'b11111111;
    assign HEX7 = 8'b11111111;

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
