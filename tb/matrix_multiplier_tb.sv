`timescale 1ns/1ps

module matrix_multiplier_tb;

    logic clk;
    logic reset;
    logic start;

    logic signed [7:0] a0 [3:0];
    logic signed [7:0] a1 [3:0];
    logic signed [7:0] a2 [3:0];
    logic signed [7:0] a3 [3:0];

    logic signed [7:0] x0;
    logic signed [7:0] x1;
    logic signed [7:0] x2;
    logic signed [7:0] x3;

    logic signed [17:0] y0;
    logic signed [17:0] y1;
    logic signed [17:0] y2;
    logic signed [17:0] y3;

    logic done;


    // DUT
    matrix_multiplier dut (
        .clk(clk),
        .reset(reset),
        .start(start),

        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .x0(x0),
        .x1(x1),
        .x2(x2),
        .x3(x3),

        .y0(y0),
        .y1(y1),
        .y2(y2),
        .y3(y3),

        .done(done)
    );


    // Clock: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    initial begin

        $dumpfile("sim/matrix_multiplier.vcd");
        $dumpvars(0, matrix_multiplier_tb);

        // -------------------------------------------------
        // Initial values
        // -------------------------------------------------
        reset = 1'b1;
        start = 1'b0;

        x0 = 8'sd0;
        x1 = 8'sd0;
        x2 = 8'sd0;
        x3 = 8'sd0;

        for (int i = 0; i < 4; i++) begin
            a0[i] = 8'sd0;
            a1[i] = 8'sd0;
            a2[i] = 8'sd0;
            a3[i] = 8'sd0;
        end


        // -------------------------------------------------
        // TEST 1: Reset
        // -------------------------------------------------
        @(posedge clk);
        #1;

        if (
            y0 !== 18'sd0 ||
            y1 !== 18'sd0 ||
            y2 !== 18'sd0 ||
            y3 !== 18'sd0 ||
            done !== 1'b0
        )
            $error("Reset test failed");
        else
            $display("Reset test passed");

        reset = 1'b0;


        // -------------------------------------------------
        // TEST 2: Positive matrix-vector multiplication
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

        a0[0] = 8'sd1;
        a0[1] = 8'sd2;
        a0[2] = 8'sd3;
        a0[3] = 8'sd4;

        a1[0] = 8'sd2;
        a1[1] = 8'sd0;
        a1[2] = 8'sd1;
        a1[3] = 8'sd1;

        a2[0] = 8'sd1;
        a2[1] = 8'sd1;
        a2[2] = 8'sd1;
        a2[3] = 8'sd1;

        a3[0] = 8'sd3;
        a3[1] = 8'sd2;
        a3[2] = 8'sd1;
        a3[3] = 8'sd0;

        x0 = 8'sd1;
        x1 = 8'sd2;
        x2 = 8'sd3;
        x3 = 8'sd4;


        // Pulse start
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        // Wait until calculation finishes
        wait(done == 1'b1);
        #1;


        if (y0 !== 18'sd30)
            $error("Test 2 y0 failed: expected 30, got %0d", y0);
        else
            $display("Test 2 y0 passed: %0d", y0);

        if (y1 !== 18'sd9)
            $error("Test 2 y1 failed: expected 9, got %0d", y1);
        else
            $display("Test 2 y1 passed: %0d", y1);

        if (y2 !== 18'sd10)
            $error("Test 2 y2 failed: expected 10, got %0d", y2);
        else
            $display("Test 2 y2 passed: %0d", y2);

        if (y3 !== 18'sd10)
            $error("Test 2 y3 failed: expected 10, got %0d", y3);
        else
            $display("Test 2 y3 passed: %0d", y3);


        // -------------------------------------------------
        // TEST 3: Done should return low
        // -------------------------------------------------

        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("Done-clear test failed");
        else
            $display("Done-clear test passed");


        // -------------------------------------------------
        // TEST 4: Signed matrix-vector multiplication
        //
        // A =
        // [ 2 -3  4 -1]
        // [-1  2 -2  3]
        // [ 1 -1  1 -1]
        // [-2 -2 -2 -2]
        //
        // X = [5 2 -1 6]
        //
        // y0 = 10 - 6 - 4 - 6  = -6
        // y1 = -5 + 4 + 2 + 18 = 19
        // y2 = 5 - 2 - 1 - 6   = -4
        // y3 = -10 -4 +2 -12   = -24
        //
        // Expected:
        // Y = [-6, 19, -4, -24]
        // -------------------------------------------------

        a0[0] =  8'sd2;
        a0[1] = -8'sd3;
        a0[2] =  8'sd4;
        a0[3] = -8'sd1;

        a1[0] = -8'sd1;
        a1[1] =  8'sd2;
        a1[2] = -8'sd2;
        a1[3] =  8'sd3;

        a2[0] =  8'sd1;
        a2[1] = -8'sd1;
        a2[2] =  8'sd1;
        a2[3] = -8'sd1;

        a3[0] = -8'sd2;
        a3[1] = -8'sd2;
        a3[2] = -8'sd2;
        a3[3] = -8'sd2;

        x0 =  8'sd5;
        x1 =  8'sd2;
        x2 = -8'sd1;
        x3 =  8'sd6;


        // Start second transaction WITHOUT asserting reset
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;


        wait(done == 1'b1);
        #1;


        if (y0 !== -18'sd6)
            $error("Signed test y0 failed: expected -6, got %0d", y0);
        else
            $display("Signed test y0 passed: %0d", y0);

        if (y1 !== 18'sd19)
            $error("Signed test y1 failed: expected 19, got %0d", y1);
        else
            $display("Signed test y1 passed: %0d", y1);

        if (y2 !== -18'sd4)
            $error("Signed test y2 failed: expected -4, got %0d", y2);
        else
            $display("Signed test y2 passed: %0d", y2);

        if (y3 !== -18'sd24)
            $error("Signed test y3 failed: expected -24, got %0d", y3);
        else
            $display("Signed test y3 passed: %0d", y3);


        $display("Matrix-vector multiplier testbench complete.");

        $finish;

    end

endmodule