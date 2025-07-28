module memory(
    input              clk,
    input              MemWrite,
    input      [15:0]  addr,
    input      [15:0]  write_data,
    output reg [15:0]  read_data
);
    reg [15:0] mem_array [0:255]; // Reduced size for synthesizability

    always @(posedge clk) begin
        if (MemWrite)
            mem_array[addr] <= write_data;
    end

    always @(*) begin
        read_data = mem_array[addr];
    end
endmodule
