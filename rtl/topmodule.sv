module topmodule #(
    parameter int DATA_WIDTH = 8,
    parameter int VECTOR_LEN = 4,
    parameter int NUM_ROWS = 4,
    parameter int ACC_WIDTH =
        (2 * DATA_WIDTH) + $clog2(VECTOR_LEN)
) (
    // Control Inputs 

    input logic clk,
    input logic reset,
    input logic start,

    // Data Inputs 

    input logic signed [DATA_WIDTH-1:0] a
        [NUM_ROWS-1:0][VECTOR_LEN-1:0],

    input logic signed [DATA_WIDTH-1:0] x
        [VECTOR_LEN-1:0],

    // Data Output 
    output logic signed [ACC_WIDTH-1:0] y
        [NUM_ROWS-1:0],
    
    // Control Output 
    output logic done
);

    // Parallel Matrix Multiplier Instatiation 

    parallel_matrix_multiplier # (
        .DATA_WIDTH(DATA_WIDTH),
        .VECTOR_LEN(VECTOR_LEN),
        .NUM_ROWS(NUM_ROWS),
        .ACC_WIDTH(ACC_WIDTH)
    ) parallel_mm_unit (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .a(a),
        .x(x),
        .y(y),
    );
endmodule