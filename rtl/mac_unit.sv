module mac_unit (
    input logic clk,
    input logic reset,
    input logic en,

    input logic [7:0] a,
    input logic [7:0] b,

    output logic [17:0] accumulator 
);

    logic [15:0] product;

    assign product = a * b;

    always_ff @(posedge clk) begin 
        if (reset)
            accumulator <= 18'd0;
        else if (en)
            accumulator <= accumulator + {2'b0, product};
    end 

endmodule 