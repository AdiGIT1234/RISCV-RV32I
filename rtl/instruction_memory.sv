`timescale 1ns/1ps
`timescale 1ns/1ps
module instruction_memory #(
    parameter int MEM_DEPTH = 256,
    parameter INIT_FILE = ""
)(
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:MEM_DEPTH-1];

    logic [31:0] word_address;

    assign word_address = address >> 2;

    // Initialize memory to NOPs and optionally load a program
    initial begin : memory_init
        integer i;

        for (i = 0; i < MEM_DEPTH; i = i + 1)
            memory[i] = 32'h00000013;  // ADDI x0, x0, 0 (NOP)

        if (INIT_FILE != "")
            $readmemh(INIT_FILE, memory);
    end

    // Combinational instruction read
    always_comb begin
        if (word_address < MEM_DEPTH)
            instruction = memory[word_address];
        else
            instruction = 32'h00000013;  // NOP for invalid address
    end

endmodule
