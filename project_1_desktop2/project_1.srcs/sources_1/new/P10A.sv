`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2026 12:56:13 AM
// Design Name: 
// Module Name: P10A
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

module P10A(
    input logic I0,
    input logic I1,
    input logic E,
    output logic F
    );
    always_comb begin
        case({E})
            1'b0: F= I0;
            1'b1: F= I1;
            default: F = 1'bx;
        endcase
    end
endmodule
    