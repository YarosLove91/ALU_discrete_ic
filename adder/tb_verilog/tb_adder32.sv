`timescale 1ns / 1ps

module tb_adder32;

    reg [31:0] a;
    reg [31:0] b;
    reg Cin;
    wire [31:0] sum;
    reg [33:0] expected;
    wire Cout;

    adder32 dut(
        .a(a),
        .b(b),
        .Cin(Cin),
        .sum(sum),
        .Cout(Cout)
    );

    integer i, j, k;

    initial begin
        a = 0;
        b = 0;
        Cin = 0;
        $dumpfile("adder32_tb.vcd");
        $dumpvars(0, tb_adder32);
        $display("32 bit adder test started");


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
                    expected = i + j + k;
                    #5;
                    if ({Cout, sum} !== expected) begin
                        $display("Test failed: \na = %d, b = %d, Cin = %b, \nsum = %d, Cout = %b, expected = %d", 
                        a, b, Cin, 
                        sum, Cout, expected);
                    end
                end
            end
        end

        $display("Test completed");
        $finish;
    end

endmodule
