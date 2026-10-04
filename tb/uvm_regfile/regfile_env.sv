import uvm_pkg::*;
`include "uvm_macros.svh"

class regfile_env extends uvm_env;

    `uvm_component_utils(regfile_env)

    regfile_agent      agent;
    regfile_scoreboard scoreboard;

    function new(
        string name = "regfile_env",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = regfile_agent::type_id::create("agent", this);
        scoreboard = regfile_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.monitor.analysis_port.connect(
            scoreboard.analysis_export
        );
    endfunction

endclass
