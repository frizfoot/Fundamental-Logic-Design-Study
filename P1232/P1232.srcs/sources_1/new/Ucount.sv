`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2026 11:20:44 AM
// Design Name: 
// Module Name: Ucount
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


module Ucount(
    input logic rst_n,
    input logic clk,
    output logic [2:0]q 
    );
    logic q0,q1,q2;
    always_ff@(posedge clk) begin
        q0f SRff(
            .r(q0),
            .s(1'b1),
            .q(q0),
            .clk(clk)
            );
        q1f SRff(
            .r(q0&q1),
            .s(q0),
            .q(q1),
            .clk(clk)
            );
        q2f SRff(
            .r(q2&q1&q0),
            .s(q0&q1),
            .q(q2),
            .clk(clk)
            );
        end
endmodule
