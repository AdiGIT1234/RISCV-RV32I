`timescale 1ns/1ps
module control_unit (
input  logic [6:0] opcode,
input  logic [2:0] funct3,
input  logic [6:0] funct7,

output logic       reg_write,
output logic       alu_src,
output logic       mem_read,
output logic       mem_write,
output logic       mem_to_reg,
output logic       branch,
output logic [2:0] alu_op

);

always_comb begin
    // Default values (VERY IMPORTANT)
    reg_write  = 0;
    alu_src    = 0;
    mem_read   = 0;
    mem_write  = 0;
    mem_to_reg = 0;
    branch     = 0;
    alu_op     = 3'b000;

    case (opcode)

        // =====================
        // R-TYPE (ADD, SUB, etc.)
        // opcode = 0110011
        // =====================
        7'b0110011: begin
            reg_write = 1;
            alu_src   = 0;

            case ({funct7, funct3})
                10'b0000000_000: alu_op = 3'b000; // ADD
                10'b0100000_000: alu_op = 3'b001; // SUB
                10'b0000000_111: alu_op = 3'b010; // AND
                10'b0000000_110: alu_op = 3'b011; // OR
                10'b0000000_100: alu_op = 3'b100; // XOR
                10'b0000000_010: alu_op = 3'b101; // SLT
                default: alu_op = 3'b000;
            endcase
        end
        // =====================
        // I-TYPE (ADDI)
        // opcode = 0010011
        // =====================
        7'b0010011: begin
   		 reg_write = 1;
   		 alu_src   = 1;

   		 case (funct3)
       			 3'b000: alu_op = 3'b000; // ADDI
       			 3'b111: alu_op = 3'b010; // ANDI
      			 3'b110: alu_op = 3'b011; // ORI
       			 3'b100: alu_op = 3'b100; // XORI
       			 3'b010: alu_op = 3'b101; // SLTI
       			 default: alu_op = 3'b000;
   		 endcase
	end

        // =====================
        // LOAD (LW)
        // opcode = 0000011
        // =====================
        7'b0000011: begin
            reg_write  = 1;
            alu_src    = 1;
            mem_read   = 1;
            mem_to_reg = 1;
            alu_op     = 3'b000; // address calc
        end

        // =====================
        // STORE (SW)
        // opcode = 0100011
        // =====================
        7'b0100011: begin
            alu_src   = 1;
            mem_write = 1;
            alu_op    = 3'b000;
        end

        // =====================
        // BRANCH (BEQ)
        // opcode = 1100011
        // =====================
        7'b1100011: begin
            branch = 1;
            alu_op = 3'b001; // SUB for comparison
        end

        default: begin
            // keep defaults
        end

    endcase
end

endmodule
