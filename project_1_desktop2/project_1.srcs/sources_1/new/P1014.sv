`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2026 11:33:39 PM
// Design Name: 
// Module Name: P1014
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


module P1014(
    input logic [5:0]D,
    input logic [2:0]E, 
    output logic F
    );
    assign F=(~E & 3'b001) | (7'b0001000 & ~D);
endmodule
