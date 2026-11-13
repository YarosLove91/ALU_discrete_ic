module alu32(
    input [31:0] a, b,
    input Cin, mode,
    input [3:0] sel,
    output [31:0] result,
    output Cout, nBo, nGo
);

    wire [3:0] ic_carry;
    wire [7:0] nGG,nGP;
    wire [7:0] carry_local;

    /* verilator lint_off PINMISSING */
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : alu_gen
            alu_74181 alu (
            .C_in(i == 0 ? Cin : (i % 2 == 1) ? carry_local[i-1] : ic_carry[(i/2)-1]),
            .Select(sel),
            .Mode(mode),
            .A_bar(a[4*i +: 4]),
            .B_bar(b[4*i +: 4]),
            .CP_bar(nGP[i]),
            .CG_bar(nGG[i]),
            .C_out(carry_local[i]),
            .F_bar(result[4*i +: 4]));
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

    assign nBo = &nGP;
    assign nGo = (&nGG) |
                 (&nGG[7:1] & nGP[1]) |
                 (&nGG[7:2] & nGP[2]) |
                 (&nGG[7:3] & nGP[3]) |
                 (&nGG[7:4] & nGP[4]) |
                 (&nGG[7:5] & nGP[5]) |
                 (&nGG[7:6] & nGP[6]) |
                 (nGG[7] & nGP[7]);
endmodule

//.Cin(i == 0 ? Cin : (i % 2 == 1) ? carry_local[i/2] : ic_carry[(i/2)-1]),		// работает