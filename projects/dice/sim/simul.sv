`timescale 1ns / 1ps
// =====================================================================
// 주사위 게임 테스트벤치 (주사위 합을 직접 넣는 방식)
//
//  - rb로 카운터를 돌리지 않고, force로 dut.sum에 원하는 합을 직접 넣음
//  - sum1 = 첫 굴림 합, sum2 = 두 번째 이후 굴림 합
//  - 확인 항목
//      1) sum1 = 7, 11      → win
//      2) sum1 = 2, 3, 12   → lose
//      3) sum2 = 7          → lose
//      4) sum2 = point      → win
//  - [추가] 표시는 네 계획 외에 내가 덧붙인 부분
// =====================================================================

module simul;
    logic rb,clk,rst_n,rst;
    logic won,lost;
    logic [3:0] display1,display2;

    main dut(.*);
    int errors=0;

    initial clk=0;
    always#5 clk=~clk;

    task automatic check(input string name, input logic ok);
        if (ok)
            $display("[PASS] %-32s t=%0t", name, $time);
        else begin
            errors++;
            $error("[FAIL] %s t=%0t | state=%s | c1=%0d c2=%0d sum=%0d point=%0d | rb=%b rst=%b | won=%b lost=%b",
                   name, $time, dut.current.name(),
                   dut.counter1, dut.counter2, dut.sum, dut.point,
                   rb, rst,
                   won, lost);
        end
    endtask

    // ---------------------------------------------------------------
    // 굴리기 1번: 합을 s로 고정해 놓고 rb를 눌렀다 뗌
    //   force   : 신호 값을 TB가 강제로 덮어씀 (DUT 코드는 그대로)
    //   release : 강제 해제 → 원래 값(counter1 + counter2)으로 돌아감
    // ---------------------------------------------------------------
    logic [3:0] forced_sum;     // force에 쓸 값 (task 밖에 선언해야 함)

    task automatic roll_with(input int s);
        @(negedge clk);
        forced_sum = s;
        force dut.sum = forced_sum;   // 합을 원하는 값으로 고정
        rb = 1;                 // 누름 → 다음 상승 엣지에서 roll 상태로
        @(negedge clk);
        rb = 0;                 // 뗌   → 다음 상승 엣지에서 sum 보고 판단
        @(negedge clk);         // 판단이 끝난 뒤
        #1;                     // 값이 안정되면 확인할 준비 완료
    endtask

    // 승/패 뒤 게임 리셋 버튼(rst) 한 클럭 누르기
    task automatic new_game();
        release dut.sum;        // 강제 해제
        @(negedge clk); rst = 1;
        @(negedge clk); rst = 0;
        #1 check("new game -> standby1", dut.current.name() == "standby1");
    endtask

    int sum1, sum2;
    int win_first[]  = '{7, 11};       // 첫 굴림 승리 합
    int lose_first[] = '{2, 3, 12};    // 첫 굴림 패배 합

    initial begin

        rst_n=0;
        rb=0;
        rst=0;
        repeat (2)@(negedge clk); //2 times for initial settle

        //reset everything
        rst_n=1;
        #1 check("Reset", dut.current.name() =="standby1");

        // ---- 1) sum1 = 7, 11 → win ----
        foreach (win_first[i]) begin
            sum1 = win_first[i];
            roll_with(sum1);
            check($sformatf("sum1=%0d -> win", sum1),
                  dut.current.name() == "win" && won && !lost);
            new_game();
        end

        // ---- 2) sum1 = 2, 3, 12 → lose ----
        foreach (lose_first[i]) begin
            sum1 = lose_first[i];
            roll_with(sum1);
            check($sformatf("sum1=%0d -> lose", sum1),
                  dut.current.name() == "lose" && lost && !won);
            new_game();
        end

        // ---- 3) sum2 = 7 → lose ----
        sum1 = 6;                              // 포인트 6 만들기
        roll_with(sum1);
        check("sum1=6 -> point saved",
              dut.current.name() == "standby2" && dut.point == 6);
        sum2 = 7;
        roll_with(sum2);
        check("sum2=7 -> lose",
              dut.current.name() == "lose" && lost && !won);
        new_game();

        // ---- 4) sum2 = point → win ----
        sum1 = 8;                              // 포인트 8 만들기
        roll_with(sum1);
        check("sum1=8 -> point saved",
              dut.current.name() == "standby2" && dut.point == 8);
        sum2 = 5;                              // [추가] 승패 없음 → 포인트가 안 덮어써지는지
        roll_with(sum2);
        check("sum2=5 -> continue, point kept",
              dut.current.name() == "standby2" && dut.point == 8 && !won && !lost);
        sum2 = 8;
        roll_with(sum2);
        check("sum2=8 (=point) -> win",
              dut.current.name() == "win" && won && !lost);
        new_game();

        // ---- 결과 ----
        if (errors == 0) $display("==== ALL PASS ====");
        else             $display("==== %0d FAIL ====", errors);
        $finish;
    end

    // [추가] 안전장치
    initial begin
        #5000;
        $error("TIMEOUT");
        $finish;
    end

endmodule