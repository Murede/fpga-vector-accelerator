`timescale 1ns/1ps

module vector_dot_product_tb;

    logic [7:0] a0, a1, a2, a3;
    logic [7:0] b0, b1, b2, b3;

    logic [17:0] dot_product;

    vector_dot_product dut (
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),

        .dot_product(dot_product)
    );

    initial begin

        $dumpfile("sim/vector_dot_product.vcd");
        $dumpvars(0, vector_dot_product_tb);

        // -------------------------
        // Test 1: Normal dot-product operation
        // -------------------------

        a0 = 8'd2;
        a1 = 8'd4;
        a2 = 8'd6;
        a3 = 8'd8;

        b0 = 8'd1;
        b1 = 8'd3;
        b2 = 8'd5;
        b3 = 8'd7;

        

        #1;

        if (dot_product !== 18'd100)
            $error("Dot-product test failed: expected %0d, got %0d",
                100, dot_product);
        else
            $display("Test 1 -Dot-product test passed");

        // -------------------------
        // Test 2: Zero Values 
        // -------------------------

        a0 = 8'd0;
        a1 = 8'd0;
        a2 = 8'd0;
        a3 = 8'd0;

        b0 = 8'd1;
        b1 = 8'd3;
        b2 = 8'd5;
        b3 = 8'd7;

        

        #1;

        if (dot_product !== 18'd0)
            $error("Dot-product test failed: expected %0d, got %0d",
                0, dot_product);
        else
            $display("Test 2 - Dot-product test passed");

        // -------------------------
        // Test 3: Large Mixed Values 
        // -------------------------

        a0 = 8'd200;
        a1 = 8'd40;
        a2 = 8'd238;
        a3 = 8'd198;

        b0 = 8'd25;
        b1 = 8'd65;
        b2 = 8'd242;
        b3 = 8'd255;

        

        #1;

        if (dot_product !== 18'd115686)
            $error("Dot-product test failed: expected %0d, got %0d",
                115686, dot_product);
        else
            $display("Test 3 - Dot-product test passed");

        // -------------------------
        // Test 4: Boundary Values 
        // -------------------------

        a0 = 8'd255;
        a1 = 8'd255;
        a2 = 8'd255;
        a3 = 8'd255;

        b0 = 8'd255;
        b1 = 8'd255;
        b2 = 8'd255;
        b3 = 8'd255;

        

        #1;

        if (dot_product !== 18'd260100)
            $error("Dot-product test failed: expected %0d, got %0d",
                260100, dot_product);
        else
            $display("Test 4 - Dot-product test passed");

        $finish;
    end

endmodule
