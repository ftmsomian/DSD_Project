module cpu(
    input         clk,
    input         reset,
    output [15:0] pc,
    output [15:0] instruction,
    output [15:0] rf0,
    output [15:0] rf1,
    output [15:0] rf2,
    output [15:0] rf3,
    output        ready
);
    wire [5:0]  ALUOp;
    wire        AluSrc, MemToReg, RegDst, RegWrite, MemWrite, done;
    wire [15:0] instr_addr;
    wire [2:0]  opcode;
    wire [1:0]  rd_addr, rs1_addr, rs2_addr;
    wire [8:0]  imm_lo;
    wire [15:0] rs1_data, rs2_data, imm_ext, alu_b, alu_result, mem_read_data, wb_data;
    wire        fetch, decode, exec, mem_stage, wb_stage;
    wire        is_load = (opcode == 3'b100);
    wire        is_store = (opcode == 3'b101);

    reg [15:0] addr_buf;
    reg [15:0] mem_data_buf;

    always @(posedge clk or posedge reset) begin
        if (reset)
            addr_buf <= 16'b0;
        else if (exec)
            addr_buf <= alu_result;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            mem_data_buf <= 16'b0;
        else if (mem_stage && is_load)
            mem_data_buf <= mem_read_data;
    end

    control ctrl(
        .clk(clk), .reset(reset), .ALUdone(1'b1), .opcode(opcode),
        .ALUOp(ALUOp), .AluSrc(AluSrc), .MemToReg(MemToReg),
        .MemWrite(MemWrite), .RegDst(RegDst), .RegWrite(RegWrite),
        .done(done), .ready(ready),
        .pc(pc), .instr_addr(instr_addr),
        .s0(fetch), .s1(decode), .s2(exec), .s3(mem_stage), .s4(wb_stage)
    );

    wire [15:0] mem_addr = (fetch || decode) ? instr_addr : addr_buf;
    memory mem(
        .clk(clk), .MemWrite(MemWrite),
        .addr(mem_addr), .write_data(rs2_data),
        .read_data(mem_read_data)
    );

    instrreg ir(
        .clk(clk), .reset(reset), .en(fetch), .instr_in(mem_read_data),
        .opcode(opcode), .rd(rd_addr), .rs1(rs1_addr), .rs2(rs2_addr), .imm_lo(imm_lo)
    );

    wire [1:0] real_rs2 = is_store ? rd_addr : rs2_addr;
    regfile rf(
        .clk(clk), .write_enable(RegWrite),
        .rs1_addr(rs1_addr), .rs2_addr(real_rs2), .rd_addr(rd_addr),
        .rd_data(wb_data), .rs1_data(rs1_data), .rs2_data(rs2_data),
        .reg0_out(rf0), .reg1_out(rf1), .reg2_out(rf2), .reg3_out(rf3)
    );

    immgen ig(.imm_in(imm_lo), .imm_out(imm_ext));
    Mux2 alu_mux(.in0(rs2_data), .in1(imm_ext), .sel(AluSrc), .out(alu_b));
    alu alu_unit(.A(rs1_data), .B(alu_b), .ALUOp(ALUOp), .Result(alu_result), .ALUdone());
    WB_Mux wbm(.alu_data(alu_result), .mem_data(mem_data_buf), .sel(MemToReg), .wb_data(wb_data));

    assign instruction = mem_read_data;
endmodule