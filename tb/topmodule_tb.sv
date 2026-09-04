`timescale 1ns/1ps

module tb_topmodule;

    parameter int DATA_WIDTH = 8;
    parameter int VECTOR_LEN = 4;
    parameter int NUM_ROWS = 4;
    parameter int ACC_WIDTH =
        (2 * DATA_WIDTH) + $clog2(VECTOR_LEN);

    // Clock and Control Signals
    logic clk;
    logic reset;
    logic start;
    logic done;

    // Matrix and Vector Inputs
    logic signed [DATA_WIDTH-1:0] a
        [NUM_ROWS-1:0][VECTOR_LEN-1:0];

    logic signed [DATA_WIDTH-1:0] x
        [VECTOR_LEN-1:0];

    // Output Vector
    logic signed [ACC_WIDTH-1:0] y
        [NUM_ROWS-1:0];

    // DUT Instantiation
    topmodule #(
        .DATA_WIDTH(DATA_WIDTH),
        .VECTOR_LEN(VECTOR_LEN),
        .NUM_ROWS(NUM_ROWS),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(a),
        .x(x),
        .y(y),
        .done(done)
    );

    // Clock Generation
    always #5 clk = ~clk;

    initial begin

        // Waveform Dump
        $dumpfile("sim/topmodule.vcd");
        $dumpvars(0, tb_topmodule);

        // Initial Values
        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;

        // Allow reset to be captured
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;

        // -------------------------------------------------
        // Test 1: Positive Values
        // -------------------------------------------------

        a[0][0] = 1;
        a[0][1] = 2;
        a[0][2] = 3;
        a[0][3] = 4;

        a[1][0] = 2;
        a[1][1] = 0;
        a[1][2] = 1;
        a[1][3] = 1;

        a[2][0] = 1;
        a[2][1] = 1;
        a[2][2] = 1;
        a[2][3] = 1;

        a[3][0] = 3;
        a[3][1] = 2;
        a[3][2] = 1;
        a[3][3] = 0;

        x[0] = 1;
        x[1] = 2;
        x[2] = 3;
        x[3] = 4;

        // Start Operation
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for Completion
        wait(done == 1'b1);

        @(negedge clk);

        // Check Results
        if (
            y[0] == 30 &&
            y[1] == 9  &&
            y[2] == 10 &&
            y[3] == 10
        )
            $display("Test 1 PASSED: y = %0d %0d %0d %0d",
                y[0], y[1], y[2], y[3]);
        else
            $error("Test 1 FAILED: y = %0d %0d %0d %0d",
                y[0], y[1], y[2], y[3]);

        // -------------------------------------------------
        // Test 2: Signed Values
        // -------------------------------------------------

        a[0][0] =  2;
        a[0][1] = -3;
        a[0][2] =  4;
        a[0][3] = -1;

        a[1][0] = -1;
        a[1][1] =  2;
        a[1][2] = -2;
        a[1][3] =  3;

        a[2][0] =  1;
        a[2][1] = -1;
        a[2][2] =  1;
        a[2][3] = -1;

        a[3][0] = -2;
        a[3][1] = -2;
        a[3][2] = -2;
        a[3][3] = -2;

        x[0] =  5;
        x[1] =  2;
        x[2] = -1;
        x[3] =  6;

        // Start Second Operation
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for Completion
        wait(done == 1'b1);

        @(negedge clk);

        // Check Results
        if (
            y[0] == -6  &&
            y[1] == 19  &&
            y[2] == -4  &&
            y[3] == -24
        )
            $display("Test 2 PASSED: y = %0d %0d %0d %0d",
                y[0], y[1], y[2], y[3]);
        else
            $error("Test 2 FAILED: y = %0d %0d %0d %0d",
                y[0], y[1], y[2], y[3]);

        $display("Top-level verification complete.");

        $finish;
    end

endmodule