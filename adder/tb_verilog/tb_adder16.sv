`timescale 1ns / 1ps

module tb_adder16;

    reg [15:0] a;
    reg [15:0] b;
    reg Cin;
    wire [15:0] sum;
    reg [17:0] expected;
    wire Cout, nBo, nGo;

    adder16 dut(
        .a(a),
        .b(b),
        .Cin(Cin),
        .sum(sum),
        .Cout(Cout),
        .nBo(nBo),
        .nGo(nGo)
    );

    integer i, j, k;

    initial begin
        $dumpfile("adder16_tb.vcd");
        $dumpvars(0, tb_adder16);
        $display("16 bit adder test started");

        $monitor("Time=%0t, A=%d, B=%d, Cin=%b, Cout=%b, ALU_Result=%d ALU_Expected=%d ", 
                 $time,
                 a, 
                 b, 
                 Cin, 
                 Cout, 
                 sum,
                 expected
            );

        // Loop over all possible values of a, b and Cin
        for (i = 0; i < 1000; i = i + 1) begin
            for (j = 0; j < 1000; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    a = i;
                    b = j;
                    Cin = k;
                    expected = a + b + Cin;
                    #5;
                    if ({Cout, sum} !== expected) begin
                        $display("Test failed: \na = %d, b = %d, Cin = %b, \nsum = %d, Cout = %b, expected = %d", 
                        a, b, Cin, 
                        sum, Cout, expected);
                        $finish;
                    end
                end
            end
        end

        $display("Test completed");
        $finish;
    end

endmodule
