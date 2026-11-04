`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2026 10:07:00 PM
// Design Name: 
// Module Name: flip
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


module flip(
    input logic clk,
    input logic ce,
    input logic preset_n,
    input logic j,
    input init_val,
    output logic t
    );
    logic k;
    assign #2 k=~j;
    always_ff@(negedge clk) begin
        if (!preset_n) begin
            t = init_val;   
        end else if (ce) begin
            t = (j & ~t) | (~k & t);   // J-K 특성방정식
        end
            ;
    end
endmodule
