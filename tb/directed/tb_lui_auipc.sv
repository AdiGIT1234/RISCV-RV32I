`timescale 1ns/1ps

module tb_lui_auipc;

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
        .IMEM_FILE("programs/lui_auipc.hex")
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

        repeat (8) @(posedge clk);

        $display("");
        $display("========================================");
        $display(" LUI/AUIPC VERIFICATION");
        $display("========================================");

        $display("x1 = %h", dut.reg_file.registers[1]);
        $display("x2 = %h", dut.reg_file.registers[2]);

        if (dut.reg_file.registers[1] !== 32'h12345000)
            $error("LUI failed");

        if (dut.reg_file.registers[2] !== 32'h00001004)
            $error("AUIPC failed");

        $display("========================================");
        $display(" LUI/AUIPC TEST PASSED");
        $display("========================================");

        $finish;
    end

endmodule

