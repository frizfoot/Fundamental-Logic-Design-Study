# full adder
> (한 줄 요약을 작성하세요)

### 작업 내용 및 핵심 설계
- Simple full adder using sum and Carry Out

### 테스트 / 트러블슈팅 메모
- 
module fullAdder(
    input a,
    input b,
    input ci,
    output s,
    output co
    );
    
    assign s=a^b^ci;
    assign co =a&b|b&ci|ci&a;
endmodule
