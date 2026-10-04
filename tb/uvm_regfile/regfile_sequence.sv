import uvm_pkg::*;
`include "uvm_macros.svh"

class regfile_sequence extends uvm_sequence #(regfile_sequence_item);

    `uvm_object_utils(regfile_sequence)

    function new(string name = "regfile_sequence");
        super.new(name);
    endfunction

    task body();
        regfile_sequence_item item;

        // Write x1 = 0x12345678
        item = regfile_sequence_item::type_id::create("write_x1");
        start_item(item);
        item.rs1        = 5'd1;
        item.rs2        = 5'd0;
        item.rd         = 5'd1;
        item.write_data = 32'h12345678;
        item.reg_write  = 1'b1;
        finish_item(item);

        // Write x2 = 0xA5A5A5A5
        item = regfile_sequence_item::type_id::create("write_x2");
        start_item(item);
        item.rs1        = 5'd2;
        item.rs2        = 5'd1;
        item.rd         = 5'd2;
        item.write_data = 32'hA5A5A5A5;
        item.reg_write  = 1'b1;
        finish_item(item);

        // Read x1 and x2 simultaneously
        item = regfile_sequence_item::type_id::create("read_x1_x2");
        start_item(item);
        item.rs1        = 5'd1;
        item.rs2        = 5'd2;
        item.rd         = 5'd0;
        item.write_data = 32'd0;
        item.reg_write  = 1'b0;
        finish_item(item);

        // Attempt to write x0
        item = regfile_sequence_item::type_id::create("write_x0");
        start_item(item);
        item.rs1        = 5'd0;
        item.rs2        = 5'd0;
        item.rd         = 5'd0;
        item.write_data = 32'hFFFFFFFF;
        item.reg_write  = 1'b1;
        finish_item(item);

        // Verify x0 remains zero
        item = regfile_sequence_item::type_id::create("read_x0");
        start_item(item);
        item.rs1        = 5'd0;
        item.rs2        = 5'd1;
        item.rd         = 5'd0;
        item.write_data = 32'd0;
        item.reg_write  = 1'b0;
        finish_item(item);

    endtask

endclass
