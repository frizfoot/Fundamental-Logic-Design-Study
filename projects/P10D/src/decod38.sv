`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 02:22:31 AM
// Design Name: 
// Module Name: decod38
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


module decod38(
    input logic a,
    input logic b,
    input logic c,
    output logic [7:0] y
    );
    always_comb begin
        case({a,b,c})
            3'b000: y = 8'b0000_0001;
            3'b001: y = 8'b0000_0010;
            3'b010: y = 8'b0000_0100;
            3'b011: y = 8'b0000_1000;
            3'b100: y = 8'b0001_0000;
            3'b101: y = 8'b0010_0000;
            3'b110: y = 8'b0100_0000;
            3'b111: y = 8'b1000_0000;
        endcase
    end
endmodule
