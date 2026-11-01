`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 01:40:45 AM
// Design Name: 
// Module Name: main
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


module main(
    input logic x1,x2,clk,rst_n,
    output logic z1,z2

    );
    logic [1:0]q=2'b00;
    logic d1,d2;
    always_comb begin
        case({q,x1,x2})
            4'b0000: {d1,d2,z1,z2} = 4'b0010;
            4'b0001: {d1,d2,z1,z2} = 4'b0010;
            4'b0010: {d1,d2,z1,z2} = 4'b0110;
            4'b0011: {d1,d2,z1,z2} = 4'b0110;
            4'b0100: {d1,d2,z1,z2} = 4'b1100;
            4'b0101: {d1,d2,z1,z2} = 4'b1110;
            4'b0110: {d1,d2,z1,z2} = 4'b1001;
            4'b0111: {d1,d2,z1,z2} = 4'b1011;
            4'b1000: {d1,d2,z1,z2} = 4'b1100;
            4'b1001: {d1,d2,z1,z2} = 4'b0000;
            4'b1010: {d1,d2,z1,z2} = 4'b1101;
            4'b1011: {d1,d2,z1,z2} = 4'b0001;
            4'b1100: {d1,d2,z1,z2} = 4'b1000;
            4'b1101: {d1,d2,z1,z2} = 4'b0100;
            4'b1110: {d1,d2,z1,z2} = 4'b1000;
            4'b1111: {d1,d2,z1,z2} = 4'b0100;
            default: {d1,d2,z1,z2} = 4'b0000;
        endcase
    end
    always_ff@(posedge clk) begin
        if (!rst_n) q <= 2'b00;
        else  q <= {d1, d2};
    end
endmodule
