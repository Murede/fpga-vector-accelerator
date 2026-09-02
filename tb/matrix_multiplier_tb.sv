`timescale 1ns/1ps

module matrix_multiplier_tb;

    // -------------------------------------------------
    // Parameters
    // -------------------------------------------------
    localparam int DATA_WIDTH = 8;
    localparam int VECTOR_LEN = 4;
    localparam int NUM_ROWS   = 4;
    localparam int ACC_WIDTH  =
        (2 * DATA_WIDTH) + $clog2(VECTOR_LEN);

    // -------------------------------------------------
    // Testbench Signals
    // -------------------------------------------------
    logic clk;
    logic reset;
    logic start;

    logic signed [DATA_WIDTH-1:0] a
        [NUM_ROWS-1:0][VECTOR_LEN-1:0];

    logic signed [DATA_WIDTH-1:0] x
        [VECTOR_LEN-1:0];

    logic signed [ACC_WIDTH-1:0] y
        [NUM_ROWS-1:0];

    logic done;


    // -------------------------------------------------
    // DUT
    // -------------------------------------------------
    matrix_multiplier #(
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


    // -------------------------------------------------
    // Clock: 10 ns period
    // -------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // -------------------------------------------------
    // Main Test Sequence
    // -------------------------------------------------
    initial begin

        $dumpfile("sim/matrix_multiplier.vcd");
        $dumpvars(0, matrix_multiplier_tb);

        // -------------------------------------------------
        // Initial Values
        // -------------------------------------------------
        reset = 1'b1;
        start = 1'b0;

        for (int row = 0; row < NUM_ROWS; row++) begin
            for (int col = 0; col < VECTOR_LEN; col++) begin
                a[row][col] = '0;
            end
        end

        for (int col = 0; col < VECTOR_LEN; col++) begin
            x[col] = '0;
        end


        // -------------------------------------------------
        // TEST 1: Reset
        // -------------------------------------------------
        @(posedge clk);
        #1;

        for (int row = 0; row < NUM_ROWS; row++) begin
            if (y[row] !== '0)
                $error(
                    "Reset test failed for y[%0d]: got %0d",
                    row,
                    y[row]
                );
        end

        if (done !== 1'b0)
            $error("Reset test failed: done should be 0");
        else
            $display("Reset test passed");

        reset = 1'b0;


        // -------------------------------------------------
        // TEST 2: Positive Matrix-Vector Multiplication
        //
        // A =
        // [1 2 3 4]
        // [2 0 1 1]
        // [1 1 1 1]
        // [3 2 1 0]
        //
        // X = [1 2 3 4]
        //
        // Expected:
        // Y = [30, 9, 10, 10]
        // -------------------------------------------------

        a[0][0] = 8'sd1;
        a[0][1] = 8'sd2;
        a[0][2] = 8'sd3;
        a[0][3] = 8'sd4;

        a[1][0] = 8'sd2;
        a[1][1] = 8'sd0;
        a[1][2] = 8'sd1;
        a[1][3] = 8'sd1;

        a[2][0] = 8'sd1;
        a[2][1] = 8'sd1;
        a[2][2] = 8'sd1;
        a[2][3] = 8'sd1;

        a[3][0] = 8'sd3;
        a[3][1] = 8'sd2;
        a[3][2] = 8'sd1;
        a[3][3] = 8'sd0;

        x[0] = 8'sd1;
        x[1] = 8'sd2;
        x[2] = 8'sd3;
        x[3] = 8'sd4;


        // Pulse start
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        // Wait until calculation finishes
        wait(done == 1'b1);
        #1;


        if (y[0] !== 18'sd30)
            $error(
                "Test 2 y[0] failed: expected 30, got %0d",
                y[0]
            );
        else
            $display("Test 2 y[0] passed: %0d", y[0]);

        if (y[1] !== 18'sd9)
            $error(
                "Test 2 y[1] failed: expected 9, got %0d",
                y[1]
            );
        else
            $display("Test 2 y[1] passed: %0d", y[1]);

        if (y[2] !== 18'sd10)
            $error(
                "Test 2 y[2] failed: expected 10, got %0d",
                y[2]
            );
        else
            $display("Test 2 y[2] passed: %0d", y[2]);

        if (y[3] !== 18'sd10)
            $error(
                "Test 2 y[3] failed: expected 10, got %0d",
                y[3]
            );
        else
            $display("Test 2 y[3] passed: %0d", y[3]);


        // -------------------------------------------------
        // TEST 3: Done Should Return Low
        // -------------------------------------------------

        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("Done-clear test failed");
        else
            $display("Done-clear test passed");


        // -------------------------------------------------
        // TEST 4: Signed Matrix-Vector Multiplication
        //
        // A =
        // [ 2 -3  4 -1]
        // [-1  2 -2  3]
        // [ 1 -1  1 -1]
        // [-2 -2 -2 -2]
        //
        // X = [5 2 -1 6]
        //
        // y[0] = 10 - 6 - 4 - 6  = -6
        // y[1] = -5 + 4 + 2 + 18 = 19
        // y[2] = 5 - 2 - 1 - 6   = -4
        // y[3] = -10 - 4 + 2 -12 = -24
        //
        // Expected:
        // Y = [-6, 19, -4, -24]
        // -------------------------------------------------

        a[0][0] =  8'sd2;
        a[0][1] = -8'sd3;
        a[0][2] =  8'sd4;
        a[0][3] = -8'sd1;

        a[1][0] = -8'sd1;
        a[1][1] =  8'sd2;
        a[1][2] = -8'sd2;
        a[1][3] =  8'sd3;

        a[2][0] =  8'sd1;
        a[2][1] = -8'sd1;
        a[2][2] =  8'sd1;
        a[2][3] = -8'sd1;

        a[3][0] = -8'sd2;
        a[3][1] = -8'sd2;
        a[3][2] = -8'sd2;
        a[3][3] = -8'sd2;

        x[0] =  8'sd5;
        x[1] =  8'sd2;
        x[2] = -8'sd1;
        x[3] =  8'sd6;


        // Start second transaction WITHOUT reset
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        wait(done == 1'b1);
        #1;


        if (y[0] !== -18'sd6)
            $error(
                "Signed test y[0] failed: expected -6, got %0d",
                y[0]
            );
        else
            $display("Signed test y[0] passed: %0d", y[0]);

        if (y[1] !== 18'sd19)
            $error(
                "Signed test y[1] failed: expected 19, got %0d",
                y[1]
            );
        else
            $display("Signed test y[1] passed: %0d", y[1]);

        if (y[2] !== -18'sd4)
            $error(
                "Signed test y[2] failed: expected -4, got %0d",
                y[2]
            );
        else
            $display("Signed test y[2] passed: %0d", y[2]);

        if (y[3] !== -18'sd24)
            $error(
                "Signed test y[3] failed: expected -24, got %0d",
                y[3]
            );
        else
            $display("Signed test y[3] passed: %0d", y[3]);


        $display("Matrix-vector multiplier testbench complete.");

        $finish;

    end

endmodule