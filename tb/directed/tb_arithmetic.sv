`timescale 1ns/1ps

module tb_arithmetic;

    logic clk;
    logic rst;

    logic [31:0] debug_pc;
    logic        debug_reg_write;
    logic [4:0]  debug_rd;
    logic [31:0] debug_writeback_data;
    logic [31:0] debug_instruction;
    logic [31:0] debug_alu_result;
    logic [31:0] debug_memory_address;
    logic [31:0] debug_memory_write_data;
    logic [31:0] debug_memory_read_data;
    logic        debug_mem_read;
    logic        debug_mem_write;
    logic        debug_branch_taken;
    integer write_count;
    integer errors;

    riscv_core #(
        .IMEM_FILE("programs/arithmetic.hex")
    ) dut (
        .clk                (clk),
        .rst                (rst),

        .debug_pc           (debug_pc),
        .debug_instruction       (debug_instruction),
        .debug_alu_result        (debug_alu_result),
	.debug_memory_address    (debug_memory_address),
	.debug_memory_write_data (debug_memory_write_data),
	.debug_memory_read_data  (debug_memory_read_data),
	.debug_reg_write        (debug_reg_write),
        .debug_rd               (debug_rd),
        .debug_writeback_data   (debug_writeback_data),
	.debug_mem_read          (debug_mem_read),
	.debug_mem_write         (debug_mem_write),
	.debug_branch_taken      (debug_branch_taken)
    );

    // =========================================================
    // Clock
    // =========================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // =========================================================
    // Reset
    // =========================================================

    initial begin
        rst = 1'b1;

        write_count = 0;
        errors = 0;

        repeat (2) @(posedge clk);

        rst = 1'b0;
    end


    // =========================================================
    // Monitor Register Writes
    // =========================================================

always @(posedge clk) begin
    #1;

    $display(
        "TRACE: PC=%08h INSTR=%08h ALU=%08h MEM_ADDR=%08h MEM_WDATA=%08h MEM_RDATA=%08h",
        debug_pc,
        debug_instruction,
        debug_alu_result,
        debug_memory_address,
        debug_memory_write_data,
        debug_memory_read_data
    );

    // Ignore x0 writes. This also avoids depending on rst
    // inside the clocked monitor.
    if (debug_reg_write && (debug_rd != 5'd0)) begin

        write_count <= write_count + 1;

        $display(
            "WRITE: PC=%08h INSTR=%08h ALU=%08h RD=x%0d DATA=%08h MEM_R=%b MEM_W=%b BR=%b",
            debug_pc,
            debug_instruction,
            debug_alu_result,
            debug_rd,
            debug_writeback_data,
            debug_mem_read,
            debug_mem_write,
            debug_branch_taken
        );

            case (write_count)

                0: begin
                    if (debug_rd !== 5'd1 ||
                        debug_writeback_data !== 32'd10) begin

                        $display("ERROR: Expected x1 = 10");
                        errors <= errors + 1;
                    end
                end

                1: begin
                    if (debug_rd !== 5'd2 ||
                        debug_writeback_data !== 32'd20) begin

                        $display("ERROR: Expected x2 = 20");
                        errors <= errors + 1;
                    end
                end

                2: begin
                    if (debug_rd !== 5'd3 ||
                        debug_writeback_data !== 32'd30) begin

                        $display("ERROR: Expected x3 = 30");
                        errors <= errors + 1;
                    end
                end

            endcase
        end
    end


    // =========================================================
    // End Simulation
    // =========================================================

    initial begin
        repeat (8) @(posedge clk);

        #1;

        $display("");
        $display("========================================");
        $display(" RV32I ARITHMETIC TEST");
        $display("========================================");

        if (write_count != 3) begin
            $display(
                "ERROR: Expected 3 register writes, got %0d",
                write_count
            );

            errors <= errors + 1;
        end

        #1;

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED: %0d error(s)", errors);

        $display("========================================");

        $finish;
    end

endmodule
