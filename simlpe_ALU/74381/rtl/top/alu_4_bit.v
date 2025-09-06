module alu_4_bit_with_flags_correct (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [2:0] S,
    input  wire       Cn,

    output wire [3:0] F,
    output wire       P,
    output wire       G,
    output wire       Co,
    output wire       Zero,
    output wire       Overflow,
    output wire       Negative
);

    // Внутренние сигналы
    wire [3:0] F0;
    wire P0, G0;
    wire Co_int;

    // Экземпляр 4-битного АЛУ 74381
    alu_74381 alu0 (
        .A(A[3:0]),
        .B(B[3:0]),
        .S(S),
        .Cn(Cn),
        .F(F0),
        .P(P0),
        .G(G0)
    );

    // Расчет переполнения
    wire overflow_plus = (!(A[3] ^ B[3])) & (B[3] ^ F0[3]);
    wire overflow_a_minus_b = (!(A[3] ^ ~B[3])) & (~B[3] ^ F0[3]);
    wire overflow_b_minus_a = (!(~A[3] ^ B[3])) & (B[3] ^ F0[3]);
    
    // Формирование выходных сигналов
    assign F = F0;
    assign P = P0;                          // Propagate
    assign G = G0;                          // Generate
    assign Co = ~G0 | (~P0 & Cn);           // Carry_OUT
    
    // Дополнительные флаги состояния
    assign Zero = (F0 == 4'b0000);          // Флаг нуля
    assign Negative = F0[3];                // Флаг отрицательного числа
    assign Overflow = (S == `OPERATION_A_PLUS_B)   ? overflow_plus :            // Переполнение
                     (S == `OPERATION_A_MINUS_B)  ? overflow_a_minus_b :
                     (S == `OPERATION_B_MINUS_A)  ? overflow_b_minus_a :
                     1'b0;

endmodule