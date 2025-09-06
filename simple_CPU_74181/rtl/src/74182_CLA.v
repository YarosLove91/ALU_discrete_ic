// Модель микросхемы ускоренного переноса (CLA) 74182 для совместной работы с АЛУ 74181
// или 4х разрядного сумматора с сигналами Propagate и Generate

// Версия с операторами редукции
module cla_74182 (
	input[3:0]  nPB, 
	input[3:0]  nGB,
	input   Cn,
	output	PBo, GBo, Cnx, Cny, Cnz
);
	assign PBo = ( &nPB[3:0]);
	assign GBo = ((&nGB[3:0]) |
				  ((&nGB[3:1]) & nPB[1]) | 
				  ((&nGB[3:2]) & nPB[2]) | 
				  (nGB[3] & nPB[3]));

	assign Cnx = ~((nPB[0]  &   nGB[0]) | 
				   (nGB[0]  &   ~Cn));

	assign Cny = ~((nPB[1]  &   nGB[1]) | 
				   (&nGB[1:0] & nPB[0]) |
				   (&nGB[1:0] &   ~Cn));

	assign Cnz = ~(((nGB[2]) & nPB[2])     | 
					(&(nGB[2:1]) & nPB[1]) |
					(&(nGB[2:0]) & nPB[0]) | 
					(&(nGB[2:0]) &   ~Cn));
endmodule


/*
// Версия стандартная
module cla_74182 (
	input[3:0]  nPB, 
	input[3:0]  nGB,
	input   Cn,
	output	PBo, GBo, Cnx, Cny, Cnz
);
	assign PBo = (  nPB[0]   |   nPB[1]   |   nPB[2]   |   nPB[3]);
	assign GBo = (  (nGB[0]  &   nGB[1]   &   nGB[2]   &   nGB[3]) | 
					(nPB[1]  &   nGB[1]   &   nGB[2]   &   nGB[3]) | 
					(nPB[2]  &   nGB[2]   &   nGB[3]) | 
					(nPB[3]  &   nGB[3]));

	assign Cnx = ~( (nPB[0]  &   nGB[0]) | 
					(nGB[0]  &   ~Cn));
	assign Cny = ~( (nPB[1]  &   nGB[1]) | 
					(nPB[0]  &   nGB[0]   &   nGB[1])  |
					(nGB[0]  &   nGB[1]   &   ~Cn));
	assign Cnz = ~( (nPB[2]  &   nGB[2]) | 
					(nPB[1]  &   nGB[1]   &   nGB[2])  |
					(nPB[0]  &   nGB[0]   &   nGB[1]   &   nGB[2])  | 
					(nGB[0]  &   nGB[1]   &   nGB[2]   &   ~Cn));
endmodule

*/