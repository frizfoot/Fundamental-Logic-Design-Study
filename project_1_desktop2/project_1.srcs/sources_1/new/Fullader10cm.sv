`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 01:23:00 AM
// Design Name: 
// Module Name: P10C
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
module P10C(
    input a,
    input b,
    input cin,
    output s,
    output co
    );
    logic s1,co1,s2,co2,s3,co3;
    
    P10C u_halfadder(.a(a),.b(b),.s(s1),.co(co1));
    P10C u_halfadder2(.a(s1),.b(cin),.s(s),.co(co));

endmodule
