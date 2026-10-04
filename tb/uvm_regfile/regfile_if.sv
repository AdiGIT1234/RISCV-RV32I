interface regfile_if;

    logic        clk;
    logic        rst;

    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;

    logic [31:0] write_data;
    logic        reg_write;

    logic [31:0] read_data1;
    logic [31:0] read_data2;

endinterface
