module matrix_multiplier #(
    parameter int DATA_WIDTH = 8,
    parameter int VECTOR_LEN = 4,
    parameter int NUM_ROWS = 4,
    parameter int ACC_WIDTH = 
        (2* DATA_WIDTH) + $clog2(VECTOR_LEN)
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

    // State definitions 
    typedef enum logic [2:0]{
        IDLE,
        CLEAR,
        MAC,
        STORE,
        DONE 
    } state_t;

    state_t current_state; 
    state_t next_state; 

    // Parametrized Parameters 
    localparam int VECTOR_INDEX_WIDTH =
        (VECTOR_LEN <= 1) ? 1 : $clog2(VECTOR_LEN);

    localparam int ROW_INDEX_WIDTH =
        (NUM_ROWS <= 1) ? 1 : $clog2(NUM_ROWS);

    // Selected MAC Operands
    logic signed [DATA_WIDTH-1:0] selected_vector; 
    logic signed [DATA_WIDTH-1:0] selected_matrix;

    logic [VECTOR_INDEX_WIDTH-1:0] vector_index;
    logic [ROW_INDEX_WIDTH-1:0] row_index;

    logic signed [ACC_WIDTH-1:0] mac_accumulator;

    logic mac_enable;
    logic mac_reset;

    
    // State Register 
    always_ff @(posedge clk) begin 
        if (reset)
            current_state <= IDLE;
        else 
            current_state <= next_state;
    end 

    // Matrix Traveral Logic  
    always_ff @(posedge clk) begin 
        if (reset) begin 
            vector_index <= '0;
            row_index <= '0; 
        end 
        
        else if (current_state == IDLE && start) begin 
            vector_index <= '0;
            row_index <= '0; 
        end 

        else if (current_state == CLEAR) begin 
            vector_index <= '0; 
        end 

        else if (current_state == MAC) begin
                if (vector_index < VECTOR_LEN - 1)
                    vector_index <= vector_index + 1'b1;                
        end

        else if (current_state == STORE) begin 
            if (row_index < NUM_ROWS- 1) 
                row_index <= row_index + 1'b1;
        end 
    end

    // Operand Selection Logic 
    
    // Vector Selector 

    always_comb begin 
        selected_vector = x[vector_index];
    end
    
    // Row Selector 

    always_comb begin 
        selected_matrix = a[row_index][vector_index]; 
    end 

    // MAC Instatiation 
    signed_mac_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
        ) smac_unit (
        .clk(clk),
        .reset(mac_reset),
        .en(mac_enable),

        .a(selected_matrix),
        .b(selected_vector),

        .accumulator(mac_accumulator)
    );

    // Next-State Logic 
    always_comb begin 

        next_state = current_state;

        case (current_state)

            IDLE: begin 

                if (start)
                    next_state = CLEAR;
                end

            CLEAR: begin 
                next_state = MAC;
            end  

            MAC: begin

                if (vector_index < VECTOR_LEN - 1) 
                    next_state = MAC;
                else
                    next_state = STORE;
            end 

            STORE: begin 

                if (row_index < NUM_ROWS - 1)
                    next_state = CLEAR;
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
    
    // MAC Control Logic 
    always_comb begin 

        mac_reset = reset; 
        mac_enable = 1'b0;
        
        case (current_state)

            CLEAR: begin 
                mac_reset = 1'b1;
            end 

            MAC:begin 
                mac_enable = 1'b1;
            end 

            default: begin 
            end
        endcase 
    end 

    // Output Storage Logic 

    integer i;

    always_ff @(posedge clk) begin  
        if (reset) begin 
            for (i = 0; i < NUM_ROWS; i = i + 1) begin 
                y[i] <= '0;
            end 
        end 

        else if (current_state == STORE) begin 
                y[row_index] <= mac_accumulator;
        end 
    end 
    
    // Done Assertion
    assign done = (current_state == DONE);
endmodule 