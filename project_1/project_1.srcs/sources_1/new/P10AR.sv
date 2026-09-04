`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2026 12:59:31 AM
// Design Name: 
// Module Name: P10AR
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


module P10AR(
    input logic A,
    input logic B,
    input logic I0,
    input logic I1,
    input logic I2,
    input logic I3,
    output logic F
    );
    logic q,w;
    P10A mux1(
        .I0(I0),
        .I1(I1),
        .E(B),
        .F(q)
    );
    P10A mux2(
        .I0(I2),
        .I1(I3),
        .E(B),
        .F(w) 
        );
    P10A mux3(
        .I0(q),
        .I1(w),
        .E(A),
        .F(F)
    ); 
endmodule
