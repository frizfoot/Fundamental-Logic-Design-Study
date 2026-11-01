`timescale 1ns / 1ps

module counter2421_tb;

    logic clk;
    logic ClrN;
    logic [3:0] q;

    // DUT (Device Under Test) 연결
    counter2421 dut (
        .clk(clk),
        .ClrN(ClrN),
        .q(q)
    );

    // 클럭 생성: 10ns 주기 (5ns High, 5ns Low)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 리셋 및 시뮬레이션 시퀀스
    initial begin
        // 1) 처음에 리셋 걸어서 0000으로 초기화
        ClrN = 0;
        #12;

        // 2) 리셋 풀고 카운팅 시작 (0 -> 1 -> ... -> 9 -> 0 한 바퀴)
        ClrN = 1;

        // 한 바퀴(10개 상태) 돌 때까지 대기: 클럭 10ns 주기 * 10 = 100ns 정도면 충분
        #110;

        // 3) 카운터가 3(0011)이 될 때까지 기다렸다가 그 시점에 ClrN을 다시 0으로
        wait (q == 4'b0011);
        @(negedge clk);      // 클럭 하강 에지에서 안전하게 ClrN 변경
        ClrN = 0;
        #10;

        // 4) 다시 리셋 풀고 정상 동작 확인
        ClrN = 1;
        #100;

        $finish;
    end

    // 상태 변화 확인용 출력
    initial begin
        $monitor("time=%0t  ClrN=%b  q=%b (decimal-ish=%0d)", $time, ClrN, q, q);
    end

endmodule