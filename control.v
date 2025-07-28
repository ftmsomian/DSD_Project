module control(
    input        clk,
    input        reset,
    input        ALUdone,
    input  [2:0] opcode,
    output reg [5:0] ALUOp,
    output reg   AluSrc,
    output reg   MemToReg,
    output reg   MemWrite,
    output reg   RegDst,
    output reg   RegWrite,
    output reg   done,
    output reg   ready,
    output reg [15:0] pc,
    output       [15:0] instr_addr,
    output       s0,
    output       s1,
    output       s2,
    output       s3,
    output       s4
);
    localparam S_FETCH  = 5'b00001;
    localparam S_DECODE = 5'b00010;
    localparam S_EXEC   = 5'b00100;
    localparam S_MEM    = 5'b01000;
    localparam S_WB     = 5'b10000;

    reg [4:0] state, next_state;
    wire is_add   = (opcode == 3'b000);
    wire is_sub   = (opcode == 3'b001);
    wire is_mul   = (opcode == 3'b010);
    wire is_div   = (opcode == 3'b011);
    wire is_load  = (opcode == 3'b100);
    wire is_store = (opcode == 3'b101);
    wire is_rtype = is_add | is_sub | is_mul | is_div;
    wire is_mtype = is_load | is_store;

    always @(*) begin
        case (state)
            S_FETCH:  next_state = S_DECODE;
            S_DECODE: next_state = S_EXEC;
            S_EXEC:   if (ALUdone) begin
                          if (is_rtype) next_state = S_WB;
                          else if (is_mtype) next_state = S_MEM;
                          else next_state = S_FETCH;
                      end
            S_MEM:    next_state = is_load ? S_WB : S_FETCH;
            S_WB:     next_state = S_FETCH;
            default:  next_state = S_FETCH;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_FETCH;
        else
            state <= next_state;
    end

    assign s0 = state[0]; // FETCH
    assign s1 = state[1]; // DECODE
    assign s2 = state[2]; // EXEC
    assign s3 = state[3]; // MEM
    assign s4 = state[4]; // WB

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUOp <= 6'b000000;
            pc <= 16'h0000;
        end else begin
            if (state == S_DECODE)
                ALUOp <= is_rtype ? {3'b000, opcode} : (is_mtype ? 6'b000000 : 6'b000000);
            else if (state == S_FETCH)
                ALUOp <= 6'b000000;
            if (done)
                pc <= pc + 1;
        end
    end

    always @(*) begin
        AluSrc = (state == S_EXEC) && is_mtype;
        MemWrite = (state == S_MEM) && is_store;
        RegWrite = (state == S_WB) && (is_rtype || is_load);
        MemToReg = (state == S_WB) && is_load;
        RegDst = (state == S_WB) && is_rtype;
        done = ((state == S_WB) && (is_rtype || is_load)) || ((state == S_MEM) && is_store);
        ready = done;
    end

    assign instr_addr = pc;
endmodule
