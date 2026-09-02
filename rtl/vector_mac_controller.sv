module mac_controller(

    input logic clk,

    input logic reset,
    input logic start,

    input logic [7:0] a0,
    input logic [7:0] a1,
    input logic [7:0] a2,
    input logic [7:0] a3,

    input logic [7:0] b0,
    input logic [7:0] b1,
    input logic [7:0] b2,
    input logic [7:0] b3,

    output logic [17:0] result,
    output logic done 
);

    typedef enum logic [1:0] {
        IDLE,
        CLEAR,
        MAC,
        DONE
    }   state_t;

    state_t current_state;
    state_t next_state; 

    logic [1:0] index; 

    logic [7:0] selected_a;
    logic [7:0] selected_b;

    logic mac_enable;
    logic mac_reset;  

    logic [17:0] mac_accumulator; 


    // State Register 
    always_ff @(posedge clk) begin 

        if (reset)
            current_state <= IDLE;
        else 
            current_state <= next_state;
    end

    // Index Counter
    always_ff @(posedge clk) begin 
        if (reset)
            index <= 2'd0;

        else if (current_state == CLEAR) 
            index <= 2'd0;

        else if (current_state == MAC) begin 
            if(index < 2'd3)
                index <= index + 1;
        end
    end

    // Input Selection MUX
    always_comb begin
        case (index)
            2'b00:  begin 
                selected_a = a0;
                selected_b = b0;
            end

            2'b01: begin 
                selected_a = a1;
                selected_b = b1;
            end

            2'b10: begin
                selected_a = a2;
                selected_b = b2;
            end

            2'b11: begin  
                selected_a = a3;
                selected_b = b3;
            end

            default: begin 
                selected_a = 8'd0;
                selected_b = 8'd0;
            end
        endcase
    end 

    // Instatiate the mac_unit inside the controller
    mac_unit mac(
        .clk(clk),
        .reset(mac_reset),
        .en(mac_enable),
        .a(selected_a),
        .b(selected_b),
        .accumulator(mac_accumulator)
    );  

    // Next State Logic 

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
                if (index == 2'd3)
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

    // MAC Control Logic : FSM controls our MAC Unit 
    always_comb begin 

        mac_enable = 1'b0;
        mac_reset = reset;

        case (current_state)

            CLEAR: 
                mac_reset = 1'b1;

            MAC: begin 
                mac_enable = 1'b1;
            end 

            default: begin 
            end 
        endcase
    end 


    // Connecting the internal mac accumulator to the output result wire 
    assign result = mac_accumulator;

    // Generate the DONE Signal 
    assign done = (current_state == DONE);

endmodule 