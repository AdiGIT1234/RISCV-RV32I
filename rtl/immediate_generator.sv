`timescale 1ns/1ps
`timescale 1ns/1ps
/* verilator lint_off UNUSEDSIGNAL */

module immediate_generator (
    input  logic [31:0] instr,
    input  logic [6:0]  opcode,

    output logic [31:0] immediate
);
    always_comb begin
        case (opcode)

            // ==========================================
            // I-TYPE
            // ADDI, LW
            // immediate = instr[31:20]
            // ==========================================
            7'b0010011,
            7'b0000011: begin
                immediate = {{20{instr[31]}}, instr[31:20]};
            end

            // ==========================================
            // S-TYPE
            // SW
            // immediate = instr[31:25] | instr[11:7]
            // ==========================================
            7'b0100011: begin
                immediate = {
                    {20{instr[31]}},
                    instr[31:25],
                    instr[11:7]
                };
            end

            // ==========================================
            // B-TYPE
            // BEQ
            // immediate =
            // {instr[31], instr[7], instr[30:25],
            //  instr[11:8], 1'b0}
            // ==========================================
            7'b1100011: begin
                immediate = {
                    {19{instr[31]}},
                    instr[31],
                    instr[7],
                    instr[30:25],
                    instr[11:8],
                    1'b0
                };
            end
            // ==========================================
            // J-TYPE
            // JAL
            // immediate =
            // {instr[31], instr[19:12], instr[20],
            //  instr[30:21], 1'b0}
            // ==========================================
            7'b1101111: begin
                immediate = {
                    {11{instr[31]}},
                    instr[31],
                    instr[19:12],
                    instr[20],
                    instr[30:21],
                    1'b0
                };
            end
            // ==========================================
            // U-TYPE
            // LUI, AUIPC
            // immediate = instr[31:12] << 12
            // ==========================================
            7'b0110111,
            7'b0010111: begin
                immediate = {instr[31:12], 12'b0};
            end
	    // ==========================================
            // Unsupported instruction
            // ==========================================
            default: begin
                immediate = 32'd0;
            end

        endcase
    end

endmodule
/* verilator lint_on UNUSEDSIGNAL */
