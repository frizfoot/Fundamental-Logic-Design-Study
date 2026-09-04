`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 01:52:23 AM
// Design Name: 
// Module Name: mas
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


module mas(
    input logic [7:0]a,
    input logic [7:0]b,
    output logic [7:0]c,
    output logic bo
    );
    logic [7:0]bcom;
    logic com,cout;
    assign bcom=~b;
    adder2 uaddL(.a(a[3:0]),.b(bcom[3:0]),.cin(1'b1),.s(c[3:0]),.co(com));
    adder2 uaddH(.a(a[7:4]),.b(bcom[7:4]),.cin(com),.s(c[7:4]),.co(cout));
    assign bo=~cout;   

endmodule
