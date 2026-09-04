`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2026 12:50:48 AM
// Design Name: 
// Module Name: P1010
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


module P1010(
    input logic P,Q,N, output logic R
);
    logic L,M;
    assign #10ns L= ~(P & Q);
    assign #5ns M= ~(L | N);
    assign R=~M;
    
endmodule
