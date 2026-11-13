module adder16(
    input [15:0] a, b,
    input Cin,
    output [15:0] sum,
    output Cout, nBo, nGo
);

    wire [2:0] carry_local;
    wire [3:0] unused_carry;
    wire [3:0] nGG;
    wire [3:0] nGP;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : fa_gen
            fulladd4 fa(
                .Cin(i == 0 ? Cin : carry_local[i-1]), 
                .a(a[4*i +: 4]), 
                .b(b[4*i +: 4]), 
                .sum(sum[4*i +: 4]), 
                .nGP(nGP[i]), 
                .nGG(nGG[i]),
                .Cout(unused_carry[i])
            );
        end
    endgenerate

    cla_74182 cla(
        .Cn(Cin), 
        .nPB(nGP), 
        .nGB(nGG), 
        .PBo(nBo), 
        .GBo(nGo), 
        .Cnx(carry_local[0]), 
        .Cny(carry_local[1]), 
        .Cnz(carry_local[2])
    );

    assign Cout = unused_carry[3];

endmodule

/*
module adder16(
    input [15:0] a, b,
    input Cin,
    output [15:0] sum,
    output Cout, nBo, nGo
);
    wire [2:0] carry_local;
    wire [3:0] nGG;
    wire [3:0] nGP;

    fulladd4 fa0(
        .Cin(Cin), 
        .a(a[3:0]), 
        .b(b[3:0]), 
        .sum(sum[3:0]), 
        .nGP(nGP[0]), 
        .nGG(nGG[0])
        );

    fulladd4 fa1(
        .Cin(carry_local[0]), 
        .a(a[7:4]), 
        .b(b[7:4]), 
        .sum(sum[7:4]),  
        .nGP(nGP[1]), 
        .nGG(nGG[1]));


    fulladd4 fa2(
        .Cin(carry_local[1]), 
        .a(a[11:8]), 
        .b(b[11:8]), 
        .sum(sum[11:8]), 
        .nGP(nGP[2]), 
        .nGG(nGG[2]));

    fulladd4 fa3(
        .Cin(carry_local[2]), 
        .a(a[15:12]), 
        .b(b[15:12]), 
        .sum(sum[15:12]), 
        .nGP(nGP[3]), 
        .nGG(nGG[3]),
        .Cout(Cout)
        );

    cla_74182b cla(.Cn(Cin), 
                   .nPB(nGP), 
                   .nGB(nGG), 
                   .PBo(nBo), 
                   .GBo(nGo), 
                   
                   .Cnx(carry_local[0]), 
                   .Cny(carry_local[1]), 
                   .Cnz(carry_local[2]));

endmodule
*/

