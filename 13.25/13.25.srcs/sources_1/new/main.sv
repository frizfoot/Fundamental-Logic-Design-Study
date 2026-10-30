`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 10:39:16 PM
// Design Name: 
// Module Name: main
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


module main(
    input logic x,clk,
    output logic z
    );
    logic q1,q2,d1,d2;
    dff ff1(.d(d1),.clk(clk),.q(q1));
    dff ff2(.d(d2),.clk(clk),.q(q2));
    wire p1=~x&q1;
    wire p2=x&~q1&q2;
    wire p3=~x&q2;
    wire p4=x&~q1&~q2;
    wire p5=x&q1&~q2;
    
    assign d1=p1|p2;
    assign d2=p3|p4;
    assign z=p3|p4|p5;
    
endmodule
