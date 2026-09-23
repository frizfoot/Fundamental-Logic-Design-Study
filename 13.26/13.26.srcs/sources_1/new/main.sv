`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 01:15:21 AM
// Design Name: 
// Module Name: main
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


module main(
    input logic x,
    input logic clk,rst_n,
    output logic z

    );
    logic a,b,ja,jb,ka,kb;
    jkff ff1(.j(ja),.k(ka),.clk(clk),.o(a),.o2(),.rst_n(rst_n));
    jkff ff2(.j(jb),.k(kb),.clk(clk),.o(b),.o2(),.rst_n(rst_n));
    assign jb=x&a;
    assign kb=x&a;
    assign ja=~x&b|x&~b;
    assign ka=~x&b;
    assign z=a&b; 
endmodule
