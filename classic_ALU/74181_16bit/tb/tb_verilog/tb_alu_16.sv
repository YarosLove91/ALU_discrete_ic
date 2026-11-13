`timescale 1ns / 1ps

module tb_ALU16;

	reg [15:0] A,B;
	reg [3:0] sel;
	reg mode, Cin;
	wire [15:0] Result;
	wire Cout, nBo, nGo;

	integer errors = 0;
	integer checks = 0;
	integer t, i;
	reg [16:0] r;
	reg [3:0] pn, gn;
	reg [3:0] an, bn, p, g;
	reg exp_nBo, exp_nGo;

	alu16 dut(
		.a(A),
		.b(B),
		.Cin(Cin),
		.mode(mode),
		.sel(sel),
		.result(Result),
		.Cout(Cout),
		.nBo(nBo),
		.nGo(nGo)
	);

	task check(input [15:0] a, b, input [3:0] s, input m, input cin,
	           input [15:0] exp_f, input exp_c, input chk_c);
		begin
			A = a; B = b; sel = s; mode = m; Cin = ~cin;
			#1;
			checks = checks + 1;
			if (Result !== exp_f) begin
				errors = errors + 1;
				$display("FAIL F: a=%h b=%h sel=%b mode=%b cin=%b got=%h exp=%h",
				         a, b, s, m, cin, Result, exp_f);
			end
			if (chk_c && Cout !== ~exp_c) begin
				errors = errors + 1;
				$display("FAIL C: a=%h b=%h cin=%b got=%b exp=%b",
				         a, b, cin, Cout, ~exp_c);
			end
		end
	endtask

	task check_pg;
		begin
			pn = dut.nGP; gn = dut.nGG;
			exp_nBo = &pn;
			exp_nGo = (gn[3]&pn[3]) | (gn[3]&gn[2]&pn[2]) |
			          (gn[3]&gn[2]&gn[1]&pn[1]) | (&gn);
			checks = checks + 1;
			if (nBo !== exp_nBo || nGo !== exp_nGo) begin
				errors = errors + 1;
				$display("FAIL PG: nGP=%b nGG=%b nBo=%b exp=%b nGo=%b exp=%b",
				         pn, gn, nBo, exp_nBo, nGo, exp_nGo);
			end
		end
	endtask

	initial begin
		$dumpfile("tb_ALU16.vcd");
		$dumpvars(0, tb_ALU16);
		$display("Test started");

		// A plus B, directed carry-chain corners
		check(16'h0000, 16'h0000, 4'b1001, 0, 0, 16'h0000, 0, 1);
		check(16'hFFFF, 16'h0000, 4'b1001, 0, 1, 16'h0000, 1, 1);
		check(16'hFFFF, 16'hFFFF, 4'b1001, 0, 0, 16'hFFFE, 1, 1);
		check(16'h7FFF, 16'h7FFF, 4'b1001, 0, 1, 16'hFFFF, 0, 1);
		check(16'h0FFF, 16'h0001, 4'b1001, 0, 0, 16'h1000, 0, 1);
		check(16'h00FF, 16'h0001, 4'b1001, 0, 0, 16'h0100, 0, 1);
		check(16'h000F, 16'h0001, 4'b1001, 0, 0, 16'h0010, 0, 1);
		check_pg;

		// random addition / subtraction with golden model
		for (t = 0; t < 500; t = t + 1) begin
			reg [15:0] a, b; reg cin;
			a = $urandom; b = $urandom; cin = $urandom_range(0,1);
			r = {1'b0, a} + {1'b0, b} + cin;
			check(a, b, 4'b1001, 0, cin, r[15:0], r[16], 1);
			check_pg;
			r = {1'b0, a} + {1'b0, ~b} + cin;
			check(a, b, 4'b0110, 0, cin, r[15:0], r[16], 1);
		end
		// logic operations
		for (t = 0; t < 200; t = t + 1) begin
			reg [15:0] a, b;
			a = $urandom; b = $urandom;
			check(a, b, 4'b0110, 1, 0, a ^ b, 0, 0);
			check(a, b, 4'b1011, 1, 0, a & b, 0, 0);
			check(a, b, 4'b1110, 1, 0, a | b, 0, 0);
			check(a, b, 4'b1111, 1, 0, a,     0, 0);
			check(a, b, 4'b0000, 1, 0, ~a,    0, 0);
		end

		$display("Checks: %0d, errors: %0d", checks, errors);
		if (errors == 0)
			$display("TESTS PASSED");
		else
			$fatal(1, "TESTS FAILED");
		$display("Test completed");
		$finish;
	end

endmodule
