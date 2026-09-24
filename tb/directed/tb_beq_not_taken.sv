`timescale 1ns/1ps

module tb_beq_not_taken;

    logic clk;
    logic rst;

    /* verilator lint_off UNUSEDSIGNAL */
    logic [31:0] debug_pc;
    logic [31:0] debug_instruction;
    logic [31:0] debug_alu_result;
    logic [31:0] debug_memory_address;
    logic [31:0] debug_memory_write_data;
    logic [31:0] debug_memory_read_data;
    logic        debug_reg_write;
    logic [4:0]  debug_rd;
    logic [31:0] debug_writeback_data;
    logic        debug_mem_read;
    logic        debug_mem_write;
    logic        debug_branch_taken;
    /* verilator lint_on UNUSEDSIGNAL */

    riscv_core #(
        .IMEM_FILE("programs/beq_not_taken.hex")
    ) dut (
        .clk(clk),
        .rst(rst),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_alu_result(debug_alu_result),
        .debug_memory_address(debug_memory_address),
        .debug_memory_write_data(debug_memory_write_data),
        .debug_memory_read_data(debug_memory_read_data),
        .debug_reg_write(debug_reg_write),
        .debug_rd(debug_rd),
        .debug_writeback_data(debug_writeback_data),
        .debug_mem_read(debug_mem_read),
        .debug_mem_write(debug_mem_write),
        .debug_branch_taken(debug_branch_taken)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #12;
        rst = 0;

        #100;

        $display("");
        $display("========================================");
        $display(" BEQ NOT-TAKEN TEST");
        $display("========================================");

        if (dut.reg_file.registers[3] === 32'h00000063) begin
            $display("PASS: BEQ not taken, x3 = 99");
            $display("# TEST PASSED");
        end
        else begin
            $display("FAIL: x3 expected 99, got %08h",
                     dut.reg_file.registers[3]);
            $display("# TEST FAILED");
        end

        $finish;
    end

endmodule
