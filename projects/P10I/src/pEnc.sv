`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 12:26:51 AM
// Design Name: 
// Module Name: pEnc
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


module pEnc(
    input logic [3:0] y,
    output logic a,
    output logic b,
    output logic c
    );
    always_comb begin
        if (y[3]) begin
            a=1'b1;
            b=1'b1;
            c=1'b1;
        end
        else if (y[2]) begin
            a=1'b1;
            b=1'b0;
            c=1'b1;
        end
        else if (y[1]) begin
            a=1'b0;
            b=1'b1;
            c=1'b1;
        end
        else if (y[0]) begin
            a=1'b0;
            b=1'b0;
            c=1'b1;
        end
        else begin
            a=1'bx;
            b=1'bx;
            c=1'b0;
        end      
    end
endmodule
