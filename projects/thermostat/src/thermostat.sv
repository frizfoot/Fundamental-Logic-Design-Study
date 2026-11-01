`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2026 07:59:23 PM
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


module thermostat(
    input [2:0] presetTemp,currentTemp,
    input switch,
    output fanOn
    );
    assign fanOn=switch&(currentTemp>presetTemp);
endmodule
