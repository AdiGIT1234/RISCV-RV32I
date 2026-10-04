import uvm_pkg::*;
`include "uvm_macros.svh"

class regfile_sequence_item extends uvm_sequence_item;

    rand bit [4:0]  rs1;
    rand bit [4:0]  rs2;
    rand bit [4:0]  rd;

    rand bit [31:0] write_data;
    rand bit         reg_write;

    bit [31:0] read_data1;
    bit [31:0] read_data2;

    `uvm_object_utils(regfile_sequence_item)

    function new(string name = "regfile_sequence_item");
        super.new(name);
    endfunction

endclass
