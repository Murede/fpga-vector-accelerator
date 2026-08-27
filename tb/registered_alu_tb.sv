`timescale 1ns/1ps

module registered_alu_tb;

    logic clk;
    logic reset;
    logic start;

    logic [7:0] a;
    logic [7:0] b;
    logic [1:0] opcode;

    logic [7:0] result;
    logic done;

    registered_alu dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .done(done)
    );

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        $dumpfile("sim/registered_alu.vcd");
        $dumpvars(0, registered_alu_tb);

        // =========================
        // Stage 0: Reset
        // =========================

        reset  = 1'b1;
        start  = 1'b0;
        a      = 8'd0;
        b      = 8'd0;
        opcode = 2'b00;

        @(posedge clk);
        #1;

        reset = 1'b0;


        // =========================
        // Transaction 1: ADD
        // 5 + 3 = 8
        // =========================

        a      = 8'd5;
        b      = 8'd3;
        opcode = 2'b00;
        start  = 1'b1;

        // Cycle N: Inputs captured
        @(posedge clk);
        #1;

        start = 1'b0;

        // Cycle N+1: Operation completes
        @(posedge clk);
        #1;

        if (result !== 8'd8)
            $error("Registered ADD failed: expected 8, got %0d", result);
        else
            $display("Registered ADD result passed");

        if (done !== 1'b1)
            $error("Registered ADD failed: done was not asserted");
        else
            $display("Registered ADD done pulse passed");

        // Cycle N+2: done must return low
        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("ADD done should return low after one cycle");
        else
            $display("ADD done pulse width passed");


        // =========================
        // Transaction 2: SUB
        // 9 - 4 = 5
        // =========================

        a      = 8'd9;
        b      = 8'd4;
        opcode = 2'b01;
        start  = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0;

        @(posedge clk);
        #1;

        if (result !== 8'd5)
            $error("Registered SUB failed: expected 5, got %0d", result);
        else
            $display("Registered SUB result passed");

        if (done !== 1'b1)
            $error("Registered SUB failed: done was not asserted");
        else
            $display("Registered SUB done pulse passed");

        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("SUB done should return low after one cycle");
        else
            $display("SUB done pulse width passed");


        // =========================
        // Transaction 3: AND
        // CC & AA = 88
        // =========================

        a      = 8'b11001100;
        b      = 8'b10101010;
        opcode = 2'b10;
        start  = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0;

        @(posedge clk);
        #1;

        if (result !== 8'b10001000)
            $error(
                "Registered AND failed: expected 10001000, got %b",
                result
            );
        else
            $display("Registered AND result passed");

        if (done !== 1'b1)
            $error("Registered AND failed: done was not asserted");
        else
            $display("Registered AND done pulse passed");

        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("AND done should return low after one cycle");
        else
            $display("AND done pulse width passed");


        // =========================
        // Transaction 4: XOR
        // CC ^ AA = 66
        // =========================

        a      = 8'b11001100;
        b      = 8'b10101010;
        opcode = 2'b11;
        start  = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0;

        @(posedge clk);
        #1;

        if (result !== 8'b01100110)
            $error(
                "Registered XOR failed: expected 01100110, got %b",
                result
            );
        else
            $display("Registered XOR result passed");

        if (done !== 1'b1)
            $error("Registered XOR failed: done was not asserted");
        else
            $display("Registered XOR done pulse passed");

        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("XOR done should return low after one cycle");
        else
            $display("XOR done pulse width passed");

        $finish;
    end

endmodule