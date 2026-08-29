`timescale 1ns/1ps

module controller_alu_tb;

    logic clk;
    logic reset;
    logic start;

    logic [7:0] a;
    logic [7:0] b;
    logic [1:0] opcode;

    logic [7:0] result;
    logic done;

    controller_alu dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .done(done)
    );

    // =========================
    // Clock Generator
    // =========================

    initial begin 
        clk = 1'b0; 

        // Create a 10 ns clock signal with a 50% duty cycle
        forever #5 clk = ~clk;
    end 


    initial begin 

        $dumpfile("sim/controller_alu.vcd");
        $dumpvars(0, controller_alu_tb);

        // =========================
        // Stage 0: Reset
        // =========================

        reset  = 1'b1;
        start  = 1'b0;
        a      = 8'd0;
        b      = 8'd0;
        opcode = 2'b00;

        // Wait for reset clock edge, then allow sequential updates to settle 
        @(posedge clk);
        #1;

        // Set the reset bit back to low 1ns after the clock edge
        // to avoid creating a race with our DUT
        reset = 1'b0;

        // Verify the reset result 
        if (result !== 8'd0)
            $error("RESET failed: expected result = 0, got %d", result);
        
        if (done !== 1'b0)
            $error("RESET failed: expected done = 0");
        
        $display("RESET test passed");

        // =========================
        // Stage 1: Start Transaction
        // =========================

        a      = 8'd5;
        b      = 8'd3;
        opcode = 2'b00;
        start  = 1'b1;

        @(posedge clk);
        #1;

        // =========================
        // Stage 2: LOAD Transaction
        // =========================

        start = 1'b0; 

        @(posedge clk);
        #1;

        // =========================
        // Stage 3: EXECUTE Transaction
        // =========================
        
        @(posedge clk);
        #1;

        // =========================
        // Stage 4: DONE Transaction
        // =========================

        // Add transaction to simulate arithmetic operation of the circuit 
        if (result !== 8'd8) 
            $error("Controller ADD failed: expected 8, got %0d", result);
        else
            $display("Controller ADD result passed");

        if (done !== 1'b1)
            $error("Controller ADD failed: done was not asserted");
        else
            $display("Controller ADD done pulse passed");
        
        $display("ADD Transaction passed");

        

        // =========================
        // Stage 5: Return to IDLE Transaction
        // =========================


        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("Return to IDLE failed, done does not go back to 0");
        else
            $display("Return to IDLE Transaction was succesful");

        if (result !== 8'd8)
            $error("Result did not remain stored after returning to IDLE");
        else 
            $display("Result remains stored after returning to IDLE");

            $finish;

    end 

    // Test sequence goes here


endmodule