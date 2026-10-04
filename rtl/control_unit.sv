`timescale 1ns/1ps
module control_unit (
input  logic [6:0] opcode,
input  logic [2:0] funct3,
input  logic [6:0] funct7,
input logic [11:0] system_imm,

output logic       reg_write,
output logic       alu_src,
output logic       mem_read,
output logic       mem_write,
output logic       mem_to_reg,
output logic       branch,
output logic [3:0] alu_op,
output logic [2:0] branch_type,
output logic [1:0] mem_size,
output logic       load_unsigned,
output logic       jump,
output logic       jalr,
output logic 	   lui,
output logic 	   auipc,
output logic 	   fence,
output logic 	   ecall,
output logic  	   ebreak
);

always_comb begin
    // Default values 
    
    reg_write  = 0;
    alu_src    = 0;
    mem_read   = 0;
    mem_write  = 0;
    mem_to_reg = 0;
    branch     = 0;
    alu_op     = 4'b0000;
    branch_type = 3'b000;
    mem_size      = 2'b10; // default WORD
    load_unsigned = 1'b0;
    jump = 1'b0;
    jalr = 1'b0;
    lui = 1'b0;
    auipc = 1'b0;
    fence = 1'b0;
    ecall = 1'b0;
    ebreak = 1'b0;
    case (opcode)

        // =====================
        // R-TYPE (ADD, SUB, etc.)
        // opcode = 0110011
        // =====================
        7'b0110011: begin
            reg_write = 1;
            alu_src   = 0;

            case ({funct7, funct3})
                10'b0000000_000: alu_op = 4'b0000; // ADD
                10'b0100000_000: alu_op = 4'b0001; // SUB
    		10'b0000000_111: alu_op = 4'b0010; // AND
    		10'b0000000_110: alu_op = 4'b0011; // OR
    		10'b0000000_100: alu_op = 4'b0100; // XOR
    		10'b0000000_010: alu_op = 4'b0101; // SLT

    		10'b0000000_001: alu_op = 4'b0110; // SLL
    		10'b0000000_011: alu_op = 4'b0111; // SLTU
    		10'b0000000_101: alu_op = 4'b1000; // SRL
    		10'b0100000_101: alu_op = 4'b1001; // SRA

    		default: alu_op = 4'b0000;

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
       			3'b000: alu_op = 4'b0000; // ADDI
			3'b111: alu_op = 4'b0010; // ANDI
			3'b110: alu_op = 4'b0011; // ORI
			3'b100: alu_op = 4'b0100; // XORI
			3'b010: alu_op = 4'b0101; // SLTI
			3'b001: alu_op = 4'b0110; // SLLI

    			3'b101: begin
        			if (funct7 == 7'b0000000)
            				alu_op = 4'b1000; // SRLI
        			else if (funct7 == 7'b0100000)
            				alu_op = 4'b1001; // SRAI
        			else
            				alu_op = 4'b0000;
    			end			
			default: alu_op = 4'b0000;
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
    		alu_op     = 4'b0000;

    		case (funct3)
        		3'b000: begin
        	    		mem_size      = 2'b00; // LB
            			load_unsigned = 1'b0;
	        	end

	        	3'b001: begin
        	    		mem_size      = 2'b01; // LH
            			load_unsigned = 1'b0;
        		end

        		3'b010: begin
            			mem_size      = 2'b10; // LW
         	   		load_unsigned = 1'b0;
        		end
	
        		3'b100: begin
            			mem_size      = 2'b00; // LBU
            			load_unsigned = 1'b1;
        		end

        		3'b101: begin
            			mem_size      = 2'b01; // LHU
            			load_unsigned = 1'b1;
        		end

        		default: begin
            			mem_size      = 2'b10;
            			load_unsigned = 1'b0;
        		end
    		endcase
	end
        // =====================
        // STORE (SW)
        // opcode = 0100011
        // =====================
	7'b0100011: begin
    		alu_src   = 1;
    		mem_write = 1;
    		alu_op    = 4'b0000;

    		case (funct3)
        		3'b000: mem_size = 2'b00; // SB
        		3'b001: mem_size = 2'b01; // SH
        		3'b010: mem_size = 2'b10; // SW
        		default: mem_size = 2'b10;
    		endcase
	end	
        // =====================
        // BRANCH (BEQ)
        // opcode = 1100011
        // =====================
	7'b1100011: begin
    		branch = 1;
    		alu_op = 4'b0001; // SUB

    		case (funct3)
        		3'b000: branch_type = 3'b000; // BEQ
        		3'b001: branch_type = 3'b001; // BNE
        		3'b100: branch_type = 3'b010; // BLT
        		3'b101: branch_type = 3'b011; // BGE
        		3'b110: branch_type = 3'b100; // BLTU
        		3'b111: branch_type = 3'b101; // BGEU
        		default: branch_type = 3'b000;
    		endcase
	end
        default: begin
            // keep defaults
        end
	// JAL
	7'b1101111: begin
    		jump = 1'b1;
    		reg_write = 1'b1;
	end

	// JALR
	7'b1100111: begin
    		jump = 1'b1;
    		jalr = 1'b1;
    		reg_write = 1'b1;
	end
    	// LUI
        7'b0110111: begin
    		lui = 1'b1;
    		reg_write = 1'b1;
	end

	// AUIPC
	7'b0010111: begin
    		auipc = 1'b1;
    		reg_write = 1'b1;
	end
        // SYSTEM / MISC-MEM

        // FENCE
        7'b0001111: begin
            fence = 1'b1;
        end

        // ECALL / EBREAK
        7'b1110011: begin
            if (funct3 == 3'b000) begin
                if (system_imm == 12'h000)
                    ecall = 1'b1;
                else if (system_imm == 12'h001)
                    ebreak = 1'b1;
            end
        end
	endcase
end

endmodule
