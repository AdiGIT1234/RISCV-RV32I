`timescale 1ns/1ps

module tb_memory;

    logic clk;
    logic rst;

    // =========================================================
    // DUT debug signals
    // =========================================================

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
    integer errors;
    integer write_count;

    // =========================================================
    // DUT
    // =========================================================
    riscv_core #(
        .IMEM_FILE("programs/memory.hex")
    ) dut (
        .clk                    (clk),
        .rst                    (rst),

        .debug_pc               (debug_pc),
        .debug_instruction      (debug_instruction),
        .debug_alu_result       (debug_alu_result),
        .debug_memory_address   (debug_memory_address),
        .debug_memory_write_data(debug_memory_write_data),
        .debug_memory_read_data (debug_memory_read_data),
        .debug_reg_write        (debug_reg_write),
        .debug_rd               (debug_rd),
        .debug_writeback_data   (debug_writeback_data),
        .debug_mem_read         (debug_mem_read),
        .debug_mem_write        (debug_mem_write),
	.debug_branch_taken (debug_branch_taken)
    );

    // =========================================================
    // Clock
    // =========================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // Reset
    // =========================================================

    initial begin
        rst = 1;
        errors = 0;
        write_count = 0;

        #12;
        rst = 0;
    end

    // =========================================================
    // Monitor memory transactions
    // =========================================================

    always @(posedge clk) begin
        #1;

        if (debug_mem_write) begin
            $display(
                "STORE: PC=%08h ADDR=%08h DATA=%08h",
                debug_pc,
                debug_memory_address,
                debug_memory_write_data
            );

            if (debug_memory_address !== 32'd0) begin
                $display("ERROR: Expected store address 0, got %08h",
                         debug_memory_address);
                errors <= errors + 1;
            end

            if (debug_memory_write_data !== 32'd42) begin
                $display("ERROR: Expected store data 42, got %08h",
                         debug_memory_write_data);
                errors <= errors + 1;
            end
        end

        if (debug_mem_read) begin
            $display(
                "LOAD:  PC=%08h ADDR=%08h DATA=%08h",
                debug_pc,
                debug_memory_address,
                debug_memory_read_data
            );

            if (debug_memory_address !== 32'd0) begin
                $display("ERROR: Expected load address 0, got %08h",
                         debug_memory_address);
                errors <= errors + 1;
            end

            if (debug_memory_read_data !== 32'd42) begin
                $display("ERROR: Expected loaded data 42, got %08h",
                         debug_memory_read_data);
                errors <= errors + 1;
            end
        end

        if (debug_reg_write && (debug_rd != 5'd0)) begin
            write_count <= write_count + 1;

            $display(
                "WRITE: RD=x%0d DATA=%08h",
                debug_rd,
                debug_writeback_data
            );

            // First write: x1 = 42
            // Second write: x2 = 42
            case (write_count)
                0: begin
                    if (debug_rd !== 5'd1 ||
                        debug_writeback_data !== 32'd42) begin
                        $display("ERROR: Expected x1 = 42");
                        errors <= errors + 1;
                    end
                end

                1: begin
                    if (debug_rd !== 5'd2 ||
                        debug_writeback_data !== 32'd42) begin
                        $display("ERROR: Expected x2 = 42");
                        errors <= errors + 1;
                    end
                end

                default: begin
                    $display("ERROR: Unexpected register write");
                    errors <= errors + 1;
                end
            endcase
        end
    end

// =========================================================
// Trace
// =========================================================

always @(posedge clk) begin
    #1;

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
end
    // =========================================================
    // Final result
    // =========================================================

    initial begin
        repeat (8) @(posedge clk);
        #1;

        $display("");
        $display("========================================");
        $display(" RV32I MEMORY TEST");
        $display("========================================");

        if (write_count != 2) begin
            $display(
                "ERROR: Expected 2 register writes, got %0d",
                write_count
            );
            errors <= errors + 1;
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
