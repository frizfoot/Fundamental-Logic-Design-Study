`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 12:30:48 PM
// Design Name: 
// Module Name: jkff
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


module jkff(
    input logic j,
    input logic k,
    input logic clk,rst_n,
    output logic o,
    output logic o2
    );
    assign o2=~o;
    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) o <= 1'b0;
        else        o <= (j & ~o) | (~k & o);
    end
endmodule
