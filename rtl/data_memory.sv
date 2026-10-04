`timescale 1ns/1ps

module data_memory #(
    parameter int MEM_DEPTH = 256
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    input  logic        mem_read,
    input  logic        mem_write,

    // 00 = byte, 01 = halfword, 10 = word
    input  logic [1:0]  mem_size,

    // Used only for loads: 0 = signed, 1 = unsigned
    input  logic        load_unsigned,

    output logic [31:0] read_data
);

    // 256 words = 1024 bytes of data memory
    logic [31:0] memory [0:MEM_DEPTH-1];

    // Byte address -> word index
    logic [31:0] word_address;
    assign word_address = address >> 2;

    // Reset and memory writes
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            integer i;
            for (i = 0; i < MEM_DEPTH; i = i + 1)
                memory[i] = 32'd0;
        end
        else if (mem_write && (word_address < MEM_DEPTH)) begin
            case (mem_size)

                // SB
                2'b00: begin
                    case (address[1:0])
                        2'b00: memory[word_address][7:0]   <= write_data[7:0];
                        2'b01: memory[word_address][15:8]  <= write_data[7:0];
                        2'b10: memory[word_address][23:16] <= write_data[7:0];
                        2'b11: memory[word_address][31:24] <= write_data[7:0];
                    endcase
                end

                // SH
                2'b01: begin
                    if (address[1:0] == 2'b00)
                        memory[word_address][15:0] <= write_data[15:0];
                    else if (address[1:0] == 2'b10)
                        memory[word_address][31:16] <= write_data[15:0];
                end

                // SW
                2'b10: begin
                    memory[word_address] <= write_data;
                end

                default: begin
                    // No operation
                end

            endcase
        end
    end

    // Combinational memory read
    always_comb begin
        read_data = 32'd0;

        if (mem_read && (word_address < MEM_DEPTH)) begin
            case (mem_size)

                // LB / LBU
                2'b00: begin
                    case (address[1:0])

                        2'b00: begin
                            if (load_unsigned)
                                read_data = {24'd0, memory[word_address][7:0]};
                            else
                                read_data = {{24{memory[word_address][7]}},
                                             memory[word_address][7:0]};
                        end

                        2'b01: begin
                            if (load_unsigned)
                                read_data = {24'd0, memory[word_address][15:8]};
                            else
                                read_data = {{24{memory[word_address][15]}},
                                             memory[word_address][15:8]};
                        end

                        2'b10: begin
                            if (load_unsigned)
                                read_data = {24'd0, memory[word_address][23:16]};
                            else
                                read_data = {{24{memory[word_address][23]}},
                                             memory[word_address][23:16]};
                        end

                        2'b11: begin
                            if (load_unsigned)
                                read_data = {24'd0, memory[word_address][31:24]};
                            else
                                read_data = {{24{memory[word_address][31]}},
                                             memory[word_address][31:24]};
                        end

                    endcase
                end

                // LH / LHU
                2'b01: begin
                    if (address[1:0] == 2'b00) begin
                        if (load_unsigned)
                            read_data = {16'd0, memory[word_address][15:0]};
                        else
                            read_data = {{16{memory[word_address][15]}},
                                         memory[word_address][15:0]};
                    end
                    else if (address[1:0] == 2'b10) begin
                        if (load_unsigned)
                            read_data = {16'd0, memory[word_address][31:16]};
                        else
                            read_data = {{16{memory[word_address][31]}},
                                         memory[word_address][31:16]};
                    end
                end

                // LW
                2'b10: begin
                    read_data = memory[word_address];
                end

                default: begin
                    read_data = 32'd0;
                end

            endcase
        end
    end

endmodule
