`timescale 1ns / 1ps

module jkff(
    input  logic j,
    input  logic k,
    input  logic clk, rst_n,
    output logic o,
    output logic o2
);
    assign o2 = ~o;

    // ── setup 감시견 ──
    time t_j_last, t_k_last; //시간 변수

    always @(j) t_j_last = $time; //j가 변할때 현재의 시간($time)을 기록해라
    always @(k) t_k_last = $time; //k도 마찬가지로 기록해라

    always @(negedge clk) if (rst_n === 1'b1) begin// 클럭엣지에서
        if ($time - t_j_last < 2)//현재시간-j가 바뀐시간이 2보다 짧을 경우
            $display("[SETUP VIOL] %m  J  edge=%0t  last=%0t  margin=%0t",
                     $time, t_j_last, $time - t_j_last);
        if ($time - t_k_last < 2)
            $display("[SETUP VIOL] %m  K  edge=%0t  last=%0t  margin=%0t",
                     $time, t_k_last, $time - t_k_last);
    end

    // ── 플립플롭 본체 ──
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) o <= 1'b0;
        else        o <= #4 (j & ~o) | (~k & o);
    end
endmodule