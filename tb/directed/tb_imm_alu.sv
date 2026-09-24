`timescale 1ns/1ps

module tb_imm_alu;

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
        .IMEM_FILE("programs/imm_alu.hex")
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

    always @(posedge clk) begin
        #1;

        if (debug_reg_write && (debug_rd != 5'd0)) begin
            $display(
                "WRITE: PC=%08h RD=x%0d DATA=%08h",
                debug_pc,
                debug_rd,
                debug_writeback_data
            );
        end
    end

    initial begin
        clk = 0;
        rst = 1;

        #12;
        rst = 0;

        #100;

        $display("");
        $display("========================================");
        $display(" IMMEDIATE ALU TEST");
        $display("========================================");

        if (dut.reg_file.registers[1] !== 32'h0000000F)
            $display("FAIL: x1 expected 15, got %08h",
                     dut.reg_file.registers[1]);
        else
            $display("PASS: x1 = 15");

        if (dut.reg_file.registers[2] !== 32'h0000000A)
            $display("FAIL: x2 expected 10, got %08h",
                     dut.reg_file.registers[2]);
        else
            $display("PASS: ANDI x2 = 10");

        if (dut.reg_file.registers[3] !== 32'h0000000F)
            $display("FAIL: x3 expected 15, got %08h",
                     dut.reg_file.registers[3]);
        else
            $display("PASS: ORI x3 = 15");

        if (dut.reg_file.registers[4] !== 32'h00000000)
            $display("FAIL: x4 expected 0, got %08h",
                     dut.reg_file.registers[4]);
        else
            $display("PASS: XORI x4 = 0");

        if (dut.reg_file.registers[5] !== 32'h00000000)
            $display("FAIL: x5 expected 0, got %08h",
                     dut.reg_file.registers[5]);
        else
            $display("PASS: SLTI x5 = 0");

        if (dut.reg_file.registers[6] !== 32'h00000000)
            $display("FAIL: x6 expected 0, got %08h",
                     dut.reg_file.registers[6]);
        else
            $display("PASS: SLTI x6 = 0 for 15 < -1");

        if ((dut.reg_file.registers[1] === 32'h0000000F) &&
            (dut.reg_file.registers[2] === 32'h0000000A) &&
            (dut.reg_file.registers[3] === 32'h0000000F) &&
            (dut.reg_file.registers[4] === 32'h00000000) &&
            (dut.reg_file.registers[5] === 32'h00000000) &&
            (dut.reg_file.registers[6] === 32'h00000000)) begin

            $display("");
            $display("# TEST PASSED");
        end
        else begin
            $display("");
            $display("# TEST FAILED");
        end

        $finish;
    end

endmodule
