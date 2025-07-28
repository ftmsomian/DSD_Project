module testbench;
    reg clk, reset;
    integer instr_cnt;
    wire [15:0] pc, instruction, r0, r1, r2, r3;
    wire ready;

    cpu dut(.clk(clk), .reset(reset), .pc(pc), .instruction(instruction), 
            .rf0(r0), .rf1(r1), .rf2(r2), .rf3(r3), .ready(ready));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        instr_cnt = 0; reset = 1; #20 reset = 0;
        dut.rf.regs[0] = 16'd10;  // r0 = 10
        dut.rf.regs[1] = 16'd3;   // r1 = 3
        dut.rf.regs[2] = 16'd0;   // r2 = 0
        dut.rf.regs[3] = 16'd0;   // r3 = 0
        dut.mem.mem_array[16] = 16'd55;  // mem[16] = 55
        dut.mem.mem_array[17] = 16'd0;   // mem[17] = 0
        dut.mem.mem_array[18] = 16'd99;  // mem[18] = 99 (for new LOAD)
        // Original instructions
        dut.mem.mem_array[0] = {3'b000,2'b10,2'b00,2'b01,7'b0}; // ADD r2, r0, r1
        dut.mem.mem_array[1] = {3'b001,2'b10,2'b00,2'b01,7'b0}; // SUB r2, r0, r1
        dut.mem.mem_array[2] = {3'b010,2'b10,2'b00,2'b01,7'b0}; // MUL r2, r0, r1
        dut.mem.mem_array[3] = {3'b011,2'b10,2'b00,2'b01,7'b0}; // DIV r2, r0, r1
        dut.mem.mem_array[4] = {3'b100,2'b01,2'b00,9'd6};      // LOAD r1, [r0 + 6]
        dut.mem.mem_array[5] = {3'b101,2'b01,2'b00,9'd7};      // STORE r1, [r0 + 7]
        // New instructions
        dut.mem.mem_array[6] = {3'b000,2'b01,2'b10,2'b00,7'b0}; // ADD r1, r2, r0
        dut.mem.mem_array[7] = {3'b001,2'b11,2'b00,2'b01,7'b0}; // SUB r3, r0, r1
        dut.mem.mem_array[8] = {3'b010,2'b01,2'b11,2'b10,7'b0}; // MUL r1, r3, r2
        dut.mem.mem_array[9] = {3'b100,2'b11,2'b00,9'd8};      // LOAD r3, [r0 + 8]
    end

    always @(posedge clk) begin
        if (!reset && ready && instr_cnt < 10) begin
            instr_cnt = instr_cnt + 1; #15;
            case(instr_cnt)
                1: begin
                    $display("# ADD r2, r0, r1");
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                2: begin
                    $display("# SUB r2, r0, r1");
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                3: begin
                    $display("# MUL r2, r0, r1");
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                4: begin
                    $display("# DIV r2, r0, r1");
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                5: begin
                    $display("# LOAD r1, [r0 + 6]");
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                6: begin
                    $display("# STORE r1, [r0 + 7]");
                    $display("mem[17] = %d", dut.mem.mem_array[17]);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                7: begin
                    $display("# ADD r1, r2, r0");
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                8: begin
                    $display("# SUB r3, r0, r1");
                    $display("r3 = %d", r3);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                9: begin
                    $display("# MUL r1, r3, r2");
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                10: begin
                    $display("# LOAD r3, [r0 + 8]");
                    $display("r3 = %d", r3);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                    $finish;
                end
            endcase
        end
    end
endmodule