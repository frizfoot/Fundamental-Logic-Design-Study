`timescale 1ns / 1ps

module counter_tb;

    logic clk;
    logic reset_n;
    logic [2:0] cba;

    // DUT (Device Under Test) 연결
    counter dut (
        .clk(clk),
        .reset_n(reset_n),
        .cba(cba)
    );

    // 클럭 생성: 10ns 주기 (5ns High, 5ns Low)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 리셋 및 시뮬레이션 시퀀스
    initial begin
        reset_n = 0;   // 처음에 리셋 걸어서 000으로 초기화
        #12;           // 클럭 한두 번 지나도록 대기
        reset_n = 1;   // 리셋 풀고 카운팅 시작

        // 충분히 오래 돌려서 카운터가 몇 바퀴 도는지 확인
        #200;

        $finish;       // 시뮬레이션 종료
    end

    // 상태 변화 확인용 출력
    initial begin
        $monitor("time=%0t  reset_n=%b  cba=%b (C=%b B=%b A=%b)",
                  $time, reset_n, cba, cba[2], cba[1], cba[0]);
    end

endmodule