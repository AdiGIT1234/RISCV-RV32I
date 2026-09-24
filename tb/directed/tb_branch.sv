`timescale 1ns/1ps

module tb_branch;

    logic clk;
    logic rst;
    /* verilator lint_off UNUSEDSIGNAL */
    logic [31:0] debug_memory_address;
    logic [31:0] debug_memory_write_data;
    logic [31:0] debug_memory_read_data;
    logic        debug_mem_read;
    logic        debug_mem_write;
    /* verilator lint_on UNUSEDSIGNAL */
    logic [31:0] debug_pc;
    logic [31:0] debug_instruction;
    logic [31:0] debug_alu_result;
    logic        debug_reg_write;
    logic [4:0]  debug_rd;
    logic [31:0] debug_writeback_data;
    logic        debug_branch_taken;

    riscv_core #(
        .IMEM_FILE("programs/branch.hex")
    ) dut (
        .clk(clk),
        .rst(rst),
	.debug_memory_address     (debug_memory_address),
	.debug_memory_write_data  (debug_memory_write_data),
	.debug_memory_read_data   (debug_memory_read_data),
	.debug_mem_read           (debug_mem_read),
	.debug_mem_write          (debug_mem_write),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result(debug_alu_result),
        .debug_reg_write(debug_reg_write),
        .debug_rd(debug_rd),
        .debug_writeback_data(debug_writeback_data),
        .debug_branch_taken(debug_branch_taken)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #12;
        rst = 0;

        #100;

        if (dut.reg_file.registers[1] !== 32'd1) begin
            $display("ERROR: x1 = %08h, expected 1",
                     dut.reg_file.registers[1]);
            $finish;
        end

        if (dut.reg_file.registers[2] !== 32'd1) begin
            $display("ERROR: x2 = %08h, expected 1",
                     dut.reg_file.registers[2]);
            $finish;
        end

        if (dut.reg_file.registers[3] !== 32'd0) begin
            $display("ERROR: x3 = %08h, expected 0 (instruction should be skipped)",
                     dut.reg_file.registers[3]);
            $finish;
        end

        if (dut.reg_file.registers[4] !== 32'd99) begin
            $display("ERROR: x4 = %08h, expected 99",
                     dut.reg_file.registers[4]);
            $finish;
        end

        $display("");
        $display("# TEST PASSED");
        $display("BEQ correctly changed the PC and skipped the instruction.");
        $display("");

        $finish;
    end

    always @(posedge clk) begin
        #1;

        $display(
            "TRACE: PC=%08h INSTR=%08h ALU=%08h BR=%b",
            debug_pc,
            debug_instruction,
            debug_alu_result,
            debug_branch_taken
        );

        if (debug_branch_taken) begin
            $display(
                "BRANCH TAKEN: PC=%08h -> target",
                debug_pc
            );
        end

        if (debug_reg_write && (debug_rd != 5'd0)) begin
            $display(
                "WRITE: RD=x%0d DATA=%08h",
                debug_rd,
                debug_writeback_data
            );
        end
    end

endmodule
