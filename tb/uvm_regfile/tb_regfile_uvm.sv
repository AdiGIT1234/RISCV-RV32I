`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

module tb_regfile_uvm;

    regfile_if vif();

    // Clock
    initial begin
        vif.clk = 1'b0;
        forever #5 vif.clk = ~vif.clk;
    end

    // Reset
    initial begin
        vif.rst = 1'b1;

        vif.rs1        = 5'd0;
        vif.rs2        = 5'd0;
        vif.rd         = 5'd0;
        vif.write_data = 32'd0;
        vif.reg_write  = 1'b0;

        #20;
        vif.rst = 1'b0;
    end

    // DUT
    register_file dut (
        .clk        (vif.clk),
        .rst        (vif.rst),
        .rs1        (vif.rs1),
        .rs2        (vif.rs2),
        .rd         (vif.rd),
        .write_data (vif.write_data),
        .reg_write  (vif.reg_write),
        .read_data1 (vif.read_data1),
        .read_data2 (vif.read_data2)
    );

    // Pass virtual interface to UVM
    initial begin
        uvm_config_db#(virtual regfile_if)::set(
            null,
            "*",
            "vif",
            vif
        );

        run_test("regfile_test");
    end

endmodule
