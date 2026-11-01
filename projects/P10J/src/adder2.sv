`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 01:34:35 AM
// Design Name: 
// Module Name: adder2
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


module adder2(
    input logic [3:0]a,
    input logic [3:0]b,
    input logic cin,
    output logic [3:0]s,
    output logic co
    );
    logic [4:0]sn;
    assign sn=a+b+cin;
    assign s=sn[3:0];
    assign co=sn[4];
endmodule
