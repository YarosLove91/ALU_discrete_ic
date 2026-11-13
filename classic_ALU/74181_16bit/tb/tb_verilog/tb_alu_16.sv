`timescale 1ns / 1ps

module tb_ALU16;

	reg [15:0] A,B;
	reg [3:0] cmd;
	reg Cin;
	wire [15:0] Result;
	reg [17:0] expected;
	wire Cout, nBo, nGo;

	alu16 dut(
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
		$dumpfile("tb_ALU16.vcd");
		$dumpvars(0, tb_ALU16);
		$display("Test started");

		$display("Test completed");
		$finish;
	end

endmodule