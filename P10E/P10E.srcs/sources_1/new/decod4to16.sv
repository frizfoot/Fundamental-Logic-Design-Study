`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 10:52:28 PM
// Design Name: 
// Module Name: decod4to16
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


module decod4to16(
    input logic [3:0] a,
    output logic [15:0] f
    );
    always_comb begin
        f=16'b0;
        f[a]=1'b1;
    end
endmodule
