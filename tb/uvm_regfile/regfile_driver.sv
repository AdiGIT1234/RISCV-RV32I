import uvm_pkg::*;
`include "uvm_macros.svh"

class regfile_driver extends uvm_driver #(regfile_sequence_item);

    `uvm_component_utils(regfile_driver)

    virtual regfile_if vif;

    function new(
        string name = "regfile_driver",
        uvm_component parent = null
    );
        super.new(name, parent);
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
            seq_item_port.get_next_item(item);

            @(negedge vif.clk);

            vif.rs1        <= item.rs1;
            vif.rs2        <= item.rs2;
            vif.rd         <= item.rd;
            vif.write_data <= item.write_data;
            vif.reg_write  <= item.reg_write;

            `uvm_info(
                "REGFILE_DRIVER",
                $sformatf(
                    "rs1=%0d rs2=%0d rd=%0d write_data=%08h reg_write=%0b",
                    item.rs1,
                    item.rs2,
                    item.rd,
                    item.write_data,
                    item.reg_write
                ),
                UVM_MEDIUM
            )

            seq_item_port.item_done();
        end
    endtask

endclass
