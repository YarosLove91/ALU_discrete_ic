`timescale 1ns / 1ps

module testbench;
    reg [7:0] G;
    reg [7:0] P;
    reg Cin;
    wire [3:0] Cout;
    wire Cn_8, Cn_16, Cn_24, Cn_32;

    carry32_p74882 uut_p (
        .G(G),
        .P(P),
        .Cin(Cin),
        .Cout(Cout)
    );

    reg [31:0] A, B;
    reg nCin;
    reg [7:0] nP, nG;

    cla32_n74882 uut_n (
        .nP(nP),
        .nG(nG),
        .Cin(nCin),
        .Cn_8(Cn_8),
        .Cn_16(Cn_16),
        .Cn_24(Cn_24),
        .Cn_32(Cn_32)
    );

    integer passed_tests = 0;
    integer failed_tests = 0;
    integer k, t, j;
    reg c;
    reg [3:0] expected;
    reg [3:0] an, bn, p, g;
    reg [3:0] cg_int;
    reg [32:0] r;
    reg [3:0] exp_n;
    reg [8:0] r8;
    reg [16:0] r16;
    reg [24:0] r24;

    task check_p;
        begin
            #1;
            c = Cin;
            for (k = 0; k < 8; k = k + 1) begin
                c = G[k] | (P[k] & c);
                if (k == 1) expected[0] = c;
                if (k == 3) expected[1] = c;
                if (k == 5) expected[2] = c;
                if (k == 7) expected[3] = c;
            end
            if (Cout === expected) begin
                passed_tests = passed_tests + 1;
            end else begin
                failed_tests = failed_tests + 1;
                $display("FAIL P: G=%b P=%b Cin=%b Cout=%b exp=%b",
                         G, P, Cin, Cout, expected);
            end
        end
    endtask

    task check_n;
        begin
            for (j = 0; j < 8; j = j + 1) begin
                an = A[4*j +: 4]; bn = B[4*j +: 4];
                g = an & bn; p = an | bn;
                nP[j] = |g;
                cg_int[0] = (&~g[3:1]) & ~p[0];
                cg_int[1] = (&~g[3:2]) & ~p[1];
                cg_int[2] = ~g[3] & ~p[2];
                cg_int[3] = ~p[3];
                nG[j] = ~(|cg_int);
            end
            nCin = ~Cin;
            #1;
            r8 = {1'b0, A[7:0]} + {1'b0, B[7:0]} + Cin;
            r16 = {1'b0, A[15:0]} + {1'b0, B[15:0]} + Cin;
            r24 = {1'b0, A[23:0]} + {1'b0, B[23:0]} + Cin;
            r = {1'b0, A} + {1'b0, B} + Cin;
            exp_n = ~{r[32], r24[24], r16[16], r8[8]};
            if ({Cn_32, Cn_24, Cn_16, Cn_8} === exp_n) begin
                passed_tests = passed_tests + 1;
            end else begin
                failed_tests = failed_tests + 1;
                $display("FAIL N: A=%h B=%h Cin=%b got=%b exp=%b",
                         A, B, Cin, {Cn_32, Cn_24, Cn_16, Cn_8}, exp_n);
            end
        end
    endtask

    initial begin
        // positive-logic module tests
        G = 8'h00; P = 8'h00; Cin = 1'b0; check_p;
        G = 8'h00; P = 8'h00; Cin = 1'b1; check_p;
        G = 8'h00; P = 8'hFF; Cin = 1'b0; check_p;
        G = 8'h00; P = 8'hFF; Cin = 1'b1; check_p;
        G = 8'hFF; P = 8'h00; Cin = 1'b0; check_p;
        G = 8'hFF; P = 8'hFF; Cin = 1'b1; check_p;
        for (t = 0; t < 8; t = t + 1) begin
            G = 8'h01 << t; P = 8'h00; Cin = 1'b0; check_p;
            G = 8'h00; P = 8'h01 << t; Cin = 1'b1; check_p;
        end
        for (t = 0; t < 2000; t = t + 1) begin
            G = $random; P = $random; Cin = $random & 1; check_p;
        end

        // negative-logic module tests (74181 model convention)
        A = 32'h0; B = 32'h0; Cin = 0; check_n;
        A = 32'hFFFFFFFF; B = 32'h0; Cin = 1; check_n;
        A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; Cin = 0; check_n;
        A = 32'h0FFFFFFF; B = 32'h00000001; Cin = 0; check_n;
        A = 32'h00FFFFFF; B = 32'h00000001; Cin = 0; check_n;
        A = 32'h0000FFFF; B = 32'h00000001; Cin = 0; check_n;
        A = 32'h000000FF; B = 32'h00000001; Cin = 0; check_n;
        A = 32'h0000000F; B = 32'h00000001; Cin = 0; check_n;
        for (t = 0; t < 2000; t = t + 1) begin
            A = $random; B = $random; Cin = $random & 1; check_n;
        end

        $display("Количество пройденных тестов: %0d", passed_tests);
        $display("Количество не пройденных тестов: %0d", failed_tests);
        if (failed_tests == 0)
            $display("TESTS PASSED");
        else
            $fatal(1, "TESTS FAILED");
        $finish;
    end
endmodule
