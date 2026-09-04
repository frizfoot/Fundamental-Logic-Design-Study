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
    output s,
    output co
    );
    assign s=a^b;
    assign co=a&b;
endmodule
