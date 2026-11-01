`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 06:30:05 PM
// Design Name: 
// Module Name: decod24
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


module decod24(
    input logic [1:0]a,
    output logic [3:0]b
    );
    always_comb begin
        case(a)
            2'b00: b=4'b0001; 
            2'b01: b=4'b0010;
            2'b10: b=4'b0100;
            2'b11: b=4'b1000;
            default: b = 4'b0000;
        endcase
    end
endmodule

