module FullAdder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    wire axb;
    assign axb  = a ^ b;
    assign sum  = axb ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module RippleAdder4 (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);
    wire [3:0] c;

    FullAdder fa0 (
        .a(A[0]), .b(B[0]), .cin(Cin),
        .sum(Sum[0]), .cout(c[0])
    );

    FullAdder fa1 (
        .a(A[1]), .b(B[1]), .cin(c[0]),
        .sum(Sum[1]), .cout(c[1])
    );

    FullAdder fa2 (
        .a(A[2]), .b(B[2]), .cin(c[1]),
        .sum(Sum[2]), .cout(c[2])
    );

    FullAdder fa3 (
        .a(A[3]), .b(B[3]), .cin(c[2]),
        .sum(Sum[3]), .cout(Cout)
    );
endmodule

module CSA4 (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin_sel,   
    output [3:0] Sum,
    output       Cout
);
    wire [3:0] sum0, sum1;
    wire       c0, c1;

    RippleAdder4 r0 (
        .A(A), .B(B), .Cin(1'b0),
        .Sum(sum0), .Cout(c0)
    );

    RippleAdder4 r1 (
        .A(A), .B(B), .Cin(1'b1),
        .Sum(sum1), .Cout(c1)
    );

    assign Sum  = Cin_sel ? sum1 : sum0;
    assign Cout = Cin_sel ? c1 : c0;
endmodule

module CSA16 (
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,
    output [15:0] Sum,
    output        Cout
);
    wire [2:0] c_sel;

    CSA4 blk0 (
        .A(A[3:0]),   .B(B[3:0]),   .Cin_sel(Cin),       .Sum(Sum[3:0]),   .Cout(c_sel[0])
    );
    CSA4 blk1 (
        .A(A[7:4]),   .B(B[7:4]),   .Cin_sel(c_sel[0]),   .Sum(Sum[7:4]),   .Cout(c_sel[1])
    );
    CSA4 blk2 (
        .A(A[11:8]),  .B(B[11:8]),  .Cin_sel(c_sel[1]),   .Sum(Sum[11:8]),  .Cout(c_sel[2])
    );
    CSA4 blk3 (
        .A(A[15:12]), .B(B[15:12]), .Cin_sel(c_sel[2]),   .Sum(Sum[15:12]), .Cout(Cout)
    );
endmodule

module Mul8_ShiftAdd_Comb (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] P
);
    integer i;
    reg [15:0] result;

    always @(*) begin
        result = 16'd0;
        for (i = 0; i < 8; i = i + 1) begin
            if (B[i])
                result = result + (A << i);
        end
    end

    assign P = result;
endmodule

module Mul16_Karatsuba_Comb (
    input  [15:0] X,
    input  [15:0] Y,
    output [31:0] P
);
    wire [7:0] XH = X[15:8], XL = X[7:0];
    wire [7:0] YH = Y[15:8], YL = Y[7:0];

    wire [15:0] Z0, Z2, Z01;

    wire [8:0] sumX = XH + XL;
    wire [8:0] sumY = YH + YL;

    Mul8_ShiftAdd_Comb mul_z0 (
        .A(XL), .B(YL), .P(Z0)
    );

    Mul8_ShiftAdd_Comb mul_z2 (
        .A(XH), .B(YH), .P(Z2)
    );

    Mul8_ShiftAdd_Comb mul_z01 (
        .A(sumX[7:0]), .B(sumY[7:0]), .P(Z01)  
    );

    wire [17:0] Z0_ext  = {2'b00, Z0};
    wire [17:0] Z2_ext  = {2'b00, Z2};
    wire [17:0] Z01_ext = {2'b00, Z01};

    wire [17:0] Z1 = Z01_ext - Z0_ext - Z2_ext;

    assign P = (Z2 << 16) + (Z1 << 8) + Z0;
endmodule

module Divider16_QuotientOnly_Comb (
    input  [15:0] Dividend,
    input  [15:0] Divisor,
    output [15:0] Quotient
);
    wire [15:0] rem_stage [0:16];
    wire [15:0] div_stage [0:16];
    wire [15:0] quo_stage [0:16];
    
    assign rem_stage[0] = 16'b0;
    assign div_stage[0] = Dividend;
    assign quo_stage[0] = 16'b0;
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : division_stages
            wire [15:0] shifted_rem = {rem_stage[i][14:0], div_stage[i][15]};
            wire [15:0] shifted_div = {div_stage[i][14:0], 1'b0};
            wire [15:0] sub_result = shifted_rem - Divisor;
            
            assign quo_stage[i+1] = (sub_result[15]) ? 
                                   {quo_stage[i][14:0], 1'b0} : 
                                   {quo_stage[i][14:0], 1'b1};
            
            assign rem_stage[i+1] = (sub_result[15]) ? 
                                   shifted_rem : 
                                   sub_result;
            
            assign div_stage[i+1] = shifted_div;
        end
    endgenerate
    
    assign Quotient = (Divisor == 16'b0) ? 16'hFFFF : quo_stage[16];
endmodule