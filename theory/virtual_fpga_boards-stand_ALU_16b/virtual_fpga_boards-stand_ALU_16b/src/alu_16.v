module alu16(
    input [15:0] a, b,
    input Cin, mode,
    input [3:0] sel,
    output [15:0] result,
    output Cout, nBo, nGo
);

    wire [1:0] ic_carry;
    wire [3:0] nGG, nGP;
    wire [3:0] carry_local;
    wire [15:0] F_bar;

    // Обработка carry_in
    wire carry_in_internal = (mode == 1) ? 1'b0 : ((sel == 4'b0110) ? Cin : ~Cin);

    /* verilator lint_off PINMISSING */
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : alu_gen
            alu_74181 alu (
                .C_in(i == 0 ? carry_in_internal : (i % 2 == 1) ? carry_local[i-1] : ic_carry[(i/2)-1]), 
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

    cla32_n74882 carry16 (
        .nP(nGP), 
        .nG(nGG), 
        .Cin(carry_in_internal), 
        .Cn_8(ic_carry[0]), 
        .Cn_16(ic_carry[1]), 
        .Cn_24(),            
        .Cn_32()             
    );

    // Обработка carry_out
    wire carry_out_internal = (mode == 1) ? 1'b0 : ((sel == 4'b0110) ? ic_carry[1] : ~ic_carry[1]);
    assign Cout = carry_out_internal;

endmodule
