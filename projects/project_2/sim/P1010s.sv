`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2026 12:57:23 AM
// Design Name: 
// Module Name: P1010s
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
`timescale 1ns/1ps

module P1010s;
    logic P,Q,N;
    logic R;
// DUT (Design Under Test) 인스턴스화
    P1010 uut (
        .P(P),
        .Q(Q),
        .N(N),
        .R(R)
    );
    initial begin
        P=1;
        Q=1;
        N=0;
    
        #4ns
        Q=0;
        #30s
        $finish;
        
    end
endmodule
