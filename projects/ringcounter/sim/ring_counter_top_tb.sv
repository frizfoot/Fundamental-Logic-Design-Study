`timescale 1ns / 1ps
 
module ring_counter_top_tb;
 
    logic clk;
    logic ce;
    logic preset;
    logic [7:0] t;
 
    ring_counter_top dut (
        .clk(clk),
        .ce(ce),
        .preset(preset),
        .t(t)
    );
 
    // 클럭 생성: 10ns 주기
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
 
    initial begin
        ce = 1;
 
        // 처음에 프리셋 걸어서 t0=1, 나머지=0 으로 초기화
        // preset은 active-low(preset_n)로 flip 모듈에 연결되므로 0=프리셋 동작
        preset = 0;
        #12;
        preset = 1;
 
        // 두 바퀴(16클럭 = 160ns) 정도 관찰
        #170;
 
        $finish;
    end
 
    initial begin
        $monitor("time=%0t  t=%b  (t0=%b t1=%b t2=%b t3=%b t4=%b t5=%b t6=%b t7=%b)",
                  $time, t, t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7]);
    end
 
endmodule
 