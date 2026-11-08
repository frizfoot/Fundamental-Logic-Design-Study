`timescale 1ns / 1ps
// =====================================================================
// 4비트 곱셈기 테스트벤치
//  - DUT 내부 이름: current / acc / cnt / k  (네 main.sv 기준)
//  - 리셋: active-low (rst_n = 0 이면 리셋)
//    (네 DUT 이름이 다르면 dut. 뒤만 바꿔)
//  - 상태 이름: standby(S0), min(S1) 사용
//  - [추가] / [수정] 표시가 내가 채운 부분
// =====================================================================

module simul;
    logic clk,rst_n,st;
    logic [3:0]ier;
    logic [3:0]cand;
    logic [7:0]prod;
    logic done;

    main dut (.*);
    int errors=0;

    initial clk=0;
    always #5 clk=~clk;

    // 성공하면 PASS 한 줄, 실패하면 그 순간의 주요 신호를 전부 찍어 줌
    task automatic check(input string name, input logic ok);
        if (ok)
            $display("[PASS] %-32s t=%0t", name, $time);
        else begin
            errors++;
            $error("[FAIL] %s t=%0t | state=%s | acc=%b cnt=%0d k=%b | st=%b done=%b prod=%0d",
                   name, $time, dut.current.name(),
                   dut.acc, dut.cnt, dut.k,
                   st, done, prod);
        end
    endtask

    // [추가] 곱셈 한 번을 처음부터 끝까지 돌리는 task
    //        a × b 를 넣고, load 확인 → 끝날 때까지 기다림 → 결과 확인
    //        task로 묶어 두면 숫자만 바꿔서 여러 번 부를 수 있음
    task automatic multiply(input logic [3:0] a, input logic [3:0] b);
        logic [7:0] expect_v;                       // [추가] 정답 = a × b (8비트)
        expect_v = a * b;

        //load
        @(negedge clk);
        ier  = a;                                   // [수정] 고정값 대신 task 입력 사용
        cand = b;
        @(negedge clk);                             // [수정] posedge+#1 대신 negedge+#1로 통일
        #1 check($sformatf("%0d x %0d: before st", a, b),
                 dut.current.name() == "standby");   // st 안 눌렀으니 그대로 대기

        //st activate and go to min state
        @(negedge clk);
        st = 1'b1;                                  // 하강 엣지에서 누름
        @(negedge clk);                             // [수정] 사이의 상승 엣지에서 Load + S1 이동
        st = 1'b0;                                  // [수정] 떼는 것도 하강 엣지에서 (규칙 1)
        #1 check($sformatf("%0d x %0d: st and loaded", a, b),
                 dut.current.name() == "min" &&
                 dut.acc == {5'b0, a});             // [추가] 위 5비트 0, 아래 4비트 = 승수

        wait (done == 1);                           // 몇 클럭 걸릴지 모르니 wait (상승 엣지 직후에 풀림)
        @(negedge clk);                             // [추가] 확인은 하강 엣지에서 (규칙 2) - 아직 Done 상태
        #1 check($sformatf("%0d x %0d = %0d", a, b, expect_v),
                 done && prod == expect_v);         // [추가] 이 TB의 진짜 목적: 결과 확인

        @(negedge clk);                             // [추가] Done 다음 클럭엔 S0으로 돌아와야 함
        #1 check($sformatf("%0d x %0d: back to standby", a, b),
                 dut.current.name() == "standby" && !done);
    endtask

    initial begin
        rst_n=0;                                    // [수정] DUT가 active-low 리셋 → 0이 리셋
        st=1'b0;                                   // [추가] st도 처음부터 0 (X 방지)
        ier=4'd0;
        cand=4'd0;
        repeat (2)@(negedge clk);
        rst_n=1;                                    // [수정] 1로 올려서 리셋 해제
        #1 check("Reset",
                 dut.current.name() == "standby");

        // [추가] 여러 경우 테스트
        multiply(4'd11, 4'd13);   // 1011 × 1101 = 143 (원래 네가 넣은 값)
        multiply(4'd5,  4'd3);    // 책 Table 18-2 예제 = 15
        multiply(4'd0,  4'd7);    // 승수 0 → 덧셈 없이 시프트만 = 0
        multiply(4'd15, 4'd15);   // 최댓값 = 225 (캐리가 ACC[8]까지 가는지)
        multiply(4'd8,  4'd1);    // 승수 MSB만 1 → 마지막 비트에서만 덧셈 = 8

        // [추가] 결과 요약
        repeat (2) @(negedge clk);
        if (errors == 0) $display("==== ALL PASS ====");
        else             $display("==== %0d FAIL ====", errors);
        $finish;                                    // [추가] 시뮬 종료
    end

    // [추가] 안전장치: done이 안 뜨면 wait에서 영원히 멈추므로 강제 종료
    initial begin
        #5000;
        $error("TIMEOUT: done이 안 뜸 (상태 전이나 K 확인)");
        $finish;
    end

endmodule