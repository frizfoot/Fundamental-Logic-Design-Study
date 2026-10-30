`timescale 1ns / 1ps

module sim1;
    parameter real T = 10.0;
    // 상승엣지 5,15,25,...  /  하강엣지 10,20,30,...  (하강 트리거)

    logic clk = 1'b0, x;
    logic z;

    main dut(.x(x), .clk(clk), .z(z));
    wire q1 = dut.q1;
    wire q2 = dut.q2;

    always #(T/2) clk = ~clk;

    // X = 1 0 0 1 1,  하강엣지 사이 중간(=상승엣지)에 변경
    initial begin
        x = 1'b1;          // ① t=10 엣지에 유효
        #15 x = 1'b0;      // ② t=15
        #10 x = 1'b0;      // ③ t=25
        #10 x = 1'b1;      // ④ t=35
        #10 x = 1'b1;      // ⑤ t=45
    end

    localparam int N = 5;
    bit       exp_z [N] = '{1'b1, 1'b1, 1'b1, 1'b0, 1'b1};
    bit [1:0] exp_q [N] = '{2'b00, 2'b01, 2'b01, 2'b01, 2'b10};
    int errors = 0;

    initial begin
        $display("──────────────────────────────────────────────────────");
        $display("  # │ 엣지직전(정답)        │ 엣지직후(전이)");
        $display("────┼───────────────────────┼─────────────────────────");
        #(T - 1);                                  // t = 9
        for (int i = 0; i < N; i++) begin
            $write("  %0d │ %4.1f Q=%b%b X=%b Z=%b%s │",
                   i+1, $realtime, q1, q2, x, z,
                   ({q1,q2}===exp_q[i] && z===exp_z[i]) ? "  " : " ✗");
            if ({q1,q2}!==exp_q[i] || z!==exp_z[i]) errors++;
            #2;                                    // 11,21,31,41,51
            $display(" %4.1f Q=%b%b X=%b Z=%b",
                     $realtime, q1, q2, x, z);
            #(T-2);
        end
        $display("──────────────────────────────────────────────────────");
        $display(errors==0 ? "=== PASS ===" : "=== FAIL: %0d ===", errors);
        $finish;
    end

    initial begin
        $timeformat(-9, 1, " ns", 7);
        $monitor("%t | clk=%b X=%b Q=%b%b D=%b%b Z=%b",
                 $realtime, clk, x, q1, q2, dut.d1, dut.d2, z);
    end
endmodule