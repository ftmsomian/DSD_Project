module instrreg(
    input         clk,
    input         reset,
    input         en,
    input  [15:0] instr_in,
    output [2:0]  opcode,
    output [1:0]  rd,
    output [1:0]  rs1,
    output [1:0]  rs2,
    output [8:0]  imm_lo
);
    reg [15:0] IR;

    always @(posedge clk or posedge reset) begin
        if (reset)
            IR <= 16'b0;
        else if (en)
            IR <= instr_in;
    end

    assign opcode = IR[15:13];
    assign rd     = IR[12:11];
    assign rs1    = IR[10:9];
    assign rs2    = IR[8:7];
    assign imm_lo = IR[8:0];
endmodule
