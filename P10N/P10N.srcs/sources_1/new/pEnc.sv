`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 10:24:01 PM
// Design Name: 
// Module Name: pEnc
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


module pEnc(
    input logic i0,
    input logic i1,
    input logic i2,
    input logic i3,
    input logic e,
    output logic a,
    output logic b,
    output logic c
    );
    assign a=e&(i0|i1);
    assign b=e&(i0| (~i1 & i2));
    assign c= e&(i0|i1|i2|i3);
endmodule
