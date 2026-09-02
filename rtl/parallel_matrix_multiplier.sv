module parallel_matrix_multiplier #(
    parameter int VECTOR_LEN =4,
    parameter int DATA_WIDTH = 8,
    parameter int NUM_ROWS = 4,
    parameter int ACC_WIDTH = 
    2 * DATA_WIDTH + $clog2(VECTOR_LEN) 
) (

    input logic clk,

    input logic reset,
    input logic start,

    input logic signed [DATA_WIDTH-1:0] a 
        [NUM_ROWS-1:0][VECTOR_LEN-1:0],

    input logic signed [DATA_WIDTH-1:0] x 
        [VECTOR_LEN - 1:0],

    output logic signed [ACC_WIDTH-1:0] y 
        [NUM_ROWS-1:0],

    output logic done
);

    // Omit the vector index as it is getting removed since we will control 
    // operations through using the seperate multipliers
    localparam int ROW_INDEX_WIDTH =
        (NUM_ROWS <= 1) ? 1 : $clog2(NUM_ROWS);

    logic [ROW_INDEX_WIDTH-1:0] row_index;

    localparam int PRODUCT_WIDTH = 2 * DATA_WIDTH;

    logic signed [PRODUCT_WIDTH-1:0]
        product [VECTOR_LEN-1:0];

    logic signed [ACC_WIDTH-1:0] row_result;
    
    // State Register
    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        STORE,
        DONE 
    } state_t;

    state_t current_state;
    state_t next_state;

    // State Register
    always_ff @(posedge clk) begin

        if (reset)
            current_state <= IDLE;
        else 
            current_state <= next_state;
    end 

    // Matrix Travel Logic 
    always_ff @(posedge clk) begin
        if (reset || (current_state == IDLE && start)) begin 
            row_index <= '0; 
        end 

        else if (current_state == STORE) begin 
            if (row_index < NUM_ROWS - 1) 
                row_index <= row_index + 1'b1;
        end 
    end

   

endmodule 