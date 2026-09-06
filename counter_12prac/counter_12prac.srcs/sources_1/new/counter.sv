`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2026 07:26:31 PM
// Design Name: 
// Module Name: counter
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


module counter(
    input logic clk,
    input logic reset_n,
    output logic [2:0]cba
    );
    logic ta,tb,tc;
    assign ta=cba[2]|cba[1];
    assign tb=(cba[0]&(~cba[2]))|((~cba[1])&cba[2]);
    assign tc=(cba[1]&cba[2])|((~cba[1])&(~cba[2]));
    always_ff @ (posedge clk) begin
        if (!reset_n) begin
            cba <= 3'b000;
        end else begin
            if (ta) cba[0]<=~cba[0];
            if (tb) cba[1] <= ~cba[1]; // B 토글
            if (tc) cba[2] <= ~cba[2]; // C 토글
        end
    end
endmodule
