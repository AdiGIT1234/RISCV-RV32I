`timescale 1ns/1ps
/* verilator lint_off DECLFILENAME */
module riscv_core #(
    parameter IMEM_FILE = ""
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
    logic [11:0] system_imm;

    // =========================================================
    // Control Signals
    // =========================================================

    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;

    logic [3:0] alu_op;
    logic [2:0]  branch_type;
    logic [1:0] mem_size;
    logic       load_unsigned;
    logic 	jump;
    logic 	jalr;
    logic 	lui;
    logic 	auipc;
    /* verilator lint_off UNUSEDSIGNAL */
    logic fence;
    logic ecall;
    logic ebreak;
    /* verilator lint_on UNUSEDSIGNAL */
    
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
    /* verilator lint_off UNUSEDSIGNAL */
    logic alu_zero;
    /* verilator lint_on UNUSEDSIGNAL */
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
        .funct7 (funct7),
	.system_imm(system_imm) 
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
        .alu_op    (alu_op),
        .branch_type(branch_type),    
        .mem_size      (mem_size),
        .load_unsigned (load_unsigned),
	.jump(jump),
	.jalr(jalr),
	.lui(lui),
	.auipc(auipc),
	.system_imm(system_imm),
	.fence(fence),
	.ecall(ecall),
	.ebreak(ebreak)	
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

	always_comb begin
    		if (alu_src && (alu_op == 4'b0110 ||
                    		alu_op == 4'b1000 ||
                    		alu_op == 4'b1001))
        		alu_operand_b = {27'b0, immediate[4:0]};
    		else if (alu_src)
        		alu_operand_b = immediate;
    		else
        		alu_operand_b = read_data2;
		end

    // =========================================================
    // ALU
    // =========================================================

    alu arithmetic_logic_unit (
        .operand_a (read_data1),
        .operand_b (alu_operand_b),
        .alu_op    (alu_op),
        .result    (alu_result),
	.zero (alu_zero)
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
        .read_data (memory_read_data),
	.mem_size(mem_size),
        .load_unsigned(load_unsigned)
    );


    // =========================================================
    // Writeback MUX
    // =========================================================

	always_comb begin
    		if (jump)
        		writeback_data = pc_plus_4;
    		else if (lui)
        		writeback_data = immediate;
    		else if (auipc)
        		writeback_data = current_pc + immediate;
    		else if (mem_to_reg)
        		writeback_data = memory_read_data;
    		else
        		writeback_data = alu_result;
	end
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

	always_comb begin
    		branch_taken = 1'b0;

    		if (branch) begin
        		case (branch_type)
            			3'b000: branch_taken = (read_data1 == read_data2); // BEQ
            			3'b001: branch_taken = (read_data1 != read_data2); // BNE
            			3'b010: branch_taken = ($signed(read_data1) < $signed(read_data2)); // BLT
            			3'b011: branch_taken = ($signed(read_data1) >= $signed(read_data2)); // BGE
            			3'b100: branch_taken = ($unsigned(read_data1) < $unsigned(read_data2)); // BLTU
            			3'b101: branch_taken = ($unsigned(read_data1) >= $unsigned(read_data2)); // BGEU
            			default: branch_taken = 1'b0;
        		endcase
    		end
	end
    // =========================================================
    // Next PC MUX
    // =========================================================
	always_comb begin
    		if (jalr)
        		next_pc = (read_data1 + immediate) & 32'hFFFFFFFE;
    		else if (jump)
        		next_pc = current_pc + immediate;
    		else if (branch && branch_taken)
        		next_pc = branch_target;
    		else
    	    		next_pc = pc_plus_4;
	end
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

// ============================================================
// SystemVerilog Assertions
// ============================================================

`ifdef ASSERTIONS
/* verilator lint_off SYNCASYNCNET */
    // --------------------------------------------------------
    // Assertion 1: x0 must always remain zero
    // --------------------------------------------------------
    property p_x0_always_zero;
        @(posedge clk)
        disable iff (rst)
        reg_file.registers[0] == 32'h00000000;
    endproperty

    assert property (p_x0_always_zero)
        else $error("ASSERTION FAILED: x0 is not zero");


    // --------------------------------------------------------
    // Assertion 2: Taken branch selects branch target
    // --------------------------------------------------------
    property p_taken_branch_target;
        @(posedge clk)
        disable iff (rst)
        branch_taken |-> (next_pc == branch_target);
    endproperty

    assert property (p_taken_branch_target)
        else $error(
            "ASSERTION FAILED: taken branch did not select branch target"
        );


    // --------------------------------------------------------
    // Assertion 3: Non-taken path selects PC + 4
    // --------------------------------------------------------
	property p_normal_pc_increment;
  		@(posedge clk) disable iff (rst)
  		(!branch_taken && !jump) |-> (next_pc == pc_plus_4);
	endproperty
    	assert property (p_normal_pc_increment)
        	else $error(
            	"ASSERTION FAILED: PC did not select PC + 4"
        	);

       // ------------------------------------------------
    // JAL: jump target selection
    // ------------------------------------------------
    property p_jal_target;
        @(posedge clk) disable iff (rst)
        (jump && !jalr) |-> (next_pc == current_pc + immediate);
    endproperty

    assert property (p_jal_target)
        else $error("ASSERTION FAILED: JAL target incorrect");


    // ------------------------------------------------
    // JALR: aligned register + immediate target
    // ------------------------------------------------
    property p_jalr_target;
        @(posedge clk) disable iff (rst)
        (jump && jalr) |-> (next_pc == ((read_data1 + immediate) & 32'hFFFFFFFE));
    endproperty

    assert property (p_jalr_target)
        else $error("ASSERTION FAILED: JALR target incorrect");


    // ------------------------------------------------
    // Jumps write PC + 4
    // ------------------------------------------------
    property p_jump_writeback;
        @(posedge clk) disable iff (rst)
        (jump && reg_write) |-> (writeback_data == pc_plus_4);
    endproperty

    assert property (p_jump_writeback)
        else $error("ASSERTION FAILED: jump did not write PC + 4");


    // ------------------------------------------------
    // LUI writeback
    // ------------------------------------------------
    property p_lui_writeback;
        @(posedge clk) disable iff (rst)
        lui |-> (writeback_data == immediate);
    endproperty

    assert property (p_lui_writeback)
        else $error("ASSERTION FAILED: LUI writeback incorrect");


    // ------------------------------------------------
    // AUIPC writeback
    // ------------------------------------------------
    property p_auipc_writeback;
        @(posedge clk) disable iff (rst)
        auipc |-> (writeback_data == current_pc + immediate);
    endproperty

    assert property (p_auipc_writeback)
        else $error("ASSERTION FAILED: AUIPC writeback incorrect");


    // ------------------------------------------------
    // System instructions must not write registers
    // or access data memory
    // ------------------------------------------------
    property p_system_no_side_effects;
        @(posedge clk) disable iff (rst)
        (fence || ecall || ebreak) |->
        (!reg_write && !mem_read && !mem_write);
    endproperty

    assert property (p_system_no_side_effects)
        else $error("ASSERTION FAILED: system instruction caused side effect");
`endif
/* verilator lint_on DECLFILENAME */
endmodule 
