module topmodule #(
    parameter int DATA_WIDTH = 8,
    parameter int VECTOR_LEN = 4,
    parameter nt NUM_ROWS = 4,
    paramerer int ACC_WIDTH =
        (2 * DATA_WIDTH) + $clog2(VECTOR_LEN)
) (
    // Control Inputs 
    input logic clk,
    input logic reset,
    input logic start,

    input logic signed [DATA_WIDTH-1:0] a
        [NUM_ROWS-1:0][VECTOR_LEN-1:0],

    input logic signed [DATA_WIDTH-1:0] x
        [VECTOR_LEN-1:0],

    output logic signed [DATA_WIDTH-1:0] y
        [NUM_ROWS-1:0],
)