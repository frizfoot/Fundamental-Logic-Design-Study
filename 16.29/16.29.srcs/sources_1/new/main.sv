`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2026 11:30:59 PM
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
    input logic fb1,fb2,call1,call2,fs1,fs2,clk,rst_n,
    output logic up,down
    );
    
    typedef enum logic[1:0]{
        first=2'b00, 
        rise=2'b01,
        second=2'b11,
        fall=2'b10
        }state_t;
    state_t cstate,next;
    
    logic n1,n2,r1,r2,od,cd;
    
    always_ff@(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            cstate<=first;
        end else begin
            cstate<=next;
        end
    end
    
    always_comb begin
        assign n1=(fb1+call1)&~r1;
        assign n2=(fb2+call2)&~r2;
        next=cstate;
        up=1'b0;
        down=1'b0;
        unique case(cstate)
            first: begin
                if (n1) begin
                    next=first;
                    od=1'b1;
                    r1=1'b1;
                end else if (~n1&n2|~n1&n2&~cd) begin
                    next=first;
                end else if (~n1&n2&cd) begin
                    next=rise;
                    up=1'b1;
                end
            end
            
            rise: begin 
                if (~fs2) begin
                    next=rise;
                    up=1'b1;
                end else if (fs2) begin
                    next=second;
                    od=1'b1;
                end
            end
            
            second: begin
                if (n2) begin
                    next=second;
                    od=1'b1;
                    r2=1'b1;
                end else if (n1&~n2&cd) begin
                    next=second;
                end else if (n1&~n2&cd) begin
                    next=fall;
                    down=1'b1;
                end
            end
            
            fall: begin
                if (~fs1) begin
                    next=fall;
                    down=1'b1;
                end else if (fs1) begin
                    next=first;
                    od=1'b1;
                end
            end
            
            default: begin
                next = first;
            end
        endcase
    end
endmodule
