`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 01:24:19 AM
// Design Name: 
// Module Name: master
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


module master(
    input logic [7:0]y,
    output logic a,
    output logic b,
    output logic c,
    output logic d
    );
    logic cm,cl,bm,bl,am,al;
    pEnc msben(
        .y(y[7:4]),
        .a(am),
        .b(bm),
        .c(cm));
    pEnc lsben(.y(y[3:0]),.a(al),.b(bl),.c(cl));
    assign d= cm | cl;
    mux21 validc(.I0(bl),.I1(bm),.e(cm),.f(c));
    mux21 validb(.I0(al),.I1(am),.e(cm),.f(b));
    assign a=cm;  
endmodule
