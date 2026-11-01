`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2026 11:25:28 PM
// Design Name: 
// Module Name: P104
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


module P104 #(
    parameter int WIDTH=2
)(
    input logic A,
    input logic B,
    input logic C,
    input logic D,
    input logic E,
    output logic I
);
    logic F,G,N;
    assign F = ~A & B & C;
    assign G = D & ~ E;
    assign N = F ^ G;
    assign I=~ N;
endmodule
