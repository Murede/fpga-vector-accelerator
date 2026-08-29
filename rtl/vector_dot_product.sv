module vector_dot_product (

    input logic [7:0] a0,
    input logic [7:0] a1,
    input logic [7:0] a2,
    input logic [7:0] a3,

    input logic [7:0] b0,
    input logic [7:0] b1,
    input logic [7:0] b2,
    input logic [7:0] b3,

    output logic [17:0] dot_product

);

    // Create internal signals 
    logic [15:0] p0;
    logic [15:0] p1;
    logic [15:0] p2;
    logic [15:0] p3;

    logic [16:0] sum01;
    logic [16:0] sum23;

    assign p0 = a0 * b0;
    assign p1 = a1 * b1;
    assign p2 = a2 * b2;
    assign p3 = a3 * b3;

    // Zero-extend the operand before adding to avoid errors with bit sizing 
    assign sum01 = {1'b0 ,p0} + {1'b0 ,p1};
    assign sum23 = {1'b0 ,p2} + {1'b0, p3};

    assign dot_product = {1'b0, sum01} + {1'b0, sum23};
endmodule




    
 

