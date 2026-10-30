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
    logic a,b,ja,jb,ka,kb,ixb,xib,ixia,iixb,m;
    jkff ff1(.j(ja),.k(ka),.clk(clk),.o(a),.o2(),.rst_n(rst_n));
    jkff ff2(.j(jb),.k(kb),.clk(clk),.o(b),.o2(),.rst_n(rst_n));
    assign #3 ixb=~(~x&b);
    assign #3 xib=~(x&~b);
    assign #3 ixia=~(~x|~a);
    assign #2 iixb=~ixb;
    assign #3 m=~(ixb&xib);
    assign jb=ixia;
    assign kb=ixia;
    assign ja=m;
    assign ka=iixb;
    assign #3 z=a&b; 
endmodule
