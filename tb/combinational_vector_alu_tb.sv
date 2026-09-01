`timescale 1ns/1ps

module combinational_vector_alu_tb;

    logic [7:0] a0, a1, a2, a3;
    logic [7:0] b0, b1, b2, b3;

    logic [1:0] opcode;

    logic [7:0] result0, result1, result2, result3;

    combinational_vector_alu dut (
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),

        .opcode(opcode),

        .result0(result0),
        .result1(result1),
        .result2(result2),
        .result3(result3)
    );

    initial begin

        $dumpfile("sim/combinational_vector_alu.vcd");
        $dumpvars(0, combinational_vector_alu_tb);

        
        // Initialize vector operands
        
        a0 = 8'd2;
        a1 = 8'd4;
        a2 = 8'd6;
        a3 = 8'd8;

        b0 = 8'd1;
        b1 = 8'd3;
        b2 = 8'd5;
        b3 = 8'd7;

        // Vector ADD Test 

        opcode = 2'b00; 

        #1;

        if (result0 !== 8'd3)
            $error("Result0 Lane ADD Test failed expected 3, and got %0d", result0);
        else 
            $display("Result0 ADD Test Passed");

        if (result1 !== 8'd7)
            $error("Result1 Lane ADD Test failed expected 7, and got %0d", result1);
        else 
            $display("Result1 ADD Test Passed");
        
        if (result2 !== 8'd11)
            $error("Result2 Lane ADD Test failed expected 11, and got %0d", result2);
        else 
            $display("Result2 ADD Test Passed");

        if (result3 !== 8'd15)
            $error("Result3 Lane ADD Test failed expected 15, and got %0d", result3);
        else 
            $display("Result3 ADD Test Passed");
    
    // Vector SUB Test 
        opcode = 2'b01; 

        #1;

        if (result0 !== 8'd1)
            $error("Result0 Lane SUB Test failed expected 1, and got %0d", result0);
        else 
            $display("Result0 SUB Test Passed");

        if (result1 !== 8'd1)
            $error("Result1 Lane SUB Test failed expected 1, and got %0d", result1);
        else 
            $display("Result1 SUB Test Passed");
        
        if (result2 !== 8'd1)
            $error("Result2 Lane SUB Test failed expected 1, and got %0d", result2);
        else 
            $display("Result2 SUB Test Passed");

        if (result3 !== 8'd1)
            $error("Result3 Lane SUB Test failed expected 1, and got %0d", result3);
        else 
            $display("Result3 SUB Test Passed");

    // Vector AND Test
        opcode = 2'b10;

        #1; 

        if (result0 !== 8'b00000000)
            $error("Result0 Lane AND Test failed expected 00000000, and got %b", result0);
        else 
            $display("Result0 AND Test Passed");

        if (result1 !== 8'b00000000)
            $error("Result1 Lane AND Test failed expected 00000000, and got %b", result1);
        else 
            $display("Result1 AND Test Passed");
        
        if (result2 !== 8'b00000100)
            $error("Result2 Lane AND Test failed expected 00000100, and got %b", result2);
        else 
            $display("Result2 AND Test Passed");

        if (result3 !== 8'b00000000)
            $error("Result3 Lane AND Test failed expected 00000000, and got %b", result3);
        else 
            $display("Result3 AND Test Passed");

    // Vector XOR Test
        opcode = 2'b11;

        #1; 

        if (result0 !== 8'b00000011)
            $error("Result0 Lane XOR Test failed expected 00000011, and got %b", result0);
        else 
            $display("Result0 XOR Test Passed");

        if (result1 !== 8'b00000111)
            $error("Result1 Lane XOR Test failed expected 00000111, and got %b", result1);
        else 
            $display("Result1 XOR Test Passed");
        
        if (result2 !== 8'b00000011)
            $error("Result2 Lane XOR Test failed expected 00000011, and got %b", result2);
        else 
            $display("Result2 XOR Test Passed");

        if (result3 !== 8'b00001111)
            $error("Result3 Lane XOR Test failed expected 00001111, and got %b", result3);
        else 
            $display("Result3 XOR Test Passed");
        $finish;
    end

endmodule
