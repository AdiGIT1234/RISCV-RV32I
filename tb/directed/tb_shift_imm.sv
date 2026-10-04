module tb_shift_imm;

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
        .IMEM_FILE("programs/shift_imm.hex")
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

        #100;

        $display("");
        $display("========================================");
        $display(" IMMEDIATE SHIFT VERIFICATION");
        $display("========================================");

        if (dut.reg_file.registers[2] !== 32'h00000014) begin
            $error("SLLI FAILED: x2 = %h, expected 00000014",
                   dut.reg_file.registers[2]);
            $finish;
        end

        if (dut.reg_file.registers[3] !== 32'h00000001) begin
            $error("SRLI FAILED: x3 = %h, expected 00000001",
                   dut.reg_file.registers[3]);
            $finish;
        end

        if (dut.reg_file.registers[5] !== 32'hFFFFFFFE) begin
            $error("SRAI FAILED: x5 = %h, expected FFFFFFFE",
                   dut.reg_file.registers[5]);
            $finish;
        end

        if (dut.reg_file.registers[6] !== 32'h3FFFFFFE) begin
            $error("SRLI negative FAILED: x6 = %h, expected 3FFFFFFE",
                   dut.reg_file.registers[6]);
            $finish;
        end

        $display("");
        $display("TEST PASSED");
        $display("SLLI     : x2 = %h", dut.reg_file.registers[2]);
        $display("SRLI     : x3 = %h", dut.reg_file.registers[3]);
        $display("SRAI     : x5 = %h", dut.reg_file.registers[5]);
        $display("SRLI(-8) : x6 = %h", dut.reg_file.registers[6]);
        $display("");

        $finish;
    end

    always @(posedge clk) begin
        #1;
        $display(
            "TRACE: PC=%08h INSTR=%08h ALU=%08h RD=x%0d WB=%08h",
            debug_pc,
            debug_instruction,
            debug_alu_result,
            debug_rd,
            debug_writeback_data
        );
    end

endmodule

