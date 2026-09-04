`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 01:51:31 AM
// Design Name: 
// Module Name: fulladder
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


module fulladder(
    input logic a,
    input logic b,
    input logic cin,
    output logic  sum,
    output logic co
    );
    logic s1,co1,s2,co2;
    P10C u_hadder(.a(a),.b(b),.s(s1),.co(co1));
    P10C u_hadder2(.a(s1),.b(cin),.s(sum),.co(co2));
    assign co=co1|co2;
endmodule
