`timescale 1ns/1ps

module alu (
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    input  logic [3:0]  alu_op,
    output logic [31:0] result,
    output logic        zero
);

always_comb begin
    case (alu_op)

        4'b0000: result = operand_a + operand_b; // ADD
        4'b0001: result = operand_a - operand_b; // SUB
        4'b0010: result = operand_a & operand_b; // AND
        4'b0011: result = operand_a | operand_b; // OR
        4'b0100: result = operand_a ^ operand_b; // XOR

        4'b0101: begin // SLT
            result = ($signed(operand_a) < $signed(operand_b))
                     ? 32'd1 : 32'd0;
        end

        4'b0110: begin // SLL
            result = operand_a << operand_b[4:0];
        end

        4'b0111: begin // SLTU
            result = ($unsigned(operand_a) < $unsigned(operand_b))
                     ? 32'd1 : 32'd0;
        end

        4'b1000: begin // SRL
            result = operand_a >> operand_b[4:0];
        end

        4'b1001: begin // SRA
            result = $signed(operand_a) >>> operand_b[4:0];
        end

        default: result = 32'd0;

    endcase
end

assign zero = (result == 32'd0);

endmodule
