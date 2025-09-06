module fulladd8(
    input Cin,
    input [7:0] a, b,
    output [7:0] sum,
    output Cout,
    output wire [1:0]nGP, nGG
);
    wire carry_templ;
    // Создаем два 4-битных полных сумматора
    fulladd4 FA_lo(
                .Cin(Cin), 
                .a(a[3:0]), 
                .b(b[3:0]), 
                .sum(sum[3:0]),
                .Cout(carry_templ), 
                .nGP(nGP[0]), 
                .nGG(nGG[0]));
                
    fulladd4 FA_hi( 
                .Cin(carry_templ), 
                .a(a[7:4]), 
                .b(b[7:4]), 
                .sum(sum[7:4]), 
                .Cout(Cout), 
                .nGP(nGP[1]),
                .nGG(nGG[1]));
endmodule