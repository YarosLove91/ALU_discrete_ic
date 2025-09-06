`define OPERATION_CLEAR      3'b000
`define OPERATION_B_MINUS_A  3'b001
`define OPERATION_A_MINUS_B  3'b010
`define OPERATION_A_PLUS_B   3'b011
`define OPERATION_A_XOR_B    3'b100
`define OPERATION_A_OR_B     3'b101
`define OPERATION_A_AND_B    3'b110
`define OPERATION_PRESENT    3'b111

module alu_74381 (
	input wire [3:0] A,
	input wire [3:0] B,
	input wire [2:0] S,
	input wire Cn,
	output reg [3:0] F,
	output wire P, G
	);

	reg [3:0] P_int;
	reg [3:0] G_int;

	assign P = ~(&P_int);
	assign G = ~(G_int[3] | (P_int[3] & G_int[2]) | (P_int[3] & P_int[2] & G_int[1]) | (P_int[3] & P_int[2] & P_int[1] & G_int[0]));

	always @ (*)begin
	case (S)
		`OPERATION_CLEAR:
		begin
			F = 0;
			P_int = 4'b1111;
			G_int = 4'b1111;
		end
		`OPERATION_B_MINUS_A:
		begin
			F = B + ~A + {3'b0,Cn};
			P_int = (~A) | B;
			G_int = (~A) & B;
		end
		`OPERATION_A_MINUS_B:
		begin
			F = ~B + A + {3'b0,Cn};
			P_int = A | ~B;
			G_int = A & ~B;
		end
		`OPERATION_A_PLUS_B:
		begin
			F = A + B + {3'b0,Cn};
			P_int = A | B;
			G_int = (A) & B;
		end
		`OPERATION_A_XOR_B:
		begin
			F = A ^ B;
			if(A == 0 & B == 4'b1111)	
			begin
				P_int = 0;
			end
		else
			P_int = A | B;
			G_int = (A) & B;
		end
		`OPERATION_A_OR_B:
		begin
			F = A | B;
			if((A == 4'b1111) & (B == 4'b1111))	
			begin
				P_int = 4'b1111;
			end
		else
			P_int = 4'b0000;
			G_int = 4'b0000;
		end
		`OPERATION_A_AND_B:
		begin
			F = A & B;
			if(((A == 4'b0000) & (B == 4'b0000)) || ((A == 4'b1111) & (B == 4'b0000)) )	
			begin
				P_int = 4'b1111;
				G_int = 4'b1111;
			end
			else if ((B == 4'b1111) & (A == 4'b0000))
			begin
				P_int = 4'b0000;
				G_int = 4'b0000;
			end
			else begin
				P_int = 4'b1111;
				G_int = 4'b0000;
			end
		end
		`OPERATION_PRESENT:
		begin
			F = 4'b1111;
			if((A == 4'b1111) & (B == 4'b1111))
			begin
				P_int = 4'b1111;
			end
			else
				P_int = 4'b0000;
				G_int = 4'b0000;
		end
		default:
			F = 4'b0000;
	endcase
	end

endmodule
