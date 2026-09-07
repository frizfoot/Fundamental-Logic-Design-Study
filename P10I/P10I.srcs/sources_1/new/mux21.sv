`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 01:21:56 AM
// Design Name: 
// Module Name: mux21
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


module mux21(
    input logic I0,
    input logic I1,
    input logic e,
    output logic f
    );
    always_comb begin
        case(e)
            1'b0: f=I0;
            1'b1: f=I1;
            default: f = 1'bx;
        endcase
    end
endmodule
