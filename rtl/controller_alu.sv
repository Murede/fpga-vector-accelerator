module controller_alu (
    input logic        clk, 
    input logic        reset, 
    input logic        start,


    input logic  [7:0] a,
    input logic  [7:0] b,
    input logic  [1:0] opcode,


    output logic [7:0] result ,
    output logic       done 
);
    
    // Internal datapath registers
    logic [7:0] a_reg;
    logic [7:0] b_reg; 
    logic [1:0] opcode_reg;

    logic [7:0] alu_result;
    

    // FSM Machine
    typedef enum logic [1:0] {
        IDLE,
        LOAD, 
        EXECUTE,
        DONE
    } state_t;

    // Initialize current and next state_t
    
    state_t current_state;
    state_t next_state;

    // Instatiate existing alu 
        alu u_alu (
        .a(a_reg),
        .b(b_reg),
        .opcode(opcode_reg),
        .result(alu_result)
    );

    // 1. State register 
   
    always_ff @(posedge clk) begin 
        if (reset)
            current_state <= IDLE;
        else 
            current_state <= next_state; 
    end 

    // 2. Next-State Logic 

    always_comb begin 

        next_state = current_state;

        case (current_state)  

            IDLE: begin 
                if(start) 
                    next_state = LOAD;
                else 
                    next_state = IDLE;
            end
        
            LOAD: begin 
                next_state = EXECUTE;
            end 

            EXECUTE: begin 
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

    // 3. Datapath/Output Logic 
    always_ff @(posedge clk) begin

        if (reset) begin
            a_reg      <= 8'd0;
            b_reg      <= 8'd0;
            opcode_reg <= 2'b00;
            result     <= 8'd0;
        end

        else begin
            case (current_state)

                IDLE: begin
                    // Usually hold existing values
                end

                LOAD: begin
                    // Capture external inputs here
                    a_reg <= a;
                    b_reg <= b;
                    opcode_reg <= opcode;
                end

                EXECUTE: begin
                    // Capture alu_result here
                    result <= alu_result;
                end

                DONE: begin
                    // Usually no datapath update needed
                end

                default: begin 
                    // Hold values
                end 
            endcase
        end
    end

    // 4. FSM Output Logic 
    always_comb begin 

        done = 1'b0;

        // State-dependent output behavior 
        if (current_state == DONE)
            done = 1'b1;

    end 



endmodule