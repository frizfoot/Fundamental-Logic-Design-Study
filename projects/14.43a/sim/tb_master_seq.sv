`timescale 1ns/1ps
//=============================================================
//  tb_master_seq.sv
//  Manchester 비트열을 "적힌 순서 그대로" 한 클럭에 하나씩 넣고,
//  z 가 기대한 NRZ 수열과 맞는지 한 칸씩 비교한다.
//=============================================================
module tb_master_seq;

    localparam int L = 16;                       // Clock2 주기 개수 (= 데이터 8비트)

    // [0:L-1] 로 선언하면 왼쪽 글자가 인덱스 0 - 적은 순서 그대로 읽힌다
    logic [0:L-1] MAN = 16'b0110101001011001;    // 입력  (Manchester)
    logic [0:L-1] EXP = 16'b0011111100001100;    // 기대 출력 (NRZ)
    logic [0:L-1] GOT;                           // 실제로 나온 값

    logic clk = 1'b0, rst_n = 1'b0, x = 1'b0;
    logic z;

    master #(.dc1(1'b0), .dc2(1'b1)) dut (
        .x(x), .clk(clk), .rst_n(rst_n), .z(z)
    );

    always #5 clk = ~clk;                        // 주기 10ns

    int i, errors = 0;

    initial begin
        $dumpfile("seq.vcd");
        $dumpvars(0, tb_master_seq);

        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        for (i = 0; i < L; i++) begin
            @(posedge clk);  #1  x = MAN[i];     // 입력은 엣지보다 1ns 늦게 바뀐다
            @(negedge clk);       GOT[i] = z;    // 주기 한가운데 - z 가 안정된 지점에서 읽기
        end

        @(posedge clk); #1 x = 1'b0;
        repeat (2) @(posedge clk);

        // ---------------- 결과 ----------------
        $display("");
        $display("  입력 MAN : %b", MAN);
        $display("  기대 EXP : %b", EXP);
        $display("  실제 GOT : %b", GOT);
        $display("");
        $display("   n | x | z | 기대 | 판정");
        $display("  ---+---+---+------+------");
        for (i = 0; i < L; i++) begin
            if (GOT[i] !== EXP[i]) errors++;
            $display("  %2d | %b | %b |  %b   |  %s",
                     i, MAN[i], GOT[i], EXP[i], (GOT[i]===EXP[i]) ? "O" : "X");
        end
        $display("");
        if (errors == 0) $display("  PASS  -  16칸 전부 일치");
        else             $display("  FAIL  -  불일치 %0d 칸", errors);
        $display("");
        $finish;
    end
endmodule