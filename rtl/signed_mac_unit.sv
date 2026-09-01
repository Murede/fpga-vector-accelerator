module signed_mac_unit(
    input logic clk,
    input logic reset,
    input logic en,

    input logic signed [7:0] a,
    input logic signed [7:0] b,

    output logic signed [17:0] accumulator

);

    logic signed [15:0] product;

    assign product = a * b;

    always_ff @(posedge clk) begin 
        if (reset)
            accumulator <= 18'sd0;
        else if (en)
            accumulator <= accumulator + {{2{product[15]}}, product}; 
    end 

endmodule