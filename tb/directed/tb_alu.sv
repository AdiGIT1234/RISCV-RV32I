`timescale 1ns/1ps

module tb_alu;

    logic clk;
    logic rst;

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

    integer write_count;
    integer errors;

    riscv_core #(
        .IMEM_FILE("programs/alu.hex")
    ) dut (
        .clk                     (clk),
        .rst                     (rst),
        .debug_pc                (debug_pc),
        .debug_instruction       (debug_instruction),
        .debug_alu_result        (debug_alu_result),
        .debug_memory_address    (debug_memory_address),
        .debug_memory_write_data (debug_memory_write_data),
        .debug_memory_read_data  (debug_memory_read_data),
        .debug_reg_write         (debug_reg_write),
        .debug_rd                (debug_rd),
        .debug_writeback_data    (debug_writeback_data),
        .debug_mem_read          (debug_mem_read),
        .debug_mem_write         (debug_mem_write),
        .debug_branch_taken      (debug_branch_taken)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        write_count = 0;
        errors = 0;

        repeat (2) @(posedge clk);
        rst = 1'b0;
    end

always @(posedge clk) begin
    #1;

    // Use debug signals for cycle-level visibility.
    $display(
        "TRACE: PC=%08h INSTR=%08h ALU=%08h MEM_ADDR=%08h MEM_WDATA=%08h MEM_RDATA=%08h MEM_R=%b MEM_W=%b BR=%b",
        debug_pc,
        debug_instruction,
        debug_alu_result,
        debug_memory_address,
        debug_memory_write_data,
        debug_memory_read_data,
        debug_mem_read,
        debug_mem_write,
        debug_branch_taken
    );

    if (debug_reg_write && (debug_rd != 5'd0)) begin

        $display(
            "WRITE: RD=x%0d DATA=%08h",
            debug_rd,
            debug_writeback_data
        );

        case (debug_rd)

            5'd1: begin
                if (debug_writeback_data !== 32'd10)
                    errors <= errors + 1;
            end

            5'd2: begin
                if (debug_writeback_data !== 32'd5)
                    errors <= errors + 1;
            end

            5'd3: begin
                if (debug_writeback_data !== 32'd15)
                    errors <= errors + 1;
            end

            5'd4: begin
                if (debug_writeback_data !== 32'd5)
                    errors <= errors + 1;
            end

            5'd5: begin
                if (debug_writeback_data !== 32'd0)
                    errors <= errors + 1;
            end

            5'd6: begin
                if (debug_writeback_data !== 32'd15)
                    errors <= errors + 1;
            end

            5'd7: begin
                if (debug_writeback_data !== 32'd15)
                    errors <= errors + 1;
            end

            5'd8: begin
                if (debug_writeback_data !== 32'd0)
                    errors <= errors + 1;
            end

            default: begin
                $display(
                    "ERROR: Unexpected register write to x%0d",
                    debug_rd
                );
                errors <= errors + 1;
            end

        endcase

        write_count <= write_count + 1;
    end
end
initial begin
    repeat (12) @(posedge clk);
    #1;

    $display("");
    $display("========================================");
    $display(" RV32I ALU TEST");
    $display("========================================");

    if (write_count != 8) begin
        $display(
            "ERROR: Expected 8 register writes, got %0d",
            write_count
        );
        errors = errors + 1;
    end

    if (errors == 0)
        $display("TEST PASSED");
    else
        $display("TEST FAILED: %0d error(s)", errors);

    $display("========================================");

    #1;
    $finish;
end
endmodule
