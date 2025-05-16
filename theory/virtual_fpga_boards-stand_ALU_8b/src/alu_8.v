module alu8(
    input [7:0] a, b,
    input Cin, mode,
    input [3:0] sel,
    output [7:0] result,
    output Cout, nBo, nGo
);

    wire [1:0] carry_ic;
    wire [1:0] nGG, nGP;
    wire [1:0] carry_local;
    wire [7:0] F_bar;

    // Обработка carry_in
    wire carry_in_internal = (mode == 1) ? 1'b0 : ((sel == 4'b0110) ? Cin : ~Cin);

    /* verilator lint_off PINMISSING */
    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : alu_gen
            alu_74181 alu (
                .C_in(i == 0 ? carry_in_internal : carry_ic[i-1]),  
                .Select(sel),
                .Mode(mode),
                .A_bar(a[4*i +: 4]),
                .B_bar(b[4*i +: 4]),
                .CP_bar(nGP[i]),
                .CG_bar(nGG[i]),
                .C_out(carry_local[i]),
                .F_bar(F_bar[4*i +: 4])
            );
            assign result[4*i +: 4] = 
            (sel == 4'b0001) ? ~F_bar[4*i +: 4] : F_bar[4*i +: 4];
        end
    endgenerate

    // Обработка carry_out
    wire carry_out_internal = (mode == 1) ? 1'b0 : ((sel == 4'b0110) ? carry_local[3] : ~carry_local[3]);
    assign Cout = carry_out_internal;

    cla_74182 cla(
        .Cn(carry_in_internal), 
        .nPB(nGP), 
        .nGB(nGG), 
        .PBo(nBo), 
        .GBo(nGo), 
        .Cnx(carry_ic[0]), 
        .Cny(carry_ic[1]), 
        .Cnz(carry_ic[2])
    );

endmodule