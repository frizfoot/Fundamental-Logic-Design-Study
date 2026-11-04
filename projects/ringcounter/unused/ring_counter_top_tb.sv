`timescale 1ns / 1ps
 
module ring_counter_top_tb;
 
    logic clk;
    logic ce;
    logic preset_n;
    logic [7:0] T;
 
    ring_counter_top dut (
        .clk(clk),
        .ce(ce),
        .preset_n(preset_n),
        .T(T)
    );
 
    // 클럭 생성: 10ns 주기
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
 
    initial begin
        ce = 1;
 
        // 처음에 프리셋 걸어서 T0=1, 나머지=0 으로 초기화
        preset_n = 0;
        #12;
        preset_n = 1;
 
        // 두 바퀴(16클럭 = 160ns) 정도 관찰
        #170;
 
        $finish;
    end
 
    initial begin
        $monitor("time=%0t  T=%b  (T0=%b T1=%b T2=%b T3=%b T4=%b T5=%b T6=%b T7=%b)",
                  $time, T, T[0], T[1], T[2], T[3], T[4], T[5], T[6], T[7]);
    end
 
endmodule
 