`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2026 01:20:48 AM
// Design Name: 
// Module Name: ad42
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


module ad42(
    input A,
    input B,
    input C,
    input D,
    output Y
    );
    
    logic w0;
    logic w1;
    
    ad2 ad20 (.a(A),.b(B),.y(w0));
    ad2 ad21 (.a(C),.b(D),.y(w1));
    ad2 ad22 (.a(w0),.b(w1),.y(Y));
    
endmodule
