`timescale 1ns/1ps
`timescale 1ns/1ps
module register_file (
input  logic         clk,
input  logic         rst,

// Read ports
input  logic [4:0]   rs1,
input  logic [4:0]   rs2,
output logic [31:0]  read_data1,
output logic [31:0]  read_data2,

// Write port
input  logic         reg_write,
input  logic [4:0]   rd,
input  logic [31:0]  write_data

);

// 32 registers of 32 bits
logic [31:0] registers [31:0];

// -------------------------
// READ LOGIC (combinational)
// -------------------------
assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

// -------------------------
// WRITE LOGIC (sequential)
// -------------------------
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        integer i;
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;
    end
    else begin
        if (reg_write && (rd != 5'd0)) begin
            registers[rd] <= write_data;
        end
    end
end

endmodule
