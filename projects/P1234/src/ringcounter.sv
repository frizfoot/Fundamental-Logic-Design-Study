`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Module Name: ring_counter_jk
// Description: 8-stage Ring Counter using J-K flip-flops (negedge triggered)
//              Generates 8 sequential single-cycle pulses T0~T7,
//              as required by Problem 12.34(a).
//
//              J-K wiring rule to make each FF copy the previous stage's Q
//              (D flip-flop 동작을 J-K로 구현):
//                  J_i = Q_(i-1)
//                  K_i = ~Q_(i-1)   (J의 보수)
//              FF0 is fed back from FF7 (ring / circular connection).
//////////////////////////////////////////////////////////////////////////////

module ring_counter_jk(
    input  logic clk,      // negedge에서 동작
    input  logic preset_n, // 비동기 프리셋 (active-low): T[0]=1, 나머지=0 으로 초기화
    output logic [7:0] T   // T0 ~ T7 (T[0]=T0, ..., T[7]=T7)
    );

    // 내부적으로 J, K 신호를 명시적으로 표현 (교육/검증 목적)
    logic [7:0] J, K;

    // ---------------------------------------------------------------
    // J-K 입력 방정식 (조합 로직)
    // J_i = Q_(i-1),  K_i = ~Q_(i-1)   (i-1은 mod 8, 즉 링 구조)
    // ---------------------------------------------------------------
    assign J[0] = T[7];   // FF0은 FF7(마지막 단)에서 피드백
    assign K[0] = ~T[7];

    genvar i;
    generate
        for (i = 1; i < 8; i++) begin : jk_input_gen
            assign J[i] = T[i-1];
            assign K[i] = ~T[i-1];
        end
    endgenerate

    // ---------------------------------------------------------------
    // 8개의 J-K 플립플롭 (negedge clk, 비동기 preset)
    // Q+ = J*Q' + K'*Q  (J-K FF 특성방정식)
    // ---------------------------------------------------------------
    genvar k;
    generate
        for (k = 0; k < 8; k++) begin : jk_ff_gen
            always_ff @(negedge clk or negedge preset_n) begin
                if (!preset_n) begin
                    // 초기값: FF0(T0)만 1, 나머지는 0
                    T[k] <= (k == 0) ? 1'b1 : 1'b0;
                end else begin
                    T[k] <= (J[k] & ~T[k]) | (~K[k] & T[k]);
                end
            end
        end
    endgenerate

endmodule
