`timescale 1ns/1ps

module tb_memory_width;

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
        .IMEM_FILE("programs/memory_width.hex")
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

        repeat (20) @(posedge clk);

        $display("");
        $display("========================================");
        $display(" MEMORY WIDTH VERIFICATION");
        $display("========================================");

        $display("x2 = %h", dut.reg_file.registers[2]);
        $display("x3 = %h", dut.reg_file.registers[3]);
        $display("x5 = %h", dut.reg_file.registers[5]);
        $display("x7 = %h", dut.reg_file.registers[7]);
        $display("x8 = %h", dut.reg_file.registers[8]);
        $display("x9 = %h", dut.reg_file.registers[9]);

        if (dut.reg_file.registers[2]  !== 32'h000000FF) $error("LBU failed");
        if (dut.reg_file.registers[3]  !== 32'hFFFFFFFF) $error("LB failed");
        if (dut.reg_file.registers[5]  !== 32'h0000007F) $error("LB byte 1 failed");
        if (dut.reg_file.registers[7]  !== 32'h0000FFFE) $error("LHU failed");
        if (dut.reg_file.registers[8]  !== 32'hFFFFFFFE) $error("LH failed");
        if (dut.reg_file.registers[9]  !== 32'hFFFE7FFF) $error("LW failed");

        $display("========================================");
        $display(" MEMORY WIDTH TEST PASSED");
        $display("========================================");

        $finish;
    end

endmodule

