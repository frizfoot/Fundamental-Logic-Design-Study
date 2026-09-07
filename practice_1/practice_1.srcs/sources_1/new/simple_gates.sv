`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2026 11:03:11 PM
// Design Name: 
// Module Name: simple_gates
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


module simple_gates(
    input a,
    input b,
    output and_out,
    output or_out
    );
    
    assign and_out = a & b;
    assign or_out  = a | b;
   
endmodule
