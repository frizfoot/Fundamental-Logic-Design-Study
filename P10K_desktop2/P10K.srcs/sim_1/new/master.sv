`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 09:53:13 AM
// Design Name: 
// Module Name: master
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


module master(
    input logic [5:0]i0,
    input logic [5:0]i1,
    input logic [5:0]i2,
    input logic [5:0]i3,
    input logic [1:0]e,
    output wire [5:0] f 
    );
    logic [3:0]enable;
    decod24 enab(.a(e),.b(enable)); 
    buffer3 buff0(.a(i0),.e(enable[0]),.b(f));
    buffer3 buff1(.a(i1),.e(enable[1]),.b(f));
    buffer3 buff2(.a(i2),.e(enable[2]),.b(f));
    buffer3 buff3(.a(i3),.e(enable[3]),.b(f));
endmodule
