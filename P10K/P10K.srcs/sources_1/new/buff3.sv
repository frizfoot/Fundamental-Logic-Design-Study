`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 06:16:51 PM
// Design Name: 
// Module Name: buff3
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


module buff3(
    input logic [5:0]a,
    input logic e,
    output logic [5:0]b
    );
    always_comb begin
        case(e)
            1'b0: b=6'bz;
            1'b1: b=a;
            default: c = 6'bx;
        endcase
    end
endmodule
