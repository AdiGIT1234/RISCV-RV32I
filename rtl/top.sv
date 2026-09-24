`timescale 1ns/1ps
/* verilator lint_off DECLFILENAME */
module riscv_core #(
    parameter string IMEM_FILE = ""
)(
    input  logic        clk,
    input  logic        rst,

    output logic [31:0] debug_pc,
    output logic [31:0] debug_instruction,
    output logic [31:0] debug_alu_result,
    output logic [31:0] debug_memory_address,
    output logic [31:0] debug_memory_write_data,
    output logic [31:0] debug_memory_read_data,
    output logic        debug_reg_write,
    output logic [4:0]  debug_rd,
    output logic [31:0] debug_writeback_data,
    output logic        debug_mem_read,
    output logic        debug_mem_write,
    output logic        debug_branch_taken
);

    // =========================================================
    // PC / Instruction Fetch
    // =========================================================

    logic [31:0] current_pc;
    logic [31:0] next_pc;
    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;

    logic [31:0] instruction;

    // =========================================================
    // Instruction Decode
    // =========================================================

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;

    // =========================================================
    // Control Signals
    // =========================================================

    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;

    logic [2:0] alu_op;

    // =========================================================
    // Register File
    // =========================================================

    logic [31:0] read_data1;
    logic [31:0] read_data2;
    logic [31:0] writeback_data;

    // =========================================================
    // Immediate
    // =========================================================

    logic [31:0] immediate;

    // =========================================================
    // ALU
    // =========================================================

    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic        alu_zero;

    // =========================================================
    // Data Memory
    // =========================================================

    logic [31:0] memory_read_data;

    // =========================================================
    // Branch Control
    // =========================================================

    logic branch_taken;


    // =========================================================
    // PC
    // =========================================================

    pc program_counter (
        .clk        (clk),
        .rst        (rst),
        .next_pc    (next_pc),
        .current_pc (current_pc)
    );


    // =========================================================
    // Instruction Memory
    // =========================================================

    instruction_memory #(
        .MEM_DEPTH (256),
        .INIT_FILE(IMEM_FILE)
    ) instruction_mem (
        .address    (current_pc),
        .instruction(instruction)
    );


    // =========================================================
    // Decoder
    // =========================================================

    decoder instruction_decoder (
        .instr  (instruction),
        .opcode (opcode),
        .rd     (rd),
        .funct3 (funct3),
        .rs1    (rs1),
        .rs2    (rs2),
        .funct7 (funct7)
    );


    // =========================================================
    // Control Unit
    // =========================================================

    control_unit control (
        .opcode    (opcode),
        .funct3    (funct3),
        .funct7    (funct7),
        .reg_write (reg_write),
        .alu_src   (alu_src),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .mem_to_reg(mem_to_reg),
        .branch    (branch),
        .alu_op    (alu_op)
    );


    // =========================================================
    // Register File
    // =========================================================

    register_file reg_file ( 
        .clk        (clk),
        .rst        (rst),
        .rs1        (rs1),
        .rs2        (rs2),
        .read_data1 (read_data1),
        .read_data2 (read_data2),
        .reg_write  (reg_write),
        .rd         (rd),
        .write_data (writeback_data)
    );


    // =========================================================
    // Immediate Generator
    // =========================================================

    immediate_generator imm_gen (
        .instr     (instruction),
        .opcode    (opcode),
        .immediate (immediate)
    );


    // =========================================================
    // ALU Operand B MUX
    // =========================================================

    assign alu_operand_b = alu_src ? immediate : read_data2;


    // =========================================================
    // ALU
    // =========================================================

    alu arithmetic_logic_unit (
        .operand_a (read_data1),
        .operand_b (alu_operand_b),
        .alu_op    (alu_op),
        .result    (alu_result),
        .zero      (alu_zero)
    );


    // =========================================================
    // Data Memory
    // =========================================================

    data_memory #(
        .MEM_DEPTH (256)
    ) data_mem (
        .clk       (clk),
        .rst       (rst),
        .address   (alu_result),
        .write_data(read_data2),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .read_data (memory_read_data)
    );


    // =========================================================
    // Writeback MUX
    // =========================================================

    assign writeback_data =
        mem_to_reg ? memory_read_data : alu_result;


    // =========================================================
    // PC + 4
    // =========================================================

    assign pc_plus_4 = current_pc + 32'd4;


    // =========================================================
    // Branch Target
    // =========================================================

    assign branch_target = current_pc + immediate;


    // =========================================================
    // Branch Decision
    // =========================================================

    assign branch_taken = branch && alu_zero;


    // =========================================================
    // Next PC MUX
    // =========================================================

    assign next_pc =
        branch_taken ? branch_target : pc_plus_4;
    // =========================================================
    // Debug / Verification Outputs
    // =========================================================

    assign debug_pc                = current_pc;
    assign debug_instruction       = instruction;
    assign debug_alu_result        = alu_result;
    assign debug_memory_address    = alu_result;
    assign debug_memory_write_data = read_data2;
    assign debug_memory_read_data  = memory_read_data;
    assign debug_reg_write         = reg_write;
    assign debug_rd                = rd;
    assign debug_writeback_data    = writeback_data;
    assign debug_mem_read          = mem_read; 
    assign debug_mem_write         = mem_write;
    assign debug_branch_taken      = branch_taken;
endmodule
/* verilator lint_on DECLFILENAME */
