`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 01:04:35 AM
// Design Name: 
// Module Name: adder
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


module adder(
    input logic [3:0]a,
    input logic [3:0]b,
    input logic ci,
    output logic [3:0]s,
    output logic co    
    );
    logic [3:0]p; 
    logic [3:0]g;
    logic [3:0]c;
    assign c[0]=ci;
    assign g=a&b;
    assign p=a^b;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign co =  g[3] | (p[3]&c[3]);
    assign s = a ^ b ^ c[3:0];
endmodule
