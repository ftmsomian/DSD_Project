module WB_Mux(
    input  [15:0] alu_data,
    input  [15:0] mem_data,
    input         sel,
    output [15:0] wb_data
);
    assign wb_data = sel ? mem_data : alu_data;
endmodule