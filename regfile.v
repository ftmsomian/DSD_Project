module regfile(
    input             clk,
    input             write_enable,
    input      [1:0]  rs1_addr,
    input      [1:0]  rs2_addr,
    input      [1:0]  rd_addr,
    input      [15:0] rd_data,
    output reg [15:0] rs1_data,
    output reg [15:0] rs2_data,
    output     [15:0] reg0_out,
    output     [15:0] reg1_out,
    output     [15:0] reg2_out,
    output     [15:0] reg3_out
);
    reg [15:0] regs [0:3];

    always @(posedge clk) begin
        if (write_enable && rd_addr != 2'b00)
            regs[rd_addr] <= rd_data;
    end

    always @(*) begin
        rs1_data = regs[rs1_addr];
        rs2_data = regs[rs2_addr];
    end

    assign reg0_out = regs[0];
    assign reg1_out = regs[1];
    assign reg2_out = regs[2];
    assign reg3_out = regs[3];
endmodule