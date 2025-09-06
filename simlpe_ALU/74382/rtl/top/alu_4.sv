module alu_chain
#(
    parameter ALU_CHAIN_W = UINT_16_W,      // summary width of all alus
              ALU_W       = ORIG_OPERAND_W  // one alu width
)
(
    input  logic [   SELECT_W-1:0]  sel         ,
    input  logic                    ch_carry_in , // ch_ for "chain"
    input  logic [ALU_CHAIN_W-1:0]  ch_port_a   ,
    input  logic [ALU_CHAIN_W-1:0]  ch_port_b   ,
    output logic [ALU_CHAIN_W-1:0]  ch_result   ,
    output logic                    ch_overflow ,
    output logic                    ch_carry_out
);


//-------------------assertions-------------------
// assert ((ALU_CHAIN_W % ALU_W) == 0);
// else $display("Error: ALU_CHAIN_W parameter must be a multiple of ALU_W.");


//------------------localparams-------------------
localparam ALU_QTY = ALU_CHAIN_W / ALU_W;


//--------------------signals---------------------
logic [ALU_QTY - 1:0]              carry_in;
logic [ALU_QTY - 1:0][ALU_W - 1:0] port_a;
logic [ALU_QTY - 1:0][ALU_W - 1:0] port_b;
logic [ALU_QTY - 1:0][ALU_W - 1:0] result;
logic [ALU_QTY - 1:0]              carry_out;
logic [ALU_QTY - 1:0]              overflow;


//--------------------logic----------------------
always_comb begin : alus_carry_in_handler
    carry_in[0] = ch_carry_in;
    for (int a = 1; a < ALU_QTY; a++) begin
        carry_in[a] = carry_out[a - 1];
    end
end

always_comb begin : alus_ports_handler
    foreach (port_a[p]) begin
        port_a[p] = ch_port_a[p*ALU_W +: ALU_W];
    end
    foreach (port_b[p]) begin
        port_b[p] = ch_port_b[p*ALU_W +: ALU_W];
    end
end

generate
    genvar i;
    for (i = 0; i < ALU_QTY; i++) begin
        alu_74382 #(
            .OPERAND_W(ALU_W),
            .RESULT_W (ALU_W)
        ) i_alu_74382 (
            .sel      (sel         ),
            .carry_in (carry_in[i] ),
            .port_a   (port_a[i]   ),
            .port_b   (port_b[i]   ),
            .result   (result[i]   ),
            .overflow (overflow[i] ),
            .carry_out(carry_out[i])
        );

    end
endgenerate

always_comb begin : chain_outputs
    ch_result    = result;
    ch_overflow  = overflow[ALU_QTY - 1];
    ch_carry_out = carry_out[ALU_QTY - 1];
end

endmodule : alu_chain