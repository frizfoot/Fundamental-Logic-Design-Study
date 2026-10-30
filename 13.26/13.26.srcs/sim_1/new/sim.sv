`timescale 1ns / 1ps

module tb_13_28;

    parameter real T       = 15.0;  // (a)15 / (b)12, 11
    parameter real X_DELAY =  2.0;  // 첫 하강엣지 후 X↑
    parameter real T0      =  2.0;  // ★ 첫 하강엣지 = 2ns (책과 동일)
    parameter real T_END   = 38.0;

    logic clk, rst_n, x, z;

    main dut(.x(x), .clk(clk), .rst_n(rst_n), .z(z));

    wire a     = dut.a;
    wire b     = dut.b;
    wire ja    = dut.ja;
    wire ka    = dut.ka;
    wire jb_kb = dut.jb;

    // 클럭: 1로 시작 → 2ns에 하강
    initial begin
        clk = 1'b1;
        #(T0)   clk = 1'b0;
        forever #(T/2) clk = ~clk;
    end

    // ★ 초기 상태 A=0, B=1  (+ 조합논리 초기값 주입)
    initial begin
        force dut.ff2.o = 1'b1;
        force dut.ja    = 1'b1;
        force dut.ka    = 1'b1;
        #6.5;
        release dut.ja;
        release dut.ka;
        release dut.ff2.o;
    end

    // 자극
    initial begin
        rst_n = 1'b0;
        x     = 1'b0;
        #1                       rst_n = 1'b1;
        #(T0 + X_DELAY - 1)      x     = 1'b1;   // t = 4
    end

    initial begin
        $display("  time  | clk X | A B | JA KA | JB=KB | Z");
        $display("--------+-------+-----+-------+-------+---");
        $monitor("%7.1f |  %b  %b |  %b %b |  %b  %b  |   %b   | %b",
                 $realtime, clk, x, a, b, ja, ka, jb_kb, z);
    end

    initial begin
        #(T_END); $display("=== 종료 ==="); $finish;
    end
endmodule