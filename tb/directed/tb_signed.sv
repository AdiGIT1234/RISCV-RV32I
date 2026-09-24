 `timescale 1ns/1ps

module tb_signed;

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
        .IMEM_FILE("programs/signed.hex")
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

    integer write_count;

    initial begin
        clk = 0;
        rst = 1;
        write_count = 0;

        #12;
        rst = 0;

        #100;

        $display("");
        $display("========================================");
        $display(" SIGNED / NEGATIVE TEST");
        $display("========================================");

        if (dut.reg_file.registers[1] !== 32'hFFFFFFFB)
            $display("FAIL: x1 expected -5, got %h",
                     dut.reg_file.registers[1]);
        else
            $display("PASS: x1 = -5");

        if (dut.reg_file.registers[2] !== 32'h00000003)
            $display("FAIL: x2 expected 3, got %h",
                     dut.reg_file.registers[2]);
        else
            $display("PASS: x2 = 3");

        if (dut.reg_file.registers[3] !== 32'hFFFFFFFE)
            $display("FAIL: x3 expected -2, got %h",
                     dut.reg_file.registers[3]);
        else
            $display("PASS: x3 = -2");

        if (dut.reg_file.registers[4] !== 32'h00000001)
            $display("FAIL: x4 expected 1, got %h",
                     dut.reg_file.registers[4]);
        else
            $display("PASS: x4 = 1  (SLT)");

        if ((dut.reg_file.registers[1] === 32'hFFFFFFFB) &&
            (dut.reg_file.registers[2] === 32'h00000003) &&
            (dut.reg_file.registers[3] === 32'hFFFFFFFE) &&
            (dut.reg_file.registers[4] === 32'h00000001)) begin
            $display("");
            $display("# TEST PASSED");
        end
        else begin
            $display("");
            $display("# TEST FAILED");
        end

        $finish;
    end

    always @(posedge clk) begin
        #1;

        if (debug_reg_write && (debug_rd != 5'd0)) begin
            write_count <= write_count + 1;

            $display(
                "WRITE: PC=%08h RD=x%0d DATA=%08h",
                debug_pc,
                debug_rd,
                debug_writeback_data
            );
        end
    end

endmodule
