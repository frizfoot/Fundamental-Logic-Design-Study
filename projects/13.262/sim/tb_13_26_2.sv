`timescale 1ns / 1ps

module tb_13_26_2;

    parameter real T = 10.0;        // 상승엣지: 5, 15, 25, 35

    logic clk = 1'b0, x1, x2;
    logic z1, z2;

    main dut(.x1(x1), .x2(x2), .clk(clk), .z1(z1), .z2(z2));

    wire [1:0] q = dut.q;
    wire [1:0] d = {dut.d1, dut.d2};

    always #(T/2) clk = ~clk;

    //──────────────────────────────────────────────
    //  t=0    X=10 인가, Q=00      ← 첫 엣지부터 바로 일함
    //  t=5    엣지 ①   X1X2 = 10
    //  t=7.5  X → 01               (상승↔하강 중간)
    //  t=15   엣지 ②   X1X2 = 01
    //  t=17.5 X → 11
    //  t=25   엣지 ③   X1X2 = 11
    //  t=27.5 X → 10
    //  t=35   엣지 ④   X1X2 = 10
    //──────────────────────────────────────────────
    initial begin
        {x1,x2} = 2'b10;
        #7.5  {x1,x2} = 2'b01;
        #10   {x1,x2} = 2'b11;
        #10   {x1,x2} = 2'b10;
    end

    localparam int N = 4;
    bit [1:0] exp_q [N] = '{2'b00, 2'b01, 2'b11, 2'b01};
    bit [1:0] exp_z [N] = '{2'b10, 2'b10, 2'b00, 2'b01};

    bit [1:0] post_z [N];              // 엣지 직후 값 저장
    bit [1:0] post_q [N];
    int errors = 0;

    initial begin
        $display("──────────────────────────────────────────────────────────");
        $display("  # │ 엣지직전(정답)          │ 엣지직후(전이구간)");
        $display("    │ t     Q   X    Z        │ t     Q   X    Z");
        $display("────┼─────────────────────────┼────────────────────────────");

        #(T/2 - 1);                                     // t = 4
        for (int i = 0; i < N; i++) begin
            $write("  %0d │ %4.1f  %b  %b%b   %b%b       │",
                   i+1, $realtime, q, x1, x2, z1, z2);
            if (q !== exp_q[i] || {z1,z2} !== exp_z[i]) errors++;

            #2;                                          // 엣지 1ns 후 (6,16,26,36)
            post_q[i] = q;  post_z[i] = {z1,z2};
            $display(" %4.1f  %b  %b%b   %b%b",
                     $realtime, q, x1, x2, z1, z2);

            #(T - 2);                                    // 다음 엣지 1ns 전
        end

        $display("──────────────────────────────────────────────────────────");
        for (int i = 0; i < N-1; i++)
            if (post_z[i] !== exp_z[i+1])
                $display("  ★ FALSE OUTPUT : 클럭 %0d 직후 Z=%b  (다음 정답은 %b)",
                         i+1, post_z[i], exp_z[i+1]);
        $display("──────────────────────────────────────────────────────────");
        $display(errors == 0 ? "정답 출력 PASS" : "FAIL: %0d", errors);
    end

    initial begin
        $timeformat(-9, 1, " ns", 7);
        $monitor("%t | clk=%b  X=%b%b  Q=%b  D=%b  Z=%b%b",
                 $realtime, clk, x1, x2, q, d, z1, z2);
    end

    initial begin
        #45;
        $finish;
    end
endmodule