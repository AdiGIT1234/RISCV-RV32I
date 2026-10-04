import uvm_pkg::*;
`include "uvm_macros.svh"

class regfile_monitor extends uvm_monitor;

    `uvm_component_utils(regfile_monitor)

    virtual regfile_if vif;
    uvm_analysis_port #(regfile_sequence_item) analysis_port;

    function new(
        string name = "regfile_monitor",
        uvm_component parent = null
    );
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual regfile_if)::get(
                this, "", "vif", vif
            )) begin
            `uvm_fatal("NOVIF", "regfile_if not found")
        end
    endfunction

    task run_phase(uvm_phase phase);
        regfile_sequence_item item;

        forever begin
            @(posedge vif.clk);

            item = regfile_sequence_item::type_id::create("item");

            item.rs1        = vif.rs1;
            item.rs2        = vif.rs2;
            item.rd         = vif.rd;
            item.write_data = vif.write_data;
            item.reg_write  = vif.reg_write;

            #1;

            item.read_data1 = vif.read_data1;
            item.read_data2 = vif.read_data2;

            analysis_port.write(item);
        end
    endtask

endclass
