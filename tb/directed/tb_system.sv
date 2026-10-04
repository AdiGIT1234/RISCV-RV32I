`timescale 1ns/1ps

module tb_system;

    logic clk;
    logic rst;

    logic [31:0] debug_pc;
    logic [31:0] debug_instruction;
    logic [31:0] debug_alu_result;
    logic [31:0] debug_memory_address;
    logic [31:0] debug_memory_write_data;
    logic [31:0] debug_memory_read_data;
    logic debug_reg_write;
    logic [4:0] debug_rd;
    logic [31:0] debug_writeback_data;
    logic debug_mem_read;
    logic debug_mem_write;
    logic debug_branch_taken;

    riscv_core #(
        .IMEM_FILE("programs/system.hex")
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

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin

        rst = 1'b1;
        #12;
        rst = 1'b0;

        // =========================================
        // FENCE at PC = 0
        // =========================================
        #1;

        if (debug_pc !== 32'h00000000)
            $error("Expected FENCE at PC=0");

        if (debug_instruction !== 32'h0FF0000F)
            $error("Expected FENCE instruction");

        if (!dut.fence)
            $error("FENCE decode failed");

        if (debug_reg_write || debug_mem_read || debug_mem_write)
            $error("FENCE caused architectural write");

        // Advance to ECALL
        @(posedge clk);
        #1;

        // =========================================
        // ECALL at PC = 4
        // =========================================
        if (debug_pc !== 32'h00000004)
            $error("Expected ECALL at PC=4");

        if (debug_instruction !== 32'h00000073)
            $error("Expected ECALL instruction");

        if (!dut.ecall)
            $error("ECALL decode failed");

        if (debug_reg_write || debug_mem_read || debug_mem_write)
            $error("ECALL caused architectural write");

        // Advance to EBREAK
        @(posedge clk);
        #1;

        // =========================================
        // EBREAK at PC = 8
        // =========================================
        if (debug_pc !== 32'h00000008)
            $error("Expected EBREAK at PC=8");

        if (debug_instruction !== 32'h00100073)
            $error("Expected EBREAK instruction");

        if (!dut.ebreak)
            $error("EBREAK decode failed");

        if (debug_reg_write || debug_mem_read || debug_mem_write)
            $error("EBREAK caused architectural write");

        $display("");
        $display("========================================");
        $display(" SYSTEM INSTRUCTION VERIFICATION");
        $display("========================================");
        $display("FENCE  decode : PASS");
        $display("ECALL  decode : PASS");
        $display("EBREAK decode : PASS");
        $display("========================================");
        $display(" SYSTEM TEST PASSED");
        $display("========================================");

        $finish;
    end
endmodule

