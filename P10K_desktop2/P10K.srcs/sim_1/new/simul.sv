`timescale 1ns / 1ps

module simul;

    logic [5:0] i0, i1, i2, i3;
    logic [1:0] e;
    wire  [5:0] f;

    master u_dut (.i0(i0), .i1(i1), .i2(i2), .i3(i3), .e(e), .f(f));

    task check(input [1:0] sel, input [5:0] exp);
        e = sel;
        #10;
        if (f !== exp)
            $error("FAIL: e=%b -> got f=%b, expected %b", sel, f, exp);
        else
            $display("PASS: e=%b -> f=%b", sel, f);
    endtask

    initial begin
        i0 = 6'b000111;
        i1 = 6'b101010;
        i2 = 6'b111000;
        i3 = 6'b010101;

        check(2'b00, 6'b000111);
        check(2'b01, 6'b101010);
        check(2'b10, 6'b111000);
        check(2'b11, 6'b010101);

        $display("--- simulation finished ---");
        $finish;
    end

endmodule