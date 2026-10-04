module tb_branches;

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
        .IMEM_FILE("programs/branches.hex")
    ) dut (
        .clk                   (clk),
        .rst                   (rst),
        .debug_pc              (debug_pc),
        .debug_instruction     (debug_instruction),
        .debug_alu_result      (debug_alu_result),
        .debug_memory_address  (debug_memory_address),
        .debug_memory_write_data(debug_memory_write_data),
        .debug_memory_read_data(debug_memory_read_data),
        .debug_reg_write       (debug_reg_write),
        .debug_rd              (debug_rd),
        .debug_writeback_data  (debug_writeback_data),
        .debug_mem_read        (debug_mem_read),
        .debug_mem_write       (debug_mem_write),
        .debug_branch_taken    (debug_branch_taken)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #12;
        rst = 0;

        #250;

        $display("");
        $display("========================================");
        $display(" BRANCH INSTRUCTION VERIFICATION");
        $display("========================================");

        if (dut.reg_file.registers[10] !== 32'd2) begin
            $error("BEQ FAILED: x10 = %h, expected 00000002",
                   dut.reg_file.registers[10]);
            $finish;
        end

        if (dut.reg_file.registers[11] !== 32'd2) begin
            $error("BNE FAILED: x11 = %h, expected 00000002",
                   dut.reg_file.registers[11]);
            $finish;
        end

        if (dut.reg_file.registers[12] !== 32'd2) begin
            $error("BLT FAILED: x12 = %h, expected 00000002",
                   dut.reg_file.registers[12]);
            $finish;
        end

        if (dut.reg_file.registers[13] !== 32'd2) begin
            $error("BGE FAILED: x13 = %h, expected 00000002",
                   dut.reg_file.registers[13]);
            $finish;
        end

        if (dut.reg_file.registers[14] !== 32'd2) begin
            $error("BLTU FAILED: x14 = %h, expected 00000002",
                   dut.reg_file.registers[14]);
            $finish;
        end

        if (dut.reg_file.registers[15] !== 32'd2) begin
            $error("BGEU FAILED: x15 = %h, expected 00000002",
                   dut.reg_file.registers[15]);
            $finish;
        end

        $display("");
        $display("TEST PASSED");
        $display("BEQ  : x10 = %h", dut.reg_file.registers[10]);
        $display("BNE  : x11 = %h", dut.reg_file.registers[11]);
        $display("BLT  : x12 = %h", dut.reg_file.registers[12]);
        $display("BGE  : x13 = %h", dut.reg_file.registers[13]);
        $display("BLTU : x14 = %h", dut.reg_file.registers[14]);
        $display("BGEU : x15 = %h", dut.reg_file.registers[15]);
        $display("");

        $finish;
    end

    always @(posedge clk) begin
        #1;
        $display(
            "TRACE: PC=%08h INSTR=%08h BR=%0d RD=x%0d WB=%08h",
            debug_pc,
            debug_instruction,
            debug_branch_taken,
            debug_rd,
            debug_writeback_data
        );
    end

endmodule
