module alu16(
    input [15:0] a, b,
    input Cin, mode,
    input [3:0] sel,
    output [15:0] result,
    output Cout, nBo, nGo
);

    wire [2:0] carry_ic;
    wire [3:0] nGG,nGP;
    wire [3:0] carry_local;

    /* verilator lint_off PINMISSING */
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : alu_gen
            alu_74181 alu (
                .C_in(i == 0 ? Cin : carry_ic[i-1]),  
                .Select(sel),
                .Mode(mode),
                .A_bar(a[4*i +: 4]),
                .B_bar(b[4*i +: 4]),
                .CP_bar(nGP[i]),
                .CG_bar(nGG[i]),
                .C_out(carry_local[i]),
                .F_bar(result[4*i +: 4])
            );
        end
    endgenerate

    assign Cout = carry_local[3];
	
    cla_74182 cla(
        .Cn(Cin), 
        .nPB(nGP), 
        .nGB(nGG), 
        .PBo(nBo), 
        .GBo(nGo), 
        .Cnx(carry_ic[0]), 
        .Cny(carry_ic[1]), 
        .Cnz(carry_ic[2])
    );

endmodule