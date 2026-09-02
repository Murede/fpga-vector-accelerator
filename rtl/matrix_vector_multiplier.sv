module matrix_multiplier(

    input logic clk,
    
    input logic reset,
    input logic start,

    input logic signed [7:0] a0 [3:0],
    input logic signed [7:0] a1 [3:0],
    input logic signed [7:0] a2 [3:0],
    input logic signed [7:0] a3 [3:0],

    input logic signed [7:0] x0,
    input logic signed [7:0] x1,
    input logic signed [7:0] x2,
    input logic signed [7:0] x3,

    output logic signed [17:0] y0,
    output logic signed [17:0] y1,
    output logic signed [17:0] y2,
    output logic signed [17:0] y3,

    output logic done;
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

    // Selected MAC Operands
    logic signed [7:0] selected_vector; 
    logic signed [7:0] selected_matrix;

    
    // Horizontal Vector Traversal
    logic [1:0] element_index;

    // Vertical Vector Traversal
    logic [1:0] row_index; 

    logic mac_enable;
    logic mac_reset;

    logic [17:0] signed mac_accumulator;

    
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
            vector_index <= 2'd0;
            row_index <= 2'd0; 
        end 
        
        else if (current_state == IDLE && start = 1'b1) begin 
            vector_index <= 2'd0;
            row_index <= 2'd0; 
        end 

        else if (current_state == CLEAR) begin 
            vector_index <= 2'd0; 
        end 

        else if (current_state == MAC) begin
                if (vector_index < 2'd3)
                    vector_index <= vector_index + 2'd1;                
        end

        else if (current_state == STORE) begin 
            if (row_index < 3) 
                row_index <= row_index + 2'd1;
        end 
    end

    // Operand Selection Logic 
    
    // Vector Selector 

    always_comb begin 

        selected_vector = 8'sd0;

        case (vector_index)
            2'd0: selected_vector = x0;
            2'd1: selected_vector = x1;
            2'd2: selected_vector = x2;
            2'd3: selected_vector = x3;
            default: selected_vector = 8'sd0;
        endcase 
    end
    
    // Row Selector 

    always_comb begin 
    
        selected_matrix = 8'sd0;

        case (row_index)
            2'd0: selected_matrix =  a0[vector_index];
            2'd1: selected_matrix =  a1[vector_index];
            2'd2: selected_matrix =  a2[vector_index];
            2'd3: selected_matrix =  a3[vector_index];
            default: selected_matrix = 8'sd0;
        endcase 
    end 

    // MAC Instatiation 
    signed_mac_unit smac_unit(
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

                if (vector_index < 3) 
                    next_state = MAC;
                else
                    next_state = STORE;
            end 

            STORE: begin 

                if (row_index < 3)
                    next_state = CLEAR;
                else 
                    next_state = DONE;
            end 
            
            default: begin
                next_state = IDLE;
            end

        endcase
    end 

    // Seperatley handle DONE to emulate a Moore-style Machine 
    assign done = (current_state == DONE);

endmodule 