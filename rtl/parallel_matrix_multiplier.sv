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

    logic signed [DATA_WIDTH-1:0] 
        selected_row [VECTOR_LEN-1:0];

    logic [ROW_INDEX_WIDTH-1:0] row_index;

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

    // Row Selection Logic
    always_comb begin
        for (int i = 0; i < VECTOR_LEN; i = i + 1) begin
            selected_row[i] = a[row_index][i];
        end
    end

    // Dot-Product Datapath Instantiation 
    parallel_dot_product #(
        .DATA_WIDTH(DATA_WIDTH),
        .VECTOR_LEN(VECTOR_LEN),
        .ACC_WIDTH(ACC_WIDTH)
    ) dot_product_unit (
        .a(selected_row),
        .b(x),
        .result(row_result)
    );

    // Next State Logic 
    always_comb begin 
        next_state = current_state;

        case (current_state)

            IDLE: begin 
                if (start)
                    next_state = COMPUTE;
            end 

            COMPUTE: begin 
                next_state = STORE;
            end 

            STORE: begin 
                if (row_index < NUM_ROWS -1)
                    next_state = COMPUTE;
                else
                    next_state = DONE;
            end 

            DONE: begin 
                next_state = IDLE;
            end 

            default: begin 
                next_state = IDLE;
            end 

        endcase 
    end 

    // Output Storage Logic 
    always_ff @(posedge clk) begin 
        if (reset) begin 
            for (int i = 0; i < NUM_ROWS; i = i + 1) begin 
                y[i] <= '0;
            end 
        end 

        else if (current_state == STORE) begin 
            y[row_index] <= row_result;
        end
    end 

    // Done Assertion 
    assign done = (current_state == DONE);


   

endmodule 