`timescale 1ns/1ps
`timescale 1ns/1ps
module decoder (
input  logic [31:0] instr,

output logic [6:0]  opcode,
output logic [4:0]  rd,
output logic [2:0]  funct3,
output logic [4:0]  rs1,
output logic [4:0]  rs2,
output logic [6:0]  funct7,
output logic [11:0] system_imm
);

// Extract fields from instruction
assign opcode = instr[6:0];
assign rd     = instr[11:7];
assign funct3 = instr[14:12];
assign rs1    = instr[19:15];
assign rs2    = instr[24:20];
assign funct7 = instr[31:25];
assign system_imm = instr[31:20];
endmodule
