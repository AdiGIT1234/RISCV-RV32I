module tb_shift_rtype;

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
        .IMEM_FILE("programs/shift_rtype.hex")
    ) dut (
        .clk                  (clk),
        .rst                  (rst),
        .debug_pc             (debug_pc),
        .debug_instruction    (debug_instruction),
        .debug_alu_result     (debug_alu_result),
        .debug_memory_address (debug_memory_address),
        .debug_memory_write_data(debug_memory_write_data),
        .debug_memory_read_data(debug_memory_read_data),
        .debug_reg_write      (debug_reg_write),
        .debug_rd             (debug_rd),
        .debug_writeback_data (debug_writeback_data),
        .debug_mem_read      (debug_mem_read),
        .debug_mem_write     (debug_mem_write),
        .debug_branch_taken  (debug_branch_taken)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        #12;
        rst = 0;

        #120;

        $display("");
        $display("========================================");
        $display(" R-TYPE SHIFT INSTRUCTION VERIFICATION");
        $display("========================================");

        // SLL: 5 << 2 = 20
        if (dut.reg_file.registers[3] !== 32'd20) begin
            $error("SLL FAILED: x3 = %h, expected 00000014",
                   dut.reg_file.registers[3]);
            $finish;
        end

        // SLTU: 5 < 2 = false
        if (dut.reg_file.registers[4] !== 32'd0) begin
            $error("SLTU FAILED: x4 = %h, expected 00000000",
                   dut.reg_file.registers[4]);
            $finish;
        end

        // SRL: 5 >> 2 = 1
        if (dut.reg_file.registers[5] !== 32'd1) begin
            $error("SRL FAILED: x5 = %h, expected 00000001",
                   dut.reg_file.registers[5]);
            $finish;
        end

        // SRA: -8 >>> 2 = -2
        if (dut.reg_file.registers[8] !== 32'hFFFFFFFE) begin
            $error("SRA FAILED: x8 = %h, expected FFFFFFFE",
                   dut.reg_file.registers[8]);
            $finish;
        end

        // SRL: -8 >> 2 = 0x3FFFFFFE
        if (dut.reg_file.registers[9] !== 32'h3FFFFFFE) begin
            $error("SRL negative FAILED: x9 = %h, expected 3FFFFFFE",
                   dut.reg_file.registers[9]);
            $finish;
        end

        $display("");
        $display("TEST PASSED");
        $display("SLL  : x3 = %h", dut.reg_file.registers[3]);
        $display("SLTU : x4 = %h", dut.reg_file.registers[4]);
        $display("SRL  : x5 = %h", dut.reg_file.registers[5]);
        $display("SRA  : x8 = %h", dut.reg_file.registers[8]);
        $display("SRL(-8): x9 = %h", dut.reg_file.registers[9]);
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
