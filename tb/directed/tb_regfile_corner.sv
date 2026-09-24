`timescale 1ns/1ps

module tb_regfile_corner;

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
        .IMEM_FILE("programs/regfile_corner.hex")
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

        if (debug_reg_write) begin
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
        $display(" REGISTER FILE CORNER CASE TEST");
        $display("========================================");

        if (dut.reg_file.registers[0] !== 32'h00000000) begin
            $display("FAIL: x0 changed! = %08h",
                     dut.reg_file.registers[0]);
        end
        else begin
            $display("PASS: x0 remains 0");
        end

        if (dut.reg_file.registers[1] !== 32'h00000005) begin
            $display("FAIL: x1 expected 5, got %08h",
                     dut.reg_file.registers[1]);
        end
        else begin
            $display("PASS: x1 = 5");
        end

        if (dut.reg_file.registers[2] !== 32'h00000005) begin
            $display("FAIL: x2 expected 5, got %08h",
                     dut.reg_file.registers[2]);
        end
        else begin
            $display("PASS: x2 = 5");
        end

        if (dut.reg_file.registers[3] !== 32'h00000000) begin
            $display("FAIL: x3 expected 0, got %08h",
                     dut.reg_file.registers[3]);
        end
        else begin
            $display("PASS: x3 = 0 after subtraction");
        end

        if ((dut.reg_file.registers[0] === 32'h00000000) &&
            (dut.reg_file.registers[1] === 32'h00000005) &&
            (dut.reg_file.registers[2] === 32'h00000005) &&
            (dut.reg_file.registers[3] === 32'h00000000)) begin

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

