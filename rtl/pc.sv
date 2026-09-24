`timescale 1ns/1ps
`timescale 1ns/1ps
module pc (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] next_pc,

    output logic [31:0] current_pc
);

    // Program Counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_pc <= 32'd0;
        else
            current_pc <= next_pc;
    end

endmodule
