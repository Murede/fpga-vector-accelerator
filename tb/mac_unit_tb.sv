`timescale 1ns/1ps

module mac_unit_tb;

    logic clk;
    logic reset;
    logic en;

    logic [7:0] a;
    logic [7:0] b;

    logic [17:0] accumulator;

    mac_unit dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .a(a),
        .b(b),
        .accumulator(accumulator)
    );

    // 10 ns clock period = 100 MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("sim/mac_unit.vcd");
        $dumpvars(0, mac_unit_tb);

        // Initialize inputs
        reset = 1'b1;
        en    = 1'b0;
        a     = 8'd0;
        b     = 8'd0;

        // -------------------------
        // Test 1: Reset
        // -------------------------

        @(posedge clk);
        #1;

        reset = 1'b0;

        if (accumulator !== 18'd0)
            $error("Reset test failed: expected 0, got %0d", accumulator);
        else
            $display("Reset test passed");

        // -------------------------
        // Test 2: First MAC
        // 2 × 1 = 2
        // -------------------------

        a  = 8'd2;
        b  = 8'd1;
        en = 1'b1;

        @(posedge clk);
        #1;

        if (accumulator !== 18'd2)
            $error("MAC 1 failed: expected 2, got %0d", accumulator);
        else
            $display("MAC 1 passed");

        // -------------------------
        // Test 3: Second MAC
        // accumulator = 2 + (4 × 3)
        //             = 14
        // -------------------------

        a = 8'd4;
        b = 8'd3;

        @(posedge clk);
        #1;

        if (accumulator !== 18'd14)
            $error("MAC 2 failed: expected 14, got %0d", accumulator);
        else
            $display("MAC 2 passed");

        // -------------------------
        // Test 4: Enable = 0
        // accumulator should hold 14
        // -------------------------

        en = 1'b0;

        a = 8'd255;
        b = 8'd255;

        @(posedge clk);
        #1;

        if (accumulator !== 18'd14)
            $error("Enable hold test failed: expected 14, got %0d", accumulator);
        else
            $display("Enable hold test passed");

        // -------------------------
        // Test 5: Continue accumulation
        // accumulator = 14 + (6 × 5)
        //             = 44
        // -------------------------

        en = 1'b1;
        a  = 8'd6;
        b  = 8'd5;

        @(posedge clk);
        #1;

        if (accumulator !== 18'd44)
            $error("MAC 3 failed: expected 44, got %0d", accumulator);
        else
            $display("MAC 3 passed");

        // -------------------------
        // Test 6: Final accumulation
        // accumulator = 44 + (8 × 7)
        //             = 100
        // -------------------------

        a = 8'd8;
        b = 8'd7;

        @(posedge clk);
        #1;

        if (accumulator !== 18'd100)
            $error("MAC 4 failed: expected 100, got %0d", accumulator);
        else
            $display("MAC 4 passed");

        // -------------------------
        // Test 7: Reset accumulated value
        // -------------------------

        reset = 1'b1;
        en    = 1'b0;

        @(posedge clk);
        #1;

        if (accumulator !== 18'd0)
            $error("Final reset failed: expected 0, got %0d", accumulator);
        else
            $display("Final reset passed");

        $finish;
    end

endmodule