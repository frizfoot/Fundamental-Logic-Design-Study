`timescale 1ns/1ps
//=============================================================================
//  tb_1411.sv  -  문제 14.11 테스트벤치
//
//  핵심 아이디어 : DUT 와 "다른 방식으로" 만든 기준 모델과 매 클럭 비교한다.
//    DUT   = 상태 5개짜리 상태기계
//    기준  = 카운터 기반 (실제 메모리 컨트롤러가 쓰는 방식)
//  같은 방식으로 두 번 짜면 같은 실수를 두 번 하므로, 일부러 다르게 만든다.
//
//  시나리오 5개를 돌린다 - 정상 1개 + 극단 4개
//=============================================================================
module tb_1411;

    logic clk = 1'b0, rst_n = 1'b0, x = 1'b0;
    logic z;

    master dut (.clk(clk), .rst_n(rst_n), .x(x), .z(z));

    always #5 clk = ~clk;                 // 주기 10ns

    //-------------------------------------------------------------------------
    // 기준 모델 (카운터 방식)
    //   remaining : 앞으로 더 내보내야 할 Z=1 클럭 수
    //   blocked   : 손을 떼기 전까지 새 펄스 금지
    //-------------------------------------------------------------------------
    int  remaining = 0;
    bit  blocked   = 0;
    logic z_exp;

    task automatic ref_reset();
        remaining = 0;  blocked = 0;
    endtask

    task automatic ref_step(input logic xv);
        if (remaining > 0) begin                 // 펄스 진행 중 - x 는 보지 않는다
            z_exp = 1'b1;
            remaining--;
            if (remaining == 0) blocked = 1;     // 4클럭 끝 → 손 뗄 때까지 금지
        end
        else if (blocked) begin                  // 대기 중
            z_exp = 1'b0;
            if (!xv) blocked = 0;                // 손을 떼면 풀린다
        end
        else begin                               // 대기 상태
            z_exp = xv;                          // Mealy - 누른 그 클럭에 바로 1
            if (xv) remaining = 3;               // 이번 1클럭 + 앞으로 3클럭 = 4
        end
    endtask

    //-------------------------------------------------------------------------
    // 한 클럭 진행 + 비교
    //-------------------------------------------------------------------------
    int cyc = 0, errors = 0;
    string s_x, s_got, s_exp;

    task automatic step (input logic xv);
        @(posedge clk);  #1  x = xv;      // 입력은 엣지보다 1ns 늦게 (실제 회로와 동일)
        ref_step(xv);
        @(negedge clk);                   // 주기 한가운데 - 안정된 지점에서 비교
        cyc++;
        s_x   = {s_x,   xv    ? "1" : "0"};
        s_got = {s_got, z     ? "1" : "0"};
        s_exp = {s_exp, z_exp ? "1" : "0"};
        if (z !== z_exp) errors++;
    endtask

    task automatic do_reset();
        rst_n = 1'b0;
        x     = 1'b0;          // 리셋 중에는 입력도 쉬게 둔다 (실제 시스템과 동일)
        ref_reset();
        @(posedge clk); #1;
        @(posedge clk); #1  rst_n = 1'b1;
    endtask

    task automatic banner(input string name);
        s_x = "";  s_got = "";  s_exp = "";
    endtask

    task automatic report(input string name);
        $display("  %-28s  X=%s", name, s_x);
        $display("  %-28s  기대=%s", "", s_exp);
        $display("  %-28s  실제=%s   %s", "", s_got,
                 (s_got == s_exp) ? "OK" : "MISMATCH <<<<");
        $display("");
    endtask

    int i;

    initial begin
        $dumpfile("tb_1411.vcd");
        $dumpvars(0, tb_1411);
        $display("");
        $display("  ===== 문제 14.11 : 4클럭 펄스 생성기 =====");
        $display("");

        //--- 1. 정상 - 버튼을 길게 누름 -------------------------------------
        do_reset();  banner("1. 길게 누름");
        repeat(2) step(0);
        repeat(8) step(1);
        repeat(3) step(0);
        repeat(5) step(1);
        repeat(2) step(0);
        report("1. 길게 누름");

        //--- 2. 극단 - 1클럭만 누름 (펄스가 끊기면 안 된다) ------------------
        do_reset();  banner("2. 1클럭만 누름");
        repeat(2) step(0);
        step(1);
        repeat(8) step(0);
        report("2. 1클럭만 누름");

        //--- 3. 극단 - 떼자마자 바로 다시 누름 ------------------------------
        do_reset();  banner("3. 뗐다가 바로 재입력");
        repeat(2) step(0);
        repeat(5) step(1);          // 펄스 4 + 대기 1
        step(0);                    // 딱 1클럭만 뗌
        repeat(6) step(1);          // 바로 다시 누름 → 새 펄스가 나와야 함
        repeat(2) step(0);
        report("3. 뗐다가 바로 재입력");

        //--- 4. 극단 - 버튼 채터링 (기계식 스위치의 현실) --------------------
        do_reset();  banner("4. 채터링");
        repeat(2) step(0);
        step(1); step(0); step(1); step(1); step(0); step(1);
        repeat(8) step(1);
        repeat(2) step(0);
        report("4. 채터링");

        //--- 5. 극단 - 펄스 도중에 리셋 -------------------------------------
        do_reset();  banner("5. 펄스 중 리셋");
        repeat(2) step(0);
        repeat(2) step(1);          // 펄스 2클럭 진행한 상태에서
        do_reset();                 //   리셋!
        s_x = {s_x, "R"};  s_got = {s_got, "R"};  s_exp = {s_exp, "R"};
        repeat(2) step(0);
        repeat(6) step(1);          // 리셋 후 새 펄스가 정상으로 나와야 함
        repeat(2) step(0);
        report("5. 펄스 중 리셋");

        //--- 결과 -----------------------------------------------------------
        $display("  ------------------------------------------");
        if (errors == 0)
            $display("   PASS   -  %0d 클럭 전부 일치", cyc);
        else
            $display("   FAIL   -  %0d 클럭 중 %0d 개 불일치", cyc, errors);
        $display("");
        $finish;
    end
endmodule