module alu_16_bit (
	input wire [15:0] A,
	input wire [15:0] B,
	input wire [2:0] S,
	input wire Cn,
	output wire [15:0] F,
	// output wire P, G
	output wire Co
	);

	wire [3:0] F0, F1, F2, F3;
	wire P0, P1, P2, P3;
	wire G0, G1, G2, G3;
	wire Cn1, Cn2, Cn3;

	alu_74381 alu0 (
				.A(A[3:0]),
				.B(B[3:0]),
				.S(S),
				.Cn(Cn),
				.F(F0),
				.P(P0),
				.G(G0)
				);

	alu_74381 alu1 (
				.A(A[7:4]),
				.B(B[7:4]),
				.S(S),
				.Cn(Cn1),
				.F(F1),
				.P(P1),
				.G(G1)
				);

	alu_74381 alu2 (
				.A(A[11:8]),
				.B(B[11:8]),
				.S(S),
				.Cn(Cn2),
				.F(F2),
				.P(P2),
				.G(G2)
				);

	alu_74381 alu3 (
				.A(A[15:12]),
				.B(B[15:12]),
				.S(S),
				.Cn(Cn3),
				.F(F3),
				.P(P3),
				.G(G3)
				);

	assign F = {F3, F2, F1, F0};

	assign Cn1 = ~G0 | (~P0 & Cn);
	assign Cn2 = ~G1 | (~P1 & Cn1);
	assign Cn3 = ~G2 | (~P2 & Cn2);
	assign Co =  ~G3 | (~P3 & Cn3);

  //   assign P = P3 & P2 & P1 & P0;
  //   assign G = G3 | (P3 & G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0);

endmodule


/*
module alu_16_bit #(
    parameter WIDTH = 16,        // Разрядность АЛУ
    parameter SLICE_WIDTH = 4    // Разрядность одного модуля
) (
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [2:0]       S,
    input  wire             Cn,
    output wire [WIDTH-1:0] F,
    output wire             Co
);

    localparam NUM_SLICES = WIDTH / SLICE_WIDTH;
    
    // Внутренние сигналы
    wire [SLICE_WIDTH-1:0] F_slice [NUM_SLICES-1:0];
    wire                   P_slice [NUM_SLICES-1:0];
    wire                   G_slice [NUM_SLICES-1:0];
    wire                   Cn_slice [NUM_SLICES:0];
    
    assign Cn_slice[0] = Cn;
    assign Co = Cn_slice[NUM_SLICES];

    // Подключение входных данных к срезам
    genvar i;
    generate
        for (i = 0; i < NUM_SLICES; i = i + 1) begin : alu_slices
            // Подключение входных данных
            wire [SLICE_WIDTH-1:0] A_current = A[i*SLICE_WIDTH +: SLICE_WIDTH];
            wire [SLICE_WIDTH-1:0] B_current = B[i*SLICE_WIDTH +: SLICE_WIDTH];
            
            // Экземпляр 4-битного АЛУ
            alu_74381 alu_inst (
                .A(A_current),
                .B(B_current),
                .S(S),
                .Cn(Cn_slice[i]),
                .F(F_slice[i]),
                .P(P_slice[i]),
                .G(G_slice[i])
            );
            
            // Формирование переноса для следующего среза
            assign Cn_slice[i+1] = ~G_slice[i] | (~P_slice[i] & Cn_slice[i]);
        end
    endgenerate

    // Формирование выходного результата
    genvar j;
    for (j = 0; j < NUM_SLICES; j = j + 1) begin : output_assign
        assign F[j*SLICE_WIDTH +: SLICE_WIDTH] = F_slice[j];
    end

endmodule
*/