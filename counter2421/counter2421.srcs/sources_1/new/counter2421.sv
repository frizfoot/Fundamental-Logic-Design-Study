`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2026 01:13:23 AM
// Design Name: 
// Module Name: counter2421
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


module counter2421(
    input logic ClrN,
    output logic [3:0] q,
    input logic clk
    
    );
    logic [3:0]q; 
    logic [3:0] p;
    logic Ld;
    assign Ld = (q == 4'b0100);
    always_ff @ (posedge clk) begin
        if (~ClrN) begin
            q<=4'b0000;
        end else begin
            if (Ld) begin 
                q<=4'b1011;
            end else begin
                q<=q+1;
            end
       end
    end    
endmodule
