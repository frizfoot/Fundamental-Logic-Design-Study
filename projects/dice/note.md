# dice
> (한 줄 요약을 작성하세요)

### 작업 내용 및 핵심 설계
- <img width="1558" height="1766" alt="image" src="https://github.com/user-attachments/assets/6bd1e035-9979-4bc8-afd4-7c30af80a512" />

Fundamental Logic Design Figure 19-11을 SM차트 그린 후 SV로 구현

### 테스트 / 트러블슈팅 메모
1차 작성한 SV:

    'timescale 1ns / 1ps
    module main(
        
        input logic rb,clk,
        input logic rst,rst_n,//rst is reset input button while rst_n is total reset no matter what
        output logic won, lost
        );
        //6 states
        
        typedef enum logic [2:0]{
            standby1=3'b000,
            roll1=3'b001,
            win=3'b010,
            standby2=3'b011,
            lose=3'b101,
            roll2=3'b100
            } state_t;
            
            state_t current,next;
            
            always_ff@(posedge clk or negedge rst_n) begin
                if (!rst_n)  
                    current<=standby1;
                else current<=next;
            end
                    
            logic [2:0]counter1;
            logic [2:0]counter2;
            logic [3:0]sum;
            logic roll;
            logic [3:0]point;
            logic [3:0]display1;
            logic [3:0]display2;
            
            //fsm sm chart to SV
            always_comb begin
                next=current;
                roll=1'b0;//set default it is a signal that enables counter to roll
                point=3'b0000;
                
                case(current)
                    standby1: begin //s0
                        if (!rb) next=standby1;
                        else if (rb) next=roll1;
                    end
                    
                    roll1: begin //s1
                        if(rb) begin
                            next=roll1;
                            roll=1'b1; //use roll to roll counter
                        end
                        
                        else if (!rb)
                            roll=1'b0;
                            if (sum==7|11) begin
                                next=win;
                            end
                            else if (sum==2|3|12) begin 
                                next=lose;
                            end
                            else
                                point=sum; //point is saved by sum
                                next=standby2;
                    end
                    
                    standby2: begin //s3
                        if (!rb) next=standby2;
                        else if (rb) next=roll2;
                    end
                    
                    roll2: begin //s5
                        if(rb) begin
                            next=roll2;
                            roll=1'b1;//use roll to roll counter
                        end
                        
                        else if (!rb)
                            roll=1'b0;
                            if (sum==point) begin//check if the sum is equal topoint that is saved
                                next=win;
                            end
                            else if (sum==7) begin
                                next=lose;
                            end
                            else
                                next=standby2;                        
                    end
                   
                    win: begin //s2
                        if(!rst) next=win;
                        else next=standby1;
                    end
                    lose: begin //s2
                        if(!rst) next=lose;
                        else next=standby1;
                    end
                endcase
            end
            
    
            //Dice counter
            always_ff@(posedge clk or negedge rst_n) begin
                if(!rst_n)begin
                    counter1<=3'd1;
                    counter2<=3'd1;
                end
                else if(roll==1) begin
                    if(counter1==3'd6) begin
                        counter1<=3'd1;
                    end
                    else counter1<=counter1+3'd1;
                    
                    if(counter2==3'd6) begin
                        counter2<=3'd1;
                    end
                    else counter2<=counter2+3'd1;
                end
                
                else if (!roll) begin
                    display1=counter1;
                    display2=counter2;
                end
            end
            
            always_ff@(negedge clk or negedge rst_n) begin// I did negedge clk because counter1 and 2 values are set at posedge which mean at the next negedge will give proper counter1,2 values
                if (!rst_n) begin
                    sum<=3'd0;
                end
                else if (!roll) 
                    sum=counter1+counter2;
                end  
            
    endmodule

Claude F/B:

**60점.** 구조는 잘 잡았어. 그런데 시뮬레이션을 돌리면 동작이 크게 틀릴 버그가 몇 개 있어. 심각한 것부터 힌트로 줄게.

## 잘한 점
- 리셋 두 종류를 구분하고 주석으로 이유까지 남겼어 (rst 버튼 vs rst_n 전체 리셋).
- roll을 따로 신호로 만들고 기본값을 0으로 뒀어.
- 카운터가 1→6→1로 도는 것 정확해.

## 꼭 고쳐야 할 것 (동작이 틀림)

**1. `else if (!rb)` 다음에 `begin`이 없어**
- `begin/end` 없이 쓰면 바로 다음 한 줄만 else에 속해.
- 그러면 그 아래 `if (sum==...)`는 rb와 상관없이 항상 실행돼.
- 맨 끝 `else point=sum; next=standby2;`도 같은 문제야. `next=standby2`가 어디에 속할까?

**2. `sum==7|11`은 네 생각대로 계산되지 않아**
- 연산자 우선순위상 `==`가 `|`보다 먼저 계산돼.
- 그러면 `(sum==7) | 11`이 되는데, 이 값은 항상 몇일까?

**3. 두 카운터가 항상 같이 움직여**
- 둘이 동시에 1→6을 돌면 두 눈이 항상 같아.
- 그러면 합이 7이나 11이 나올 수 있을까?

**4. point가 기억을 못 해**
- `always_comb`에서 매번 0으로 초기화하니까, 다음 클럭엔 저장한 값이 사라져.
- 기억해야 하는 값은 어디에 써야 하지? (곱셈기 ACC는 어디 있었어?)
- 거기에 Sp 신호까지 만들면 책 구조와 똑같아져.

**5. won, lost 출력을 아무 데서도 안 정해 줘**
- 포트만 선언했고 값을 넣는 곳이 없어.

## 다듬을 것

**6. sum은 negedge 플립플롭일 필요가 없어**
- 카운터 값은 상승 엣지 직후 바로 안정돼.
- 컨트롤러가 그 값을 쓰는 건 다음 상승 엣지야.
- 그래서 sum은 조합(`assign`)이면 충분해. 클럭 엣지를 섞으면 반 클럭짜리 경로가 생겨서 오히려 위험해.

**7. display1/2**
- `always_ff` 안에서 `=`(blocking)를 쓰고 있어.
- 화면에 보여야 하는데 출력 포트가 아니야.
- 카운터 값을 그대로 보여 주면 되는 신호야.

**8. 기타**
- `case`에 `default`가 없어. 3비트 중 6개만 써서 남는 코드 2개가 있어.
- `point=3'b0000`, `sum<=3'd0`처럼 신호 폭과 숫자 폭이 안 맞아.
- 주석 상태 번호가 틀렸어 (lose가 //s2).

1~5번만 고쳐도 동작할 거야. 고치면 TB 짜기 전에 다시 보여 줘.

위의 코드 버그 수정점 정리

버그	교훈
\documentclass{article}
\usepackage{kotex}      % 한글
\usepackage{tabularx}   % 칸 너비 자동 줄바꿈
\usepackage{booktabs}   % 깔끔한 가로줄

\begin{document}

\section*{주사위 게임 컨트롤러 디버깅 정리}

\begin{tabularx}{\textwidth}{l X}
\toprule
\textbf{버그} & \textbf{교훈} \\
\midrule
\texttt{else} 뒤 두 줄
  & 두 줄 이상은 무조건 \texttt{begin}/\texttt{end} \\
\texttt{sum==7|11}
  & \texttt{||} 양쪽은 각각 완전한 비교식 \\
두 카운터 동시 증가
  & 앞 카운터가 한 바퀴 돌면 다음 카운터가 한 칸 (시계 원리) \\
\texttt{point}가 사라짐
  & 기억할 값은 \texttt{always\_ff}, 컨트롤러는 명령 신호(\texttt{lp})만 \\
\texttt{lp} 기본값 없음
  & \texttt{always\_comb}의 모든 출력에 기본값 (래치 방지) \\
\texttt{sum}이 FF
  & 바로 계산되는 값은 \texttt{assign} \\
\bottomrule
\end{tabularx}

\end{document}
