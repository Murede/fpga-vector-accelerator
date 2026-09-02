`timescale 1ns/1ps

module signed_mac_unit_tb;

    logic clk;
    logic reset;
    logic en;

    logic signed [7:0] a;
    logic signed [7:0] b;

    logic signed [17:0] accumulator;

    signed_mac_unit dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .a(a),
        .b(b),
        .accumulator(accumulator)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("sim/signed_mac_unit.vcd");
        $dumpvars(0, signed_mac_unit_tb);

        // Initialization
        reset = 1'b1;
        en    = 1'b0;
        a     = 8'sd0;
        b     = 8'sd0;

        // Test 1: Reset
        @(posedge clk);
        #1;

        if (accumulator !== 18'sd0)
            $error("Reset failed: expected 0, got %0d", accumulator);
        else
            $display("Reset test passed");

        reset = 1'b0;

        // Test 2: 2 * 5 = 10
        a  = 8'sd2;
        b  = 8'sd5;
        en = 1'b1;

        @(posedge clk);
        #1;

        if (accumulator !== 18'sd10)
            $error("Test 2 failed: expected 10, got %0d", accumulator);
        else
            $display("Test 2 passed: accumulator = %0d", accumulator);

        // Test 3: -3 * 2 = -6, accumulator becomes 4
        a = -8'sd3;
        b =  8'sd2;

        @(posedge clk);
        #1;

        if (accumulator !== 18'sd4)
            $error("Test 3 failed: expected 4, got %0d", accumulator);
        else
            $display("Test 3 passed: accumulator = %0d", accumulator);

        // Test 4: 4 * -1 = -4, accumulator becomes 0
        a =  8'sd4;
        b = -8'sd1;

        @(posedge clk);
        #1;

        if (accumulator !== 18'sd0)
            $error("Test 4 failed: expected 0, got %0d", accumulator);
        else
            $display("Test 4 passed: accumulator = %0d", accumulator);

        // Test 5: -1 * 6 = -6, accumulator becomes -6
        a = -8'sd1;
        b =  8'sd6;

        @(posedge clk);
        #1;

        if (accumulator !== -18'sd6)
            $error("Test 5 failed: expected -6, got %0d", accumulator);
        else
            $display("Test 5 passed: accumulator = %0d", accumulator);

        // Test 6: Hold when en = 0
        en = 1'b0;
        a  = 8'sd50;
        b  = 8'sd50;

        @(posedge clk);
        #1;

        if (accumulator !== -18'sd6)
            $error("Hold test failed: expected -6, got %0d", accumulator);
        else
            $display("Hold test passed");

        // Test 7: Reset again
        reset = 1'b1;

        @(posedge clk);
        #1;

        if (accumulator !== 18'sd0)
            $error("Final reset failed: expected 0, got %0d", accumulator);
        else
            $display("Final reset passed");

        $finish;
    end

endmodule