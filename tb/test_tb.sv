`timescale 1ns/1ps

module test_tb;

    logic a;
    logic b;
    logic y;

    test dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $dumpfile("sim/test.vcd");
        $dumpvars(0, test_tb);

        a = 1'b0;
        b = 1'b0;

        #10;
        a = 1'b1;

        #10;
        b = 1'b1;

        #10;
        a = 1'b0;

        #10;
        $finish;
    end

endmodule
