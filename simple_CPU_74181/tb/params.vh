// ==================== ФАЙЛ ПАРАМЕТРОВ И КОНСТАНТ ====================
// params.v - Общие параметры и константы для проекта
`ifndef PARAMS_VH
`define PARAMS_VH

// ==================== ПАРАМЕТРЫ АЛУ ====================
// Разрядность данных
localparam DATA_WIDTH = 16;
localparam ADDR_WIDTH = 4;  // Для 16 регистров (2^4 = 16)

// ==================== CONTROL SIGNALS ====================
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


// ==================== ALU 74181 COMMANDS ====================
// Logical Operations (M = 1)
localparam [3:0] 
    OP_L_NOT_A          = 4'b0000,   // ~A
    OP_L_A_OR_B_NOT     = 4'b0001,   // ~(A | B)
    OP_L_NOT_A_AND_B    = 4'b0010,   // ~A & B
    OP_L_LOGIC_0        = 4'b0011,   // 0
    OP_L_NOT_A_AND_NOT_B= 4'b0100,   // ~(A & B)
    OP_L_NOT_B          = 4'b0101,   // ~B
    OP_L_XOR            = 4'b0110,   // A ^ B
    OP_L_A_AND_NOT_B    = 4'b0111,   // A & ~B
    OP_L_NOT_A_OR_B     = 4'b1000,   // ~A | B
    OP_L_XNOR           = 4'b1001,   // ~(A ^ B)
    OP_L_B              = 4'b1010,   // B
    OP_L_A_AND_B        = 4'b1011,   // A & B
    OP_L_LOGIC_1        = 4'b1100,   // 1
    OP_L_A_OR_NOT_B     = 4'b1101,   // A | ~B
    OP_L_A_OR_B         = 4'b1110,   // A | B
    OP_L_A              = 4'b1111;   // A

// Arithmetic Operations (M = 0)
localparam [3:0]
    OP_A_A_PLUS_CARRY               = 4'b0000, // A + carry
    OP_A_A_PLUS_B_PLUS_CARRY        = 4'b0001, // (A + B) + carry
    OP_A_A_PLUS_NOT_B_PLUS_CARRY    = 4'b0010, // (A + ~B) + carry
    OP_A_MINUS_1_PLUS_CARRY         = 4'b0011, // -1 + carry
    OP_A_A_PLUS_A_AND_NOT_B         = 4'b0100, // A + (A & ~B)
    OP_A_A_PLUS_B_PLUS_A_AND_NOT_B  = 4'b0101, // (A + B) + (A & ~B) + 1
    OP_A_A_MINUS_B_MINUS_CARRY      = 4'b0110, // A - B - carry
    OP_A_A_AND_NOT_B_MINUS_CARRY    = 4'b0111, // (A & ~B) - carry
    OP_A_A_PLUS_A_AND_B_PLUS_CARRY  = 4'b1000, // A + (A & B) + carry
    OP_A_A_PLUS_B                   = 4'b1001, // A + B
    OP_A_A_PLUS_NOT_B_PLUS_A_AND_B  = 4'b1010, // (A + ~B) + (A & B)
    OP_A_A_AND_B_MINUS_CARRY        = 4'b1011, // (A & B) - carry
    OP_A_A_PLUS_A_PLUS_CARRY        = 4'b1100, // A + A + carry
    OP_A_A_PLUS_B_PLUS_A_PLUS_1     = 4'b1101, // (A + B) + A + 1
    OP_A_A_PLUS_NOT_B_PLUS_A_PLUS_1 = 4'b1110, // (A + ~B) + A + 1
    OP_A_A_MINUS_1                  = 4'b1111; // A - 1


// ==================== ALIASES FOR COMMON OPERATIONS ====================
// Combined Operations
// TODO: Доделать
localparam [4:0]
    OP_A_PLUS_CARRY = (ALU_MODE_ARITHMETIC<<4),  OP_A_A_PLUS_CARRY


// ==================== REGISTER ADDRESSES ====================
localparam [2:0]
    REG_R0 = 3'd0,
    REG_R1 = 3'd1,
    REG_R2 = 3'd2,
    REG_R3 = 3'd3,
    REG_R4 = 3'd4,
    REG_R5 = 3'd5,
    REG_R6 = 3'd6,
    REG_R7 = 3'd7;

// ==================== ТЕСТОВЫЕ КОНСТАНТЫ ====================

// Тестовые значения для регистров
localparam TEST_VAL_1 = 16'h1234;
localparam TEST_VAL_2 = 16'h5678;
localparam TEST_VAL_3 = 16'h9ABC;
localparam TEST_VAL_4 = 16'hDEFF;

// Маски для различных cценариев жестко заданные

// localparam TEST_MASK_LOW_ONES  = 16'h00FF;
// localparam TEST_MASK_HIGH_ONES  = 16'hFF00;
// 
// localparam TEST_MASK_CHESS_EVENS = 16'hF0F0;
// localparam TEST_MASK_CHESS_ODDS = 16'h0F0F;
//
// localparam TEST_MASK_ONES_ODDS = 16'h5555;
// localparam TEST_MASK_ONES_EVENS = 16'hAAAA;


// Параметризованные маски
localparam TEST_MASK_ONES_LOW  = {{DATA_WIDTH/2{1'b0}}, {DATA_WIDTH/2{1'b1}}};  // 00FF для 16-bit
localparam TEST_MASK_ONES_HIGH = {{DATA_WIDTH/2{1'b1}}, {DATA_WIDTH/2{1'b0}}};  // FF00 для 16-bit
localparam TEST_MASK_ONES_QUARTER = {{3*DATA_WIDTH/4{1'b0}}, {DATA_WIDTH/4{1'b1}}}; // 000F для 16-bit

localparam TEST_MASK_CHESS_EVENS = {DATA_WIDTH/2{2'b10}};   // 10101010... 16'hAAAA;
localparam TEST_MASK_CHESS_ODDS  = {DATA_WIDTH/2{2'b01}};   // 01010101... 16'hAAAA;

localparam TEST_ZERO  = {DATA_WIDTH{1'b0}};  // 16'h0000
localparam TEST_ONES  = {DATA_WIDTH{1'b1}};  // 16'hFFFF

localparam INDIFFERENT_VAL = {DATA_WIDTH{1'bx}};
localparam INDIFFERENT_REG = 4'bXXXX;   // Для неиспользуемых регистров

// Дополнительные полезные константы
localparam TEST_ONE   = {{DATA_WIDTH-1{1'b0}}, 1'b1};  // 16'h0001
localparam TEST_MSB   = {1'b1, {DATA_WIDTH-1{1'b0}}};  // 16'h8000
localparam TEST_LSB   = TEST_ONE;


// Функция для получения имени регистра по адресу
function string get_reg_name;
    input [ADDR_WIDTH-1:0] addr;
    begin
        get_reg_name = $sformatf("REG_R%0h", addr);
    end
endfunction

    // Макросы для упрощения вызова execute_alu_operation
    `define ALU_REG(src1, src2, dst, op, mode, cin, name)  \
        execute_alu_operation(src1, src2, dst, op, mode, cin, B_SOURCE_REGISTER, INDIFFERENT_VAL, name)

    `define ALU_IMM(src1, dst, op, mode, cin, imm, name) \
        execute_alu_operation(src1, INDIFFERENT_REG, dst, op, mode, cin, B_SOURCE_IMMEDIATE, imm, name)

    // 
    `define ALU_M_REG(src1, src2, dst, op, cin, name)  \
        ALU_REG(src1, src2, dst, op, ALU_MODE_ARITHMETIC, cin, name)

    `define ALU_M_IMM(src1, dst, op, cin, imm, name) \
        execute_alu_operation(src1, INDIFFERENT_REG, dst, op, ALU_MODE_ARITHMETIC, cin, B_SOURCE_IMMEDIATE, imm, name)

    // Макросы для упрощения вызова execute_alu_operation
    `define ALU_L_REG(src1, src2, dst, op, cin, name)  \
        execute_alu_operation(src1, src2, dst, op, ALU_MODE_LOGIC, cin, B_SOURCE_REGISTER, INDIFFERENT_VAL, name)

    `define ALU_L_IMM(src1, dst, op, cin, imm, name) \
        execute_alu_operation(src1, INDIFFERENT_REG, dst, op, ALU_MODE_LOGIC, cin, B_SOURCE_IMMEDIATE, imm, name)

    // Макросы для проверки результатов
    `define CHECK(reg_addr, expected_value, test_name) \
        check_result(reg_addr, expected_value, 1'bx, 0, test_name)

    `define CHECK_COUT(reg_addr, expected_value, expected_cout, test_name) \
        check_result(reg_addr, expected_value, expected_cout, 1'b1, test_name)

    // Макрос для чтения регистра
    `define READ_REG(reg_addr, reg_value) \
        read_register(reg_addr, reg_value)

`endif // PARAMS_VH