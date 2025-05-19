// Определение макросов
`define CHECK_VALUE(variable, expected, test_name) \
    if (variable === expected) begin \
        $display("Test %s: Success", test_name); \
        success_count = success_count + 1; \
    end else begin \
        $display("Test %s: Failure - Data: %b (Expected: %b)", test_name, variable, expected); \
        failure_count = failure_count + 1; \
    end

`define SET_DATA_AND_CHECK(value, test_name, expected, reg_to_check) \
    PB = value; #10; `CHECK_VALUE(reg_to_check, expected, test_name);

// ####################################################################3

`define TEST_GB_PB_COMBINATIONS(gb_pattern, pb_pattern, expected_value, test_name) \
    GB = gb_pattern; PB = pb_pattern; Cn = 0; #10; \
    if (GBo === expected_value) \
        $display("%s: Success", test_name); \
    else \
        $display("%s: Failure - G: %b (Expected: %b)", test_name, GBo, expected_value);


module tb_Circuit74182b;
    reg [3:0] PB, GB;
    reg Cn;
    wire PBo, GBo, Cnx, Cny, Cnz;


    reg failure_stat = 1'b0;
    reg [63:0]string_state = "Init";
    // Инстанцирование тестируемого модуля
    cla_ic_74182b uut (
        .PB(PB),
        .GB(GB),
        .Cn(Cn),
        .PBo(PBo),
        .GBo(GBo),
        .Cnx(Cnx),
        .Cny(Cny),
        .Cnz(Cnz)
    );
    
    integer success_count, failure_count;
    reg [3:0] DATA;

    initial begin
    integer i;
    
     // Настройка VCD
    $dumpfile("tb_74182.vcd");
    $dumpvars(0, tb_Circuit74182b);
#10
    string_state = "Testing P";
    $display("Testing P");

    `SET_DATA_AND_CHECK(4'b0000, "Test 1_1", 1'b0, PBo)
    `SET_DATA_AND_CHECK(4'b0001, "Test 1_2", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b0010, "Test 1_3", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b0011, "Test 1_4", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b0100, "Test 1_5", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b0101, "Test 1_6", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b0110, "Test 1_7", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b0111, "Test 1_8", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1000, "Test 1_9", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1001, "Test 1_10", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1010, "Test 1_11", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1011, "Test 1_12", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1100, "Test 1_13", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1101, "Test 1_14", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1110, "Test 1_15", 1'b1, PBo)
    `SET_DATA_AND_CHECK(4'b1111, "Test 1_16", 1'b1, PBo)
#10
    string_state = "Testing G";
    $display("Testing G");
    Cn = 0;

    // Основные комбинации
    // 0XXX XXXX
    GB = 4'b0xxx; PB = 4'bxxxx; Cn = 0;
#10;
    if (GBo === 0)
        $display("Test 2_1: Success");
    else
        $display("Test 2_1: Failure - G: %b (Expected: 0)", GBo);
    // X0XX 0XX
    GB = 4'bx0xx; PB = 4'b0xxx; Cn = 0;
#10;
    if (GBo === 0)
        $display("Test 2_2: Success");
    else
        $display("Test 2_2: Failure - G: %b (Expected: 0)", GBo);

        // XX0X 000
        GB=4'bxx0x; PB=4'b000x; Cn=0;
#10;
    if (GBo === 0)
        $display("Test 2_3: Success");
    else
        $display("Test 2_3: Failure - G: %b (Expected: 0)", GBo);

        // XXX0 000
    GB = 4'bxxx0; PB = 4'b000x; Cn = 0;
#10;
    if (GBo === 0)
        $display("Test 2_4: Success");
    else
        $display("Test 2_4: Failure - G: %b (Expected: 0)", GBo);
    
// Все остальные комбинации
    for (i = 0; i < 128; i = i + 1) begin
        GB = i[6:3];
        PB = {i[2:0], 1'bx};
        failure_stat = 0;
    $display("Iter = %d, Inputs: GB = %b, PB = %b", i, GB, PB);

    // Проверка условий для G = 0
    if ((GB[3] === 0) || 
        (GB[2] === 0 && PB[3] === 0) || 
        (GB[1] === 0 && PB[3:1] === 3'b000) || 
        (GB[0] === 0 && PB[3:1] === 3'b000)) begin
        #20;
        if (GBo === 0) 
            $display("Test 2_%0d: Success - G: %b (Expected: 0)", i, GBo);
        else begin
            $display("Test 2_%0d: Failure - G: %b (Expected: 0)", i, GBo);
            failure_stat = 1;
        end
    end
    // Все остальные комбинации для G = 1
    else begin
        #20;
        if (GBo === 1) begin   
            $display("Test 2_%0d: Success - G: %b (Expected: 1)", i, GBo);
            failure_stat = 1;
        end else
            $display("Test 2_%0d: Failure - G: %b (Expected: 1)", i, GBo);
    end
end
    string_state = "Testing Cnx";
    // Тесты для CNX
    $display("Testing Cnx");
    // Комбинации, где Cnx должно быть 1
    {GB[0], PB[0], Cn} = 3'b0xx;  #10; $display("Test 3_1: Cnx: %b (Expected: 1)", Cnx);

    
    `SET_DATA_AND_CHECK(4'b1111, "Test 1_16", 1'b1, PBo)
    
    {GB[0], PB[0], Cn} = 3'b000; #10; $display("Test 3_2: Cnx: %b (Expected: 1)", Cnx);
    {GB[0], PB[0], Cn} = 3'b001; #10; $display("Test 3_3: Cnx: %b (Expected: 1)", Cnx);
    {GB[0], PB[0], Cn} = 3'b010; #10; $display("Test 3_4: Cnx: %b (Expected: 1)", Cnx);
    {GB[0], PB[0], Cn} = 3'b011; #10; $display("Test 3_5: Cnx: %b (Expected: 1)", Cnx);

    {GB[0], PB[0], Cn} = 3'bx01; #10; $display("Test 3_6: Cnx: %b (Expected: 1)", Cnx);
    {GB[0], PB[0], Cn} = 3'b001; #10; $display("Test 3_7: Cnx: %b (Expected: 1)", Cnx);
    {GB[0], PB[0], Cn} = 3'b101; #10; $display("Test 3_8: Cnx: %b (Expected: 1)", Cnx);

    // Комбинации, где Cnx должно быть 0
    {GB[0], PB[0], Cn} = 3'b000; #10; $display("Test 3_8: Cnx: %b (Expected: 0)", Cnx);
    {GB[0], PB[0], Cn} = 3'b100; #10; $display("Test 3_8: Cnx: %b (Expected: 0)", Cnx);
    {GB[0], PB[0], Cn} = 3'b110; #10; $display("Test 3_9: Cnx: %b (Expected: 0)", Cnx);
    {GB[0], PB[0], Cn} = 3'b111; #10; $display("Test 3_10: Cnx: %b (Expected: 0)", Cnx);

    
/*

// Тесты для Cnx
for (i = 0; i < 8; i = i + 1) begin
    // Установка входных значений для текущей итерации
    {GB[0], PB[0], Cn} = i;
    
    // Пауза для стабилизации сигналов
    #10;
    
    // Вывод текущих входных значений
    $display("Iter = %d, Inputs: GB = %b, PB = %b, Cn = %b", i, GB[0], PB[0], Cn);

    // Использование casex для проверки Cnx
    casex ({GB[0], PB[0], Cn})
        3'b0xx: $display("Cnx: %b (Expected: 1) | GB = %b, PB = %b, Cn = %b", Cnx, GB[0], PB[0], Cn);
        3'bx01: $display("Cnx: %b (Expected: 1) | GB = %b, PB = %b, Cn = %b", Cnx, GB[0], PB[0], Cn);
        default: $display("Cnx: %b (Expected: 0) | GB = %b, PB = %b, Cn = %b", Cnx, GB[0], PB[0], Cn);
    endcase
end
*/



#10
    // Тесты для CNY
    string_state = "Testing CNY";
    $display("Testing CNY");
    {GB[1:0], PB[1:0], Cn} = 5'b00XXX; #10; $display("Test 4_1: CNY: %b (Expected: 1)", Cny);
    {GB[1:0], PB[1:0], Cn} = 5'bX00XX; #10; $display("Test 4_2: CNY: %b (Expected: 1)", Cny);
    {GB[1:0], PB[1:0], Cn} = 5'bXX001; #10; $display("Test 4_3: CNY: %b (Expected: 1)", Cny);
    // Все остальные комбинации, где CNY должно быть 0

    // {GB[1:0], PB[1:0], Cn} = 5'b01000; #10; $display("Test 4_4: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b01001; #10; $display("Test 4_5: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b01010; #10; $display("Test 4_6: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b01011; #10; $display("Test 4_7: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b01100; #10; $display("Test 4_8: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b01101; #10; $display("Test 4_9: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b01110; #10; $display("Test 4_10: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b01111; #10; $display("Test 4_11: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10000; #10; $display("Test 4_12: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10001; #10; $display("Test 4_13: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10010; #10; $display("Test 4_14: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10011; #10; $display("Test 4_15: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10100; #10; $display("Test 4_16: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10101; #10; $display("Test 4_17: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10110; #10; $display("Test 4_18: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b10111; #10; $display("Test 4_19: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11000; #10; $display("Test 4_20: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11001; #10; $display("Test 4_21: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11010; #10; $display("Test 4_22: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11011; #10; $display("Test 4_23: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11100; #10; $display("Test 4_24: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11101; #10; $display("Test 4_25: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11110; #10; $display("Test 4_26: CNY: %b (Expected: 0)", Cny);
    // {GB[1:0], PB[1:0], Cn} = 5'b11111; #10; $display("Test 4_27: CNY: %b (Expected: 0)", Cny);


for (i = 0; i < 32; i = i + 1) begin
        Cn = i[4];
        GB = i[3:2];
        PB = i[1:0];
        failure_stat = 0;

    $display("Iter = %d, Inputs:  Cn = %b, GB = %b, PB = %b", i, Cn, GB, PB);
    #10;
    if ((GB[1:0] == 2'b00) || (PB[1:0] == 2'b00) || (Cn == 1'b1)) begin
        if (Cny === 1)
            $display("Test 4_%0d: Success - CNY: %b (Expected: 1)", i, Cny);
        else
            $display("Test 4_%0d: Failure - CNY: %b (Expected: 1)", i, Cny);
    end else begin
        if (Cny === 0)
            $display("Test 4_%0d: Success - CNY: %b (Expected: 0)", i, Cny);
        else
            $display("Test 4_%0d: Failure - CNY: %b (Expected: 0)", i, Cny);
    end
end


// #10
//     // Тесты для GBo
//     $display("Testing GBo");
//     {GB, PB} = 7'b000XXXX; #10; $display("GBo: %b (Expected: 0)", GBo);
//     {GB, PB} = 7'bX00XXXX; #10; $display("GBo: %b (Expected: 0)", GBo);
//     {GB, PB} = 7'bXX00XXX; #10; $display("GBo: %b (Expected: 0)", GBo);
//     {GB, PB} = 7'bXXX00XX; #10; $display("GBo: %b (Expected: 0)", GBo);
//     {GB, PB} = 7'b1111111; #10; $display("GBo: %b (Expected: 1)", GBo);
// #10
//     // Тесты для PBo
//     $display("Testing PBo");
//     PB = 4'b0000; #10; $display("PBo: %b (Expected: 0)", PBo);
//     PB = 4'b1111; #10; $display("PBo: %b (Expected: 1)", PBo);

    $finish;
    end
endmodule

// Входы 	Выход
// G3 	G2 	G1 	G0 	P3 	P2 	P1 	G
// 0 	X 	X 	X 	X 	X 	X 	0
// X 	0 	X 	X 	0 	X 	X 	0
// X 	X 	0 	X 	0 	0 	0 	0
// X 	X 	X 	0 	0 	0 	0 	0
// Все остальные комбинации 	1


// Входы 	Выход
// G3 	G2 	G1 	G0 	P3 	P2 	P1 	G
// 0 	X 	X 	X 	X 	X 	X 	0
// X 	0 	X 	X 	0 	X 	X 	0
// X 	X 	0 	X 	0 	0 	0 	0
// X 	X 	X 	0 	0 	0 	0 	0
// Все остальные комбинации 	1


// Входы 	Выход
// G1 	G0 	P1 	P0 	Cn 	Cn+y
// 0 	X 	X 	X 	X 	1
// X 	0 	0 	X 	X 	1
// X 	X 	0 	0 	1 	1
// Все остальные комбинации 	0


// Входы 	Выход
// G0 	P0 	Cn 	Cn+x
// 0 	X 	X 	1
// X 	0 	1 	1
// Все остальные комбинации 	0


// Входы 	Выход
// P3 	P2 	P1 	P0 	P
// 0 	0 	0 	0 	0
// Все остальные комбинации 	1