module alu (
    input logic [7:0] a, 
    input logic [7:0] b,
    input logic [1:0] opcode,
    output logic [7:0] result 
);

    always_comb begin 
        
        // Set a default value for the ALU
        result = 8'b0;

        case (opcode)
            // 00: Addition Operation 
            2'b00: 
                result = a + b;
            // 01: Subtraction Operation  
            2'b01:
                result = a - b;
            // 10: AND Operation
            2'b10: 
                result = a & b; 
            // 11: XOR Operation
            2'b11:
                result = a ^ b; 
        endcase  
    end     
endmodule 