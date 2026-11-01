`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2026 12:08:37 AM
// Design Name: 
// Module Name: P1011
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


module P1011#(
    parameter WIDTH=2
)(
    input logic A,B,D,E,
    output logic H
    );
    assign H = A | ~B | ~D | ~E;
endmodule
