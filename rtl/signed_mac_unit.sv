module signed_mac_unit #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH  = 18
)(
    input logic clk,
    input logic reset,
    input logic en,

    input  logic signed [DATA_WIDTH-1:0] a,
    input  logic signed [DATA_WIDTH-1:0] b,

    output logic signed [ACC_WIDTH-1:0] accumulator
);

    localparam int PRODUCT_WIDTH = 2 * DATA_WIDTH;

    logic signed [PRODUCT_WIDTH-1:0] product;
    logic signed [ACC_WIDTH-1:0] extended_product;

    assign product = a * b;

    assign extended_product =
        {{(ACC_WIDTH-PRODUCT_WIDTH){product[PRODUCT_WIDTH-1]}}, product};

    always_ff @(posedge clk) begin 
        if (reset)
            accumulator <= '0;
        else if (en)
            accumulator <= accumulator + extended_product;
    end 

endmodule