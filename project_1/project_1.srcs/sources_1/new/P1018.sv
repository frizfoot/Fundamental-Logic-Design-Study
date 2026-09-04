`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2026 12:34:33 AM
// Design Name: 
// Module Name: P1018
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


module P1018(
    input logic A,
    input logic B,
    input logic C,
    input logic D,
    output logic E

    );
    logic I,J;
    
    assign #4 I=~(A&B);
    assign #4 J=~(C&D);
    assign #4 E=~(I&J);
endmodule
