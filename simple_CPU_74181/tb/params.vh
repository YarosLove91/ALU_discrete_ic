// ==================== ФАЙЛ ПАРАМЕТРОВ И КОНСТАНТ ====================
// params.v - Общие параметры и константы для проекта

// Разрядность данных
localparam DATA_WIDTH = 16;
localparam ADDR_WIDTH = 4;  // Для 16 регистров (2^4 = 16)

// ==================== ПАРАМЕТРЫ АЛУ ====================

// Режимы работы АЛУ
localparam ALU_MODE_ARITHMETIC = 1'b0;  // Арифметический режим
localparam ALU_MODE_LOGIC      = 1'b1;  // Логический режим

// Источник операнда B
localparam B_SOURCE_REGISTER  = 1'b0;  // Берем B из регистрового файла
localparam B_SOURCE_IMMEDIATE = 1'b1;  // Берем B из непосредственного значения

// Управление переносом
localparam CARRY_IN_DISABLED = 1'b1;  // Без переноса
localparam CARRY_IN_ENABLED  = 1'b0;  // С переносом

localparam CARRY_OUT_DISABLED = 1'b1;  // Без переноса
localparam CARRY_OUT_ENABLED  = 1'b0;  // С переносом


// Коды операций АЛУ
localparam OP_ADD      = 4'b1001; // Сложение A + B
localparam OP_SUB      = 4'b0110; // Вычитание A - B
localparam OP_AND      = 4'b1011; // Логическое И
localparam OP_OR       = 4'b1110; // Логическое ИЛИ
localparam OP_XOR      = 4'b0110; // Логическое XOR
localparam OP_NOT      = 4'b0000; // Логическое НЕ
localparam OP_INC      = 4'b1100; // Инкремент/удвоение
localparam OP_DEC      = 4'b0011; // Декремент

// ==================== КОДЫ РЕГИСТРОВ ====================

// Номера регистров (для удобства)
localparam REG_R0  = 3'd0;
localparam REG_R1  = 3'd1;
localparam REG_R2  = 3'd2;
localparam REG_R3  = 3'd3;
localparam REG_R4  = 3'd4;
localparam REG_R5  = 3'd5;
localparam REG_R6  = 3'd6;
localparam REG_R7  = 3'd7;
localparam REG_R8  = 4'd8;
localparam REG_R9  = 4'd9;
localparam REG_R10 = 4'd10;
localparam REG_R11 = 4'd11;
localparam REG_R12 = 4'd12;
localparam REG_R13 = 4'd13;
localparam REG_R14 = 4'd14;
localparam REG_R15 = 4'd15;

// ==================== ТЕСТОВЫЕ КОНСТАНТЫ ====================

// Тестовые значения для регистров
localparam TEST_VAL_1 = 16'h1234;
localparam TEST_VAL_2 = 16'h5678;
localparam TEST_VAL_3 = 16'h9ABC;
localparam TEST_VAL_4 = 16'hDEFF;

// Маски для различных битовых сценариев
localparam TEST_MASK_LOW_ONES  = 16'h00FF;
localparam TEST_MASK_HIGH_ONES  = 16'hFF00;

localparam TEST_MASK_CHESS_EVENS = 16'hF0F0;
localparam TEST_MASK_CHESS_ODDS = 16'h0F0F;

localparam TEST_MASK_ONES_ODDS = 16'h5555;
localparam TEST_MASK_ONES_EVENS = 16'hAAAA;

localparam TEST_ZERO  = 16'h0000;
localparam TEST_ONES  = 16'hFFFF;

