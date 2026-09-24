`timescale 1ns/1ps
`timescale 1ns/1ps
module alu (
input  logic [31:0] operand_a,
input  logic [31:0] operand_b,
input  logic [2:0]  alu_op,

output logic [31:0] result,
output logic        zero

);

always_comb begin
    case (alu_op)
        3'b000: result = operand_a + operand_b;                 // ADD
        3'b001: result = operand_a - operand_b;                 // SUB
        3'b010: result = operand_a & operand_b;                 // AND
        3'b011: result = operand_a | operand_b;                 // OR
        3'b100: result = operand_a ^ operand_b;                 // XOR
        3'b101: result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0; // SLT
        default: result = 32'd0;
    endcase
end

// Zero flag (used for branch decisions)
assign zero = (result == 32'd0);

endmodule
