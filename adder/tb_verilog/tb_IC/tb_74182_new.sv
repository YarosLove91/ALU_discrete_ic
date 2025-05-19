module tb_Circuit74182b;
	reg [3:0] PB, GB;
	reg Cn;
	wire PBo, GBo, Cnx, Cny, Cnz;


	reg failure_stat = 1'b0;
	reg [63:0]string_state = "Init";
	// Инстанцирование тестируемого модуля
	cla_ic_74182b uut (
		.PB(PB),
		.GB(GB),
		.Cn(Cn),
		.PBo(PBo),
		.GBo(GBo),
		.Cnx(Cnx),
		.Cny(Cny),
		.Cnz(Cnz)
	);
	
	integer success_count, failure_count;

	task test_p(
		input [3:0] p_input,
		input p_expected
	);

	# 1;

	$display ("TEST input [%b] output %b ",
              p_input[3:0], 
              p_expected);
    
        PB[3:0]  = p_input[3:0] ;
#10;
	if ( p_expected !== PBo)
			$display ("FAIL: EXPECTED \t %b RESULT %b", p_expected, PBo);
	endtask


    task test_CnX(
		input [2:0]t_data,//tG0, tP0, tCn,
		input eCnX
	);

	# 1;
	$display ("TEST input [%b] output %b ",
            t_data,
            eCnX);
        {GB[0], PB[0], Cn} = {t_data[2:0]}; //{tG0, tP0, tCn} ;
#10;
	if ( eCnX !== Cnx)
		$display ("FAIL: EXPECTED \t %b RESULT %b", eCnX, Cnx);
	endtask

    task test_CnY(
		input [4:0]t_data,//tG0, tP0, tCn,
		input eCnY
	);

	# 1;
	$display ("TEST input [%b] output %b ",
            t_data,
            eCnY);
    
        {GB[1], GB[0], PB[1], PB[0], Cn} = t_data[4:0]; //{tG0, tP0, tCn} ;
#10;
	if ( eCnY !== Cny)
		begin
			$display ("FAIL: EXPECTED \t %b RESULT %b", eCnY, Cny);
		end

	endtask


initial begin
    integer i;
	 // Настройка VCD
	$dumpfile("tb_74182n.vcd");
	$dumpvars(0, tb_Circuit74182b);
	$display( "Testing P");
	$display ("\nInputs\t\t\t\tOutputs");
	$display( "|--------|--------|--------|--------|");
	$display ("P3\tP2\tP1\tP0\tP");
	$display ("0\t0\t0\t0\t0");
	$display ("All other comb	          0");
    $display ("\n");

    for ( i = 0 ; i < 16 ; i=i+1 ) begin
        if (i == 0)
            test_p(i[3:0], 1'b0);
        else
            test_p(i[3:0], 1'b1);
    end

    $display("\nTesting Cn+x");
	$display ("\nInputs\t\t\t\tOutputs");
	$display( "|--------|--------|--------|--------|");
	$display ("G0\tP0\tCn\tCn+x");
	$display ("0\tX\tX\t1");
    $display ("X\t0\tX\t1");
	$display ("All other comb	          1");
    $display ("\n");

    test_CnX(3'b000, '1);
    test_CnX(3'b001, '1);
    test_CnX(3'b010, '1);
    test_CnX(3'b011, '1);
    test_CnX(3'b0xx, '1);

    test_CnX(3'b101, '1);
    test_CnX(3'bx01, '1);

    test_CnX(3'b100, '0);
    test_CnX(3'b110, '0);
    test_CnX(3'b111, '0);

    $display("\nTesting Cn+Y");
	$display ("\nInputs\t\t\t\tOutputs");
	$display( "|--------|--------|--------|--------|");
	$display ("G1\tG0\tP1\tP0\tCn+y");
	$display ("0\tX\tX\tX\tX\t1");
    $display ("X\t0\t0\tX\tX\t1");
    $display ("X\tX\t0\t0\t1\t1");
	$display ("All other comb	          0");
    $display ("\n");

    test_CnY(5'b0xxxx, '1);
    test_CnY(5'bx00xx, '1);
    test_CnY(5'bxx001, '1);

    test_CnY(5'b0xxxx, '1);
    test_CnY(5'bx00xx, '1);


    $display("\nTesting shit Y test");
// Test case 4: All other combinations
/* verilator lint_off WIDTHTRUNC */
    for (i = 0; i < 2**6; i++) begin
        {GB[1], GB[0], PB[1], PB[0], Cn} = i;
        if (!(GB[1] === '0 && GB[0] === 'x && PB[1] === 'x && PB[0] === 'x && Cn === 'x) &&
            !(GB[0] === '0 && GB[1] === 'x && PB[1] === '0 && PB[0] === 'x && Cn === 'x) &&
            !(PB[1] === '0 && PB[0] === '0 && GB[1] === 'x && GB[0] === 'x && Cn === '1 )) begin
            #10;
            assert (Cny === 0) else $error("Test 4: Failure - out should be 0");
        end
    end



#10
	$finish;

end

endmodule

    //     if (!(GB[1:0] === 2'b0x && PB[1:0] === 2'bxx && Cn === 'x) &&
    //         !(GB[1:0] === 2'bx0 && PB[1:0] === 2'b0x && Cn === 'x) &&
    //         !(GB[1:0] === 2'bxx && PB[1:0] === 2'b00 && Cn === 1 )) begin
    //         #10;
    //         assert (Cny === 0) else $error("Test 4: Failure - out should be 0");
    //     end
    // end