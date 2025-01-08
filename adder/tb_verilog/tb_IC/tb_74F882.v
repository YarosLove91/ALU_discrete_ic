module testbench;
    reg [7:0] G;
    reg [7:0] P;
    reg Cin;
    wire [3:0] Cout;

    carry32_74882 uut (
        .G(G),
        .P(P),
        .Cin(Cin),
        .Cout(Cout)
    );

    integer passed_tests = 0;
    integer failed_tests = 0;

    initial begin
        // Тестирование таблицы истинности для CarryLookaheadUnit

        // Тест 1: G7 = L, все остальные входы - X
        G = 8'b0XXXXXXX;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 1 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 1 не пройден");
            failed_tests = failed_tests + 1;
        end

        // Тест 2: G7 = X, G6 = L, все остальные входы - X
        G = 8'bX0XXXXXX;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 2 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 2 не пройден");
            failed_tests = failed_tests + 1;
        end

        // Тест 3: G7 = X, G6 = X, G5 = L, все остальные входы - X
        G = 8'bXX0XXXXX;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 3 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 3 не пройден");
            failed_tests = failed_tests + 1;
        end

        // Тест 4: G7 = X, G6 = X, G5 = X, G4 = L, все остальные входы - X
        G = 8'bXXX0XXXX;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 4 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 4 не пройден");
            failed_tests = failed_tests + 1;
        end

        // Тест 5: G7 = X, G6 = X, G5 = X, G4 = X, G3 = L, все остальные входы - X
        G = 8'bXXXX0XXX;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 5 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 5 не пройден");
            failed_tests = failed_tests + 1;
        end

        // Тест 6: G7 = X, G6 = X, G5 = X, G4 = X, G3 = X, G2 = L, все остальные входы - X
        G = 8'bXXXXX0XX;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 6 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 6 не пройден");
            failed_tests = failed_tests + 1;
        end

       // Тест 7: G7 = X, G6 = X, G5 = X, G4 = X, G3 = X, G2 = X, G1 = L, все остальные входы - X
        G = 8'bXXXXXX0X;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 7 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 7 не пройден");
            failed_tests = failed_tests + 1;
        end

        // Тест 8: G7 = X, G6 = X, G5 = X, G4 = X, G3 = X, G2 = X, G1 = X, G0 = L, все остальные входы - X
        G = 8'bXXXXXXX0;
        P = 8'bXXXXXXXX;
        Cin = 1'b0;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 8 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 8 не пройден");
            failed_tests = failed_tests + 1;
        end



        // Тест 9: Cn + 24
        G = 8'bXXXXXXXX;
        P = 8'bXXXXXXXX;
        Cin = 1'b1;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 9 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 9 не пройден");
            failed_tests = failed_tests + 1;
        end

        // Тест 10: Cn + 32
        G = 8'bXXXXXXXX;
        P = 8'bXXXXXXXX;
        Cin = 1'b1;
        #10;
        if (Cout[31] === 1'b1) begin
            $display("Тест 10 пройден");
            passed_tests = passed_tests + 1;
        end else begin
            $display("Тест 10 не пройден");
            failed_tests = failed_tests + 1;
        end

        $display("Количество пройденных тестов: %d", passed_tests);
        $display("Количество не пройденных тестов: %d", failed_tests);
    end
endmodule



