module fulladd4(
    input Cin,
    input [3:0] a, b,
    output [3:0] sum,
    output Cout,
    output wire nGP, nGG
);
    wire [3:0] p, g;
    /* verilator lint_off UNOPTFLAT */
    wire [4:0] c; // Размерность [4:0] для включения Cin

    assign p = a ^ b;
    assign g = a & b;

    assign c[0] = Cin;
    genvar i;
        generate
            for (i = 0; i < 4; i = i + 1) begin : carry_gen
                assign c[i+1] = g[i] | (p[i] & c[i]);
            end
        endgenerate

    assign sum = p ^ c[3:0];
    assign Cout = c[4];

    // Групповые сигналы Propagate и Generate для всего блока
    assign nGP = ~(&p);
    assign nGG = ~(g[3] | (p[3] & g[2]) | (p[3:2] & g[1]) | (&p[3:1] & g[0]));
endmodule