`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2026 10:06:34 PM
// Design Name: 
// Module Name: ringcounter
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


module ring_counter_top(
    input logic clk,
    input logic ce,
    input logic preset,
    output logic [7:0] t
    
    );
    genvar i;
    flip ff0(
        .clk(clk),
        .ce(ce),
        .preset_n(preset),
        .j(t[7]),
        .init_val(1'b1),          // ← 수정: FF0은 1로 초기화
        .t(t[0])
    );
    generate
        for (i = 1; i < 8; i++) begin : ff_gen
            flip ff_inst (
                .clk(clk),
                .ce(ce),
                .j(t[i-1]),
                .preset_n(preset),  // ← 수정: preset_n이 아니라 preset
                .init_val(1'b0),
                .t(t[i])
            );
        end
    endgenerate
endmodule
