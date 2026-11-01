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


module mEnc(
    input logic [7:0]y,
    input logic e,
    output logic a,
    output logic b,
    output logic c,
    output logic d
    );
    logic ah,al,bh,bl,ch,cl,ea;
    
    pEnc endh(.i0(y[7]),.i1(y[6]),.i2(y[5]),.i3(y[4]),.e(e),.a(ah),.b(bh),.c(ch));
    assign ea = e & ~ ch;
    pEnc endl(.i0(y[3]),.i1(y[2]),.i2(y[1]),.i3(y[0]),.e(ea),.a(al),.b(bl),.c(cl));
    assign a=ch;
    assign b=ah|al;
    assign c=bh|bl;
    assign d= ch|cl;
endmodule
