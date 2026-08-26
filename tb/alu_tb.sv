`timescale 1ns/1ps

module alu_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [1:0] opcode;
    logic [7:0] result;

    // Instantiate the ALU we are testing 
    alu dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result)
    );

    initial begin

        // Waveform output 
        $dumpfile("sim/alu.vcd"); 
        $dumpvars(0, alu_tb);

        // =========================
        // ADD Test Cases
        // =========================

        // Normal Addition: 5 + 3 = 8
        a = 8'd5;
        b = 8'd3;
        opcode = 2'b00;

        #1;

        if (result !== 8'd8)
            $error("ADD test failed: expected 8, got %0d", result);
        else
            $display("ADD test passed");

        // 8-bit Overflow/Truncation: 255 + 1 = 0
        a = 8'd255;
        b = 8'd1;
        opcode = 2'b00;

        #1;

        if (result !== 8'd0)
            $error("ADD overflow test failed: expected 0, got %0d", result);
        else
            $display("ADD overflow test passed");

        // =========================
        // SUB Test Cases
        // =========================

        // Normal Subtraction: 9 - 4 = 5
        a = 8'd9;
        b = 8'd4;
        opcode = 2'b01;

        #1;

        if (result !== 8'd5)
            $error("SUB test failed: expected 5, got %0d", result);
        else
            $display("SUB test passed");

        // Equal operands: 7 - 7 = 0
        a = 8'd7;
        b = 8'd7;
        opcode = 2'b01;

        #1;

        if (result !== 8'd0)
            $error("SUB equal-operands test failed: expected 0, got %0d", result);
        else
            $display("SUB equal-operands test passed");

        // =========================
        // AND Test Cases
        // =========================

        a = 8'b11001100;
        b = 8'b10101010;
        opcode = 2'b10;

        #1;

        if (result !== 8'b10001000)
            $error("AND test failed: expected 10001000, got %b", result);
        else
            $display("AND test passed");

        // Boundary behaviour
        a = 8'b11111111;
        b = 8'b00000000;
        opcode = 2'b10;

        #1;

        if (result !== 8'b00000000)
            $error("AND boundary test failed: expected 00000000, got %b", result);
        else
            $display("AND boundary test passed");

        // =========================
        // XOR Test Cases
        // =========================

        a = 8'b11001100;
        b = 8'b10101010;
        opcode = 2'b11;

        #1;

        if (result !== 8'b01100110)
            $error("XOR test failed: expected 01100110, got %b", result);
        else
            $display("XOR test passed");

        // Equal operands
        a = 8'b11111111;
        b = 8'b11111111;
        opcode = 2'b11;

        #1;

        if (result !== 8'b00000000)
            $error("XOR equal-operands test failed: expected 00000000, got %b", result);
        else
            $display("XOR equal-operands test passed");

        $finish;
    end

endmodule