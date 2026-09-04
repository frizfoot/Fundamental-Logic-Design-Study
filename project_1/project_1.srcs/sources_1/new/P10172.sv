`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2026 12:13:10 AM
// Design Name: 
// Module Name: P10172
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


module P10172( 
    input logic A,
    input logic B,
    input logic C,
    input logic D,
    output logic F
    );
    always_comb begin
        case({C,D})
            2'b00: F=~A;
            2'b01: F=B;
            2'b10: F=~B;
            2'b11: F=1'b0;
            default: F = 1'bx;
        endcase
    end
endmodule
