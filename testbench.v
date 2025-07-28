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
        dut.mem.mem_array[16] = 16'd55;   // mem[16] = 55
        dut.mem.mem_array[17] = 16'd0;    // mem[17] = 0
        dut.mem.mem_array[18] = 16'd99;   // mem[18] = 99
        dut.mem.mem_array[20] = 16'd25;   // mem[20] = 25 (new LOAD)
        dut.mem.mem_array[21] = 16'd0;    // mem[21] = 0 (new STORE)
        dut.mem.mem_array[23] = 16'd77;   // mem[23] = 77 (new LOAD)
        // Original instructions
        dut.mem.mem_array[0] = {3'b000,2'b10,2'b00,2'b01,7'b0}; // ADD r2, r0, r1
        dut.mem.mem_array[1] = {3'b001,2'b10,2'b00,2'b01,7'b0}; // SUB r2, r0, r1
        dut.mem.mem_array[2] = {3'b010,2'b10,2'b00,2'b01,7'b0}; // MUL r2, r0, r1
        dut.mem.mem_array[3] = {3'b011,2'b10,2'b00,2'b01,7'b0}; // DIV r2, r0, r1
        dut.mem.mem_array[4] = {3'b100,2'b01,2'b00,9'd6};      // LOAD r1, [r0 + 6]
        dut.mem.mem_array[5] = {3'b101,2'b01,2'b00,9'd7};      // STORE r1, [r0 + 7]
        dut.mem.mem_array[6] = {3'b000,2'b01,2'b10,2'b00,7'b0}; // ADD r1, r2, r0
        dut.mem.mem_array[7] = {3'b001,2'b11,2'b00,2'b01,7'b0}; // SUB r3, r0, r1
        dut.mem.mem_array[8] = {3'b010,2'b01,2'b11,2'b10,7'b0}; // MUL r1, r3, r2
        dut.mem.mem_array[9] = {3'b100,2'b11,2'b00,9'd8};      // LOAD r3, [r0 + 8]
        // New instructions
        dut.mem.mem_array[10] = {3'b000,2'b11,2'b01,2'b10,7'b0}; // ADD r3, r1, r2
        dut.mem.mem_array[11] = {3'b001,2'b01,2'b10,2'b01,7'b0}; // SUB r1, r2, r1
        dut.mem.mem_array[12] = {3'b010,2'b10,2'b01,2'b11,7'b0}; // MUL r2, r1, r3
        dut.mem.mem_array[13] = {3'b011,2'b11,2'b01,2'b00,7'b0}; // DIV r3, r1, r0
        dut.mem.mem_array[14] = {3'b100,2'b01,2'b10,9'd10};     // LOAD r1, [r2 + 10]
        dut.mem.mem_array[15] = {3'b101,2'b10,2'b01,9'd11};     // STORE r2, [r1 + 11]
        dut.mem.mem_array[16] = {3'b000,2'b10,2'b11,2'b01,7'b0}; // ADD r2, r3, r1
        dut.mem.mem_array[17] = {3'b001,2'b11,2'b10,2'b00,7'b0}; // SUB r3, r2, r0
        dut.mem.mem_array[18] = {3'b010,2'b01,2'b11,2'b01,7'b0}; // MUL r1, r3, r1
        dut.mem.mem_array[19] = {3'b100,2'b10,2'b11,9'd13};     // LOAD r2, [r3 + 13]
    end

    always @(posedge clk) begin
        if (!reset && ready && instr_cnt < 20) begin
            instr_cnt = instr_cnt + 1; #15;
            case(instr_cnt)
                1: begin
                    $display("# ADD r2, r0, r1"); // r2 = 10 + 3 = 13
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                2: begin
                    $display("# SUB r2, r0, r1"); // r2 = 10 - 3 = 7
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                3: begin
                    $display("# MUL r2, r0, r1"); // r2 = 10 * 3 = 30
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                4: begin
                    $display("# DIV r2, r0, r1"); // r2 = 10 / 3 = 3
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                5: begin
                    $display("# LOAD r1, [r0 + 6]"); // r1 = mem[10 + 6] = mem[16] = 55
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                6: begin
                    $display("# STORE r1, [r0 + 7]"); // mem[10 + 7] = mem[17] = r1 = 55
                    $display("mem[17] = %d", dut.mem.mem_array[17]);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                7: begin
                    $display("# ADD r1, r2, r0"); // r1 = 3 + 10 = 13
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                8: begin
                    $display("# SUB r3, r0, r1"); // r3 = 10 - 13 = -3 (65533 unsigned)
                    $display("r3 = %d", r3);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                9: begin
                    $display("# MUL r1, r3, r2"); // r1 = -3 * 3 = -9 (65527 unsigned)
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                10: begin
                    $display("# LOAD r3, [r0 + 8]"); // r3 = mem[10 + 8] = mem[18] = 99
                    $display("r3 = %d", r3);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                11: begin
                    $display("# ADD r3, r1, r2"); // r3 = -9 + 3 = -6 (65530 unsigned)
                    $display("r3 = %d", r3);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                12: begin
                    $display("# SUB r1, r2, r1"); // r1 = 3 - (-9) = 12
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                13: begin
                    $display("# MUL r2, r1, r3"); // r2 = 12 * (-6) = -72 (65464 unsigned)
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                14: begin
                    $display("# DIV r3, r1, r0"); // r3 = 12 / 10 = 1
                    $display("r3 = %d", r3);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                15: begin
                    $display("# LOAD r1, [r2 + 10]"); // r1 = mem[65464 + 10 mod 256] = mem[18] = 99
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                16: begin
                    $display("# STORE r2, [r1 + 11]"); // mem[99 + 11] = mem[110] = r2 = -72 (65464)
                    $display("mem[110] = %d", dut.mem.mem_array[110]);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                17: begin
                    $display("# ADD r2, r3, r1"); // r2 = 1 + 99 = 100
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                18: begin
                    $display("# SUB r3, r2, r0"); // r3 = 100 - 10 = 90
                    $display("r3 = %d", r3);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                19: begin
                    $display("# MUL r1, r3, r1"); // r1 = 90 * 99 = 8910
                    $display("r1 = %d", r1);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                end
                20: begin
                    $display("# LOAD r2, [r3 + 13]"); // r2 = mem[1 + 13] = mem[14] = 0
                    $display("r2 = %d", r2);
                    $display("r0 = %d, r1 = %d, r2 = %d, r3 = %d", r0, r1, r2, r3);
                    $finish;
                end
            endcase
        end
    end
endmodule
