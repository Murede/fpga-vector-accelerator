`timescale 1ns/1ps

module vector_mac_controller_tb;

    logic clk;
    logic reset; 
    logic start; 
    
    logic [7:0] a0, a1, a2, a3;
    logic [7:0] b0, b1, b2, b3;

    logic [17:0] result;
    logic done;   

    vector_mac_controller mac_control (
        .clk(clk),
        .reset(reset),
        .start(start),

        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .b0(b0),
        .b1(b1),
        .b2(b2),
        .b3(b3),

        .result(result),
        .done(done)
    );

    initial begin 
        clk = 1'b0; 

        // Create a 10 ns clock signal with a 50% duty cycle
        forever #5 clk = ~clk;
    end 

    initial begin 

        $dumpfile("sim/vector_mac_controller.vcd");
        $dumpvars(0, vector_mac_controller_tb);

        // Start with initialization
        reset = 1'b1;
        start = 1'b0;

        a0 = 8'd2;
        a1 = 8'd4;
        a2 = 8'd6;
        a3 = 8'd8;

        b0 = 8'd1;
        b1 = 8'd3;
        b2 = 8'd5;
        b3 = 8'd7;

        // Test 1: Reset Test
        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("Reset test failed: done should be 0");
        else 
            $display("Reset Test Passed");

        reset = 1'b0;

        // Test 2: IDLE should wait when start = 0
        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("IDLE test failed: done should be 0");
        else 
            $display("IDLE wait test passed");
        
        // Test 3: Start Operation
        start = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0; 

        if (done !== 1'b0)
            $error("Start test failed: done asserted too early");
        else    
            $display("Start test passed");

        // Run the FSM until the final vector element has been processed
        wait (done == 1'b1);
        #1;

        // Test 4: Completion and final result 
        if (result !== 18'd100)
            $error(
                "Result test failed: expected 100, got %0d",
                result
            );
        else 
            $display(
                "Result test passed: result = %0d",
                result
            );

        // Test 5: DONE should return to IDLE
        @(posedge clk);
        #1;

        if (done !== 1'b0)
            $error("DONE pulse test failed: done remained high");
        else 
            $display("DONE pulse test passed");

        $finish; 
    end 

endmodule