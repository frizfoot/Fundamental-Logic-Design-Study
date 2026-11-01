`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 02:32:00 AM
// Design Name: 
// Module Name: count
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


module count(
    input logic a,
    input logic b,
    input logic c,
    output logic [1:0] count
    );
    logic [7:0] y;
    decod38 u_decod(.a(a),.b(b),.c(c),.y(y));
    
    or g_msb (count[1], y[7], y[6], y[5], y[3]);   // 4입력 OR
    or g_lsb (count[0], y[7], y[4], y[2], y[1]);
    
endmodule
