`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2026 11:47:31 PM
// Design Name: 
// Module Name: P1017
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


module P1017(
    input logic A,
    input logic B,
    input logic C,
    input logic D,
    output logic F

    );
    assign F= C&D&~A | ~C&D&B | C&~D&~B | ~C&~D&1'b0;
    
endmodule
