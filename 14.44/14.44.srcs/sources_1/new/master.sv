`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2026 01:00:51 AM
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


module master(
    input logic r,a,s,rst_n,clk,
    output logic z
    );
    typedef enum logic [2:0] {s0,s1,s2,s3,ans} state_t;
    state_t current, next;
    always_ff@(posedge clk or negedge rst_n) begin
        if (!rst_n) current<=s0;
        else current<=next;
    end
    
    always_comb begin
        next=current;
        case(current)
            s0: begin
                if(a) next=s0;
                else if (r) next=s1;
            end
            s1: begin
                if(a) next=s0;
                else if (r&&!s) next=ans;
                else if (r) next=s2;
            end
            s2: begin
                if(a) next=s0;
                else if (r) next=s3;
            end
            s3: begin
                if(a) next=s0;
                else if (r) next=ans;
            end
            ans: begin
                if(!a) next=ans;
                else next=s0;
            end
        endcase
    end
    always_comb begin
        case(current)
            s0,s1,s2,s3: z=1'b0;
            ans: z=1'b1;
            default: z=1'b0;
        endcase
    end
endmodule
