`timescale 1ns/1ps

module tb_parallel_matrix_multiplier;

    parameter int VECTOR_LEN = 4;
    parameter int DATA_WIDTH = 8;
    parameter int NUM_ROWS = 4;
    parameter int ACC_WIDTH =
        2 * DATA_WIDTH + $clog2(VECTOR_LEN);

    logic clk;
    logic reset;
    logic start;
    logic done;

    logic signed [DATA_WIDTH-1:0] a
        [NUM_ROWS-1:0][VECTOR_LEN-1:0];

    logic signed [DATA_WIDTH-1:0] x
        [VECTOR_LEN-1:0];

    logic signed [ACC_WIDTH-1:0] y
        [NUM_ROWS-1:0];

    integer i;
    integer j;

    // DUT instantiation
    parallel_matrix_multiplier #(
        .VECTOR_LEN(VECTOR_LEN),
        .DATA_WIDTH(DATA_WIDTH),
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

    // Clock generation
    initial begin
        clk = 1'b0;

        forever begin
            #5 clk = ~clk;
        end
    end

    // Test sequence
    initial begin

        $dumpfile("sim/parallel_matrix_multiplier.vcd");
        $dumpvars(0, tb_parallel_matrix_multiplier);

        reset = 1'b1;
        start = 1'b0;

        // Initialize matrix
        for (i = 0; i < NUM_ROWS; i = i + 1) begin
            for (j = 0; j < VECTOR_LEN; j = j + 1) begin
                a[i][j] = '0;
            end
        end

        // Initialize vector
        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            x[i] = '0;
        end

        // Hold reset
        repeat (2) @(posedge clk);

        reset = 1'b0;

        // Test 1: positive values
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

        // Pulse start
        @(posedge clk);
        start = 1'b1;

        @(posedge clk);
        start = 1'b0;

        // Wait for completion
        wait(done == 1'b1);

        @(posedge clk);

        // Check Test 1 results
        if (y[0] !== 30)
            $error("Test 1 failed: y[0] = %0d, expected 30", y[0]);

        if (y[1] !== 9)
            $error("Test 1 failed: y[1] = %0d, expected 9", y[1]);

        if (y[2] !== 10)
            $error("Test 1 failed: y[2] = %0d, expected 10", y[2]);

        if (y[3] !== 10)
            $error("Test 1 failed: y[3] = %0d, expected 10", y[3]);

        $display(
            "Test 1 results: %0d %0d %0d %0d",
            y[0], y[1], y[2], y[3]
        );

        // Test 2: signed values
        a[0][0] = 2;
        a[0][1] = -3;
        a[0][2] = 4;
        a[0][3] = -1;

        a[1][0] = -1;
        a[1][1] = 2;
        a[1][2] = -2;
        a[1][3] = 3;

        a[2][0] = 1;
        a[2][1] = -1;
        a[2][2] = 1;
        a[2][3] = -1;

        a[3][0] = -2;
        a[3][1] = -2;
        a[3][2] = -2;
        a[3][3] = -2;

        x[0] = 5;
        x[1] = 2;
        x[2] = -1;
        x[3] = 6;

        // Start second transaction
        @(posedge clk);
        start = 1'b1;

        @(posedge clk);
        start = 1'b0;

        // Wait for completion
        wait(done == 1'b1);

        @(posedge clk);

        // Check Test 2 results
        if (y[0] !== -6)
            $error("Test 2 failed: y[0] = %0d, expected -6", y[0]);

        if (y[1] !== 19)
            $error("Test 2 failed: y[1] = %0d, expected 19", y[1]);

        if (y[2] !== -4)
            $error("Test 2 failed: y[2] = %0d, expected -4", y[2]);

        if (y[3] !== -24)
            $error("Test 2 failed: y[3] = %0d, expected -24", y[3]);

        $display(
            "Test 2 results: %0d %0d %0d %0d",
            y[0], y[1], y[2], y[3]
        );

        $display("All parallel matrix multiplier tests completed.");

        #20;
        $finish;

    end

endmodule