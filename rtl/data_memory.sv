`timescale 1ns/1ps
`timescale 1ns/1ps
module data_memory #(
    parameter int MEM_DEPTH = 256
)(
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] address,
    input  logic [31:0] write_data,

    input  logic        mem_read,
    input  logic        mem_write,

    output logic [31:0] read_data
);

    logic [31:0] memory [0:MEM_DEPTH-1];

    // Word address derived from byte address.
    logic [31:0] word_address;

    assign word_address = address >> 2;

    // Memory reset and synchronous write
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            integer i;

            for (i = 0; i < MEM_DEPTH; i = i + 1)
                memory[i] <= 32'd0;
        end
        else begin
            if (mem_write && (word_address < MEM_DEPTH))
                memory[word_address] <= write_data;
        end
    end

    // Combinational read
    always_comb begin
        if (mem_read && (word_address < MEM_DEPTH))
            read_data = memory[word_address];
        else
            read_data = 32'd0;
    end

endmodule
