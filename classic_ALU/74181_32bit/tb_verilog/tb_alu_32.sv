`timescale 1ns / 1ps

module tb_ALU32;

    reg [31:0] A,B;
	reg [3:0] cmd;
	reg Cin;
	wire [31:0] Result;
	reg [32:0] expected;
	wire Cout, nBo, nGo;

	alu32 dut(
		.a(a),
		.b(b),
		.Cin(Cin),
        .mode(mode),
        .sel(sel),
        .result(result),
		.Cout(Cout),
		.nBo(nBo),
		.nGo(nGo)
	);

    initial begin
        $dumpfile("tb_ALU32.vcd");
        $dumpvars(0, tb_ALU32);
        $display("Test started");

        $display("Test completed");
        $finish;
    end

endmodule
