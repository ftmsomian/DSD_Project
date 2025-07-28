module immgen(
    input  [8:0]  imm_in,
    output [15:0] imm_out
);
    assign imm_out = {{7{imm_in[8]}}, imm_in};
endmodule
