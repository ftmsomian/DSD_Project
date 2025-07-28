module alu(
    input      [15:0] A,
    input      [15:0] B,
    input      [5:0]  ALUOp,
    output reg [15:0] Result,
    output reg ALUdone
);
    wire [2:0] func = ALUOp[2:0];
    wire [15:0] sum_result;
    wire cout;

    CSA16 csa (
        .A(A),
        .B(func == 3'b001 ? ~B : B),
        .Cin(func == 3'b001),
        .Sum(sum_result),
        .Cout(cout)
    );

    wire [31:0] mul_result;
    Mul16_Karatsuba_Comb mul (
        .X(A),
        .Y(B),
        .P(mul_result)
    );

    wire [15:0] div_result;
    Divider16_QuotientOnly_Comb div (
        .Dividend(A),
        .Divisor(B),
        .Quotient(div_result)
    );

    always @(*) begin
        case (func)
            3'b000: Result = sum_result;                    // ADD
            3'b001: Result = sum_result;                    // SUB
            3'b010: Result = mul_result[15:0];              // MUL
            3'b011: Result = (B != 0) ? div_result : 16'hFFFF; // DIV
            default: Result = sum_result;                   // Address calc
        endcase
        ALUdone = 1'b1; // Combinational ALU
    end
endmodule