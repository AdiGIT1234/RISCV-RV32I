import uvm_pkg::*;
`include "uvm_macros.svh"

class regfile_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(regfile_scoreboard)

    uvm_analysis_imp #(regfile_sequence_item, regfile_scoreboard) analysis_export;

    bit [31:0] reference_regs [0:31];

    function new(
        string name = "regfile_scoreboard",
        uvm_component parent = null
    );
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        foreach (reference_regs[i])
            reference_regs[i] = 32'd0;
    endfunction

    function void write(regfile_sequence_item item);

        bit [31:0] expected_read1;
        bit [31:0] expected_read2;

        // Model the synchronous write first.
        // x0 must never change.
        if (item.reg_write && (item.rd != 5'd0))
            reference_regs[item.rd] = item.write_data;

        reference_regs[0] = 32'd0;

        // Reads are asynchronous, so they reflect the current
        // register-file state after the write edge.
        expected_read1 = reference_regs[item.rs1];
        expected_read2 = reference_regs[item.rs2];

        if (item.read_data1 !== expected_read1) begin
            `uvm_error(
                "READ1_MISMATCH",
                $sformatf(
                    "rs1=x%0d expected=%08h actual=%08h",
                    item.rs1,
                    expected_read1,
                    item.read_data1
                )
            )
        end

        if (item.read_data2 !== expected_read2) begin
            `uvm_error(
                "READ2_MISMATCH",
                $sformatf(
                    "rs2=x%0d expected=%08h actual=%08h",
                    item.rs2,
                    expected_read2,
                    item.read_data2
                )
            )
        end

        if ((item.read_data1 === expected_read1) &&
            (item.read_data2 === expected_read2)) begin

            `uvm_info(
                "REGFILE_SB",
                $sformatf(
                    "PASS: rs1=x%0d -> %08h, rs2=x%0d -> %08h",
                    item.rs1,
                    item.read_data1,
                    item.rs2,
                    item.read_data2
                ),
                UVM_MEDIUM
            )
        end

    endfunction

endclass
