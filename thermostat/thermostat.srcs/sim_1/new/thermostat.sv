`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2026 08:03:39 PM
// Design Name: 
// Module Name: thermostat
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module thermostat_tb;
    reg [2:0] presetTemp;
    reg [2:0] currentTemp;
    reg switch;
    
    wire fanOn;
    
    thermostat uut(
        .presetTemp(presetTemp),
        .currentTemp(currentTemp),
        .switch(switch),
        .fanOn(fanOn)
    );
    initial begin
        // 초기값 설정
        switch = 0;
        presetTemp = 3'd4; // 3비트 10진수 4
        currentTemp = 3'd2; // 3비트 10진수 2
        #10; 
        // 시나리오 1: 스위치 OFF (현재 온도가 더 높아도 선풍기는 꺼져야 함)
        presetTemp = 3'd3;
        currentTemp = 3'd6; 
        switch = 0;
        #10;
        // 시나리오 2: 스위치 ON (현재 온도가 6으로 더 높으므로 선풍기 켜짐)
        presetTemp = 3'd4; // 3비트 10진수 4
        currentTemp = 3'd2; // 3비트 10진수 2
        switch = 1;
        #10;
        // 시나리오 3: 스위치 ON 상태에서 온도가 같아짐 (선풍기 꺼짐)

        presetTemp = 3'd4; // 3비트 10진수 4
        currentTemp = 3'd6; // 3비트 10진수 2
        #10;
        // 시나리오 4: 스위치 ON 상태에서 현재 온도가 더 낮아짐 (선풍기 꺼짐)
        presetTemp = 3'd4; // 3비트 10진수 4
        currentTemp = 3'd2; // 3비트 10진수 2
        #10;
        // 시뮬레이션 종료
        $finish;
    end

endmodule