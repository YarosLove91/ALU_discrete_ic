/*
Этот макрос предназначен для распаковки данных из одного 
большого шинного сигнала в несколько меньших сигналов.

Параметры:
PK_LEN: Длина массива (количество элементов).
PK_WIDTH: Ширина каждого элемента в битах.
UNPK_DEST: Целевой массив, куда будут распакованы данные.
PK_SRC: Исходный шинный сигнал, откуда будут браться данные.
*/

`define ASSIGN_UNPACK_ARRAY(PK_LEN, PK_WIDTH, UNPK_DEST, PK_SRC)                            \
	wire [PK_LEN*PK_WIDTH-1:0] PK_IN_BUS;                                                   \
	assign PK_IN_BUS=PK_SRC;                                                                \
	generate genvar unpk_idx;                                                               \
		for (unpk_idx=0; unpk_idx<PK_LEN; unpk_idx=unpk_idx+1) begin: gen_unpack            \
		assign UNPK_DEST[unpk_idx][PK_WIDTH-1:0]=PK_IN_BUS[PK_WIDTH*unpk_idx+:PK_WIDTH];    \
		end                                                                                 \
	endgenerate

/*
Этот макрос предназначен для упаковки данных из нескольких 
меньших сигналов в один большой шинный сигнал.

Параметры:

PK_LEN: Длина массива (количество элементов).
PK_WIDTH: Ширина каждого элемента в битах.
UNPK_SRC: Исходный массив, откуда будут браться данные.
*/
`define PACK_ARRAY(PK_LEN, PK_WIDTH, UNPK_SRC) PK_OUT_BUS;                                  \
	wire [PK_LEN*PK_WIDTH-1:0] PK_OUT_BUS;                                                  \
	generate genvar pk_idx;                                                                 \
		for (pk_idx=0; pk_idx<PK_LEN; pk_idx=pk_idx+1) begin: gen_pack                      \
		assign PK_OUT_BUS[PK_WIDTH*pk_idx+:PK_WIDTH]=UNPK_SRC[pk_idx][PK_WIDTH-1:0];        \
		end                                                                                 \
	endgenerate
