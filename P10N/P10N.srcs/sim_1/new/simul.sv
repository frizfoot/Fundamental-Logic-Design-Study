`timescale 1ns / 1ps

module mEnc_tb;

    logic [7:0] y;
    logic       e;
    logic       a, b, c, d;

    mEnc u_dut (
        .y (y),
        .e (e),
        .a (a),
        .b (b),
        .c (c),
        .d (d)
    );

    // 예상값과 자동 비교
    task check(input [7:0] in, input en, input [2:0] exp_abc, input exp_d);
        y = in;
        e = en;
        #10;
        if ({a,b,c} !== exp_abc || d !== exp_d)
            $error("FAIL: y=%b e=%b -> got abc=%b%b%b d=%b, expected abc=%b d=%b",
                   in, en, a, b, c, d, exp_abc, exp_d);
        else
            $display("PASS: y=%b e=%b -> abc=%b%b%b d=%b", in, en, a, b, c, d);
    endtask

    initial begin
        // 단일 비트 활성 (y[7]이 최우선)
        check(8'b1000_0000, 1'b1, 3'b111, 1'b1);
        check(8'b0100_0000, 1'b1, 3'b110, 1'b1);
        check(8'b0010_0000, 1'b1, 3'b101, 1'b1);
        check(8'b0001_0000, 1'b1, 3'b100, 1'b1);
        check(8'b0000_1000, 1'b1, 3'b011, 1'b1);
        check(8'b0000_0100, 1'b1, 3'b010, 1'b1);
        check(8'b0000_0010, 1'b1, 3'b001, 1'b1);
        check(8'b0000_0001, 1'b1, 3'b000, 1'b1);

        // 우선순위 검증 (높은 쪽만 인정되어야 함)
        check(8'b1100_0000, 1'b1, 3'b111, 1'b1);
        check(8'b1000_1000, 1'b1, 3'b111, 1'b1);
        check(8'b0000_0110, 1'b1, 3'b010, 1'b1);
        check(8'b1111_1111, 1'b1, 3'b111, 1'b1);

        // 입력 없음 (valid = 0)
        check(8'b0000_0000, 1'b1, 3'b000, 1'b0);

        // enable = 0 (전 출력 0)
        check(8'b1111_1111, 1'b0, 3'b000, 1'b0);
        check(8'b1000_0000, 1'b0, 3'b000, 1'b0);

        $display("--- simulation finished ---");
        $finish;
    end

endmodule