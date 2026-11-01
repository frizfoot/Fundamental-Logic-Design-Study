`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 10:38:03 PM
// Design Name: 
// Module Name: bcdconv
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


module bcdconv(
    input logic [3:0]a,
    output logic [6:0]f
    );
    logic [6:0]mem [0:16];

    initial begin
        mem[0]  = 7'b1111110;   mem[1]  = 7'b0110000;
        mem[2]  = 7'b1101101;   mem[3]  = 7'b1111001;
        mem[4]  = 7'b0110011;   mem[5]  = 7'b1011011;
        mem[6]  = 7'b1011111;   mem[7]  = 7'b1110000;
        mem[8]  = 7'b1111111;   mem[9]  = 7'b1111011;
        mem[10] = 7'b0000000;   mem[11] = 7'b0000000;
        mem[12] = 7'b0000000;   mem[13] = 7'b0000000;
        mem[14] = 7'b0000000;   mem[15] = 7'b0000000;
    end

    assign f = mem[a]; 
    
endmodule
