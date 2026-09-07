`timescale 1ns / 1ps

module mas_tb;

    logic [7:0] a, b, c;
    logic       bo;

    mas u_dut (
        .a  (a),
        .b  (b),
        .c  (c),
        .bo (bo)
    );

    task check(input [7:0] ia, input [7:0] ib, input [7:0] exp_c, input exp_bo);
        a = ia;
        b = ib;
        #10;
        if (c !== exp_c || bo !== exp_bo)
            $error("FAIL: %b - %b -> got c=%b bo=%b, expected c=%b bo=%b",
                   ia, ib, c, bo, exp_c, exp_bo);
        else
            $display("PASS: %d - %d = %d (c=%b bo=%b)",
                     ia, ib, $signed(c), c, bo);
    endtask

    initial begin
        // 문제 지정 케이스
        check(8'b1101_1011, 8'b0111_0110, 8'b0110_0101, 1'b0);  // 219-118=101
        check(8'b0111_0110, 8'b1101_1011, 8'b1001_1011, 1'b1);  // 118-219=-101

        // 기본 케이스
        check(8'd10,  8'd3,   8'd7,        1'b0);   // 양수 결과
        check(8'd3,   8'd10,  8'b1111_1001, 1'b1);  // 음수 결과 (-7)
        check(8'd0,   8'd0,   8'd0,        1'b0);   // 0 - 0
        check(8'd255, 8'd1,   8'd254,      1'b0);   // 최대값 - 1
        check(8'd0,   8'd1,   8'b1111_1111, 1'b1);  // 0 - 1 = -1

        // 경계 케이스
        check(8'd128, 8'd128, 8'd0,        1'b0);   // 같은 값
        check(8'd127, 8'd128, 8'b1111_1111, 1'b1);  // -1

        $display("--- simulation finished ---");
        $finish;
    end

endmodule