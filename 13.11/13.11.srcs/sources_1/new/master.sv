`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2026 12:44:31 AM
// Design Name: 
// Module Name: master
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


module master #(
    parameter dc0=1'b0,
    parameter dc1=1'b1
    )(
    input logic clk,rst_n, x,
    output logic z
    );
    localparam [2:0]
        s0=3'b000,
        s1=3'b001,
        s2=3'b010,
        s3=3'b011,
        s4=3'b100;
    reg[2:0] state;
    
    always_ff@(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state<=s0;
        else begin
                case(state)
                    s0: state<=x?s1:s0;
                    s1: state<=s2;
                    s2: state<=s3;
                    s3: state<=s4;
                    s4: state<=x?s4:s0;
                    default: state<=s0;
                endcase
        end
    end
    assign z=(state==s0)?(x?1:0)
           :(state==s1 || state==s2 || state==s3) ? 1'b1
           :1'b0;
endmodule
 