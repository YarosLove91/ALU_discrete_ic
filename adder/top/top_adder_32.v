module adder32(
    input [31:0] a, b,
    input Cin,
    output [31:0] sum,
    output Cout
);

    wire [3:0] ic_carry, unused_carry;
    wire [7:0] carry_local, nGG, nGP;
		
    genvar i;
    generate

        for (i = 0; i < 8; i = i + 1) begin : fa_gen
        fulladd4 fa(
        //.Cin(i == 0 ? Cin : (i % 2 == 1) ? unused_carry[i/2] : ic_carry[i/2-1]),		// работает

        .Cin(i == 0 ? Cin : (i % 2 == 1) ? carry_local[i-1] : ic_carry[(i/2)-1]),  
        .a(a[4*i +: 4]), 
        .b(b[4*i +: 4]), 
        .sum(sum[4*i +: 4]), 
        .nGP(nGP[i]), 
        .nGG(nGG[i]),
        .Cout(carry_local[i])
        );
        end
    endgenerate
	 
    cla32_n74882 carry32 (
        .nP(nGP),      // Пропускные сигналы
        .nG(nGG),      // Генерирующие сигналы
        .Cin(Cin),           // Входной перенос
        .Cn_8(ic_carry[0]), 
        .Cn_16(ic_carry[1]), 
        .Cn_24(ic_carry[2]), 
        .Cn_32(ic_carry[3])    // Выходные переносы
    );
    assign Cout = ic_carry[3];
endmodule

//.Cin(i == 0 ? Cin : (i % 2 == 1) ? carry_local[i/2] : ic_carry[(i/2)-1]),		// работает