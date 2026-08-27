module registered_alu (
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [1:0] opcode,
    output logic [7:0] result,
    output logic       done
);

    // Registers that store the inputs for the active operation
    logic [7:0] a_reg;
    logic [7:0] b_reg;
    logic [1:0] opcode_reg;

    // Combinational result produced by the ALU
    logic [7:0] alu_result;

    // Tracks whether an operation is currently in progress
    logic busy;

    // Existing combinational ALU instance
    alu u_alu (
        .a(a_reg),
        .b(b_reg),
        .opcode(opcode_reg),
        .result(alu_result)
    );

    // Sequential controller/register logic
    always_ff @(posedge clk) begin

        // done is normally low and only pulses high
        // when an operation completes
        done <= 1'b0;

        // Case 1: synchronous reset
        if (reset) begin
            a_reg      <= 8'd0;
            b_reg      <= 8'd0;
            opcode_reg <= 2'b00;
            busy       <= 1'b0;
            result     <= 8'd0;
            done       <= 1'b0;
        end

        // Case 2: accept a new operation
        else if (!busy && start) begin
            a_reg      <= a;
            b_reg      <= b;
            opcode_reg <= opcode;
            busy       <= 1'b1;
        end

        // Case 3: complete the active operation
        else if (busy) begin
            result <= alu_result;
            busy   <= 1'b0;
            done   <= 1'b1;
        end

    end

endmodule