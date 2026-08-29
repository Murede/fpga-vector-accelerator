module combinational_vector_alu(

    // Create four parallel ALU lanes

    input  logic [7:0] a0,
    input  logic [7:0] a1,
    input  logic [7:0] a2,
    input  logic [7:0] a3,

    input  logic [7:0] b0,
    input  logic [7:0] b1,
    input  logic [7:0] b2,
    input  logic [7:0] b3,

    input  logic [1:0] opcode,

    output logic [7:0] result0,
    output logic [7:0] result1,
    output logic [7:0] result2,
    output logic [7:0] result3
);
    // Instantiate 4 ALU instances
    alu u_alu0 (
        .a(a0),
        .b(b0),
        .opcode(opcode),
        .result(result0)
    );

    alu u_alu1 (
    .a(a1),
    .b(b1),
    .opcode(opcode),
    .result(result1)
    );

    alu u_alu2 (
    .a(a2),
    .b(b2),
    .opcode(opcode),
    .result(result2)
    );

    alu u_alu3 (
    .a(a3),
    .b(b3),
    .opcode(opcode),
    .result(result3)
    );
endmodule 

