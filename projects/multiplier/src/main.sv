`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2026 12:41:57 AM
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
    input logic clk,rst_n,st,
    input logic [3:0]ier,[3:0]cand,
    output logic [7:0]prod,
    output logic done
    );
    
    //states
    typedef enum logic[1:0]{
        standby=2'b00,
        min=2'b10,
        add=2'b11,
        fin=2'b01
        }state_t;
        
        state_t current,next;
    //inner logic wires
    logic M,k,load,sh,ad;
    
    always_ff@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            current<=standby;
        end else begin
            current<=next;
        end
    
    always_comb begin
        next=current;
        load=1'b0;
        sh=1'b0;
        ad=1'b0;
        done=1'b0;
        
        case (current)
            standby: begin
                if(!st) begin
                    load=1'b0;
                    next=standby;
                end
                else if(st) begin
                    next=min;
                    load=1'b1;
                end
            end
            min: begin
                if(M==0&&k==0) begin
                    next=min;
                    ad=1'b0;
                    sh=1'b1;
                end
                else if(M==1) begin
                    next=add;
                    ad=1'b1;
                end
                else if(M==0&&k==1) begin
                    next=fin;
                    sh=1'b1;
                end
            end
            add: begin
                if(!k) begin
                    next=min;
                    sh=1'b1;
                end
                else if (k) begin
                    next=fin;
                    sh=1'b1;
                end
            end
            fin: begin
                if(!st) begin
                    next=standby;
                    done=1'b1;
                end
                else if (st) begin
                    next=min;
                    done=1'b1;
                    load=1'b1;
                end
            end
        endcase
    end
    
    logic adder[3:0];
 //ACC   
    always_comb begin
        prod=7'b0;
        if(load) begin
            adder=cand;
        end
        M=prod[0];
        if(ad) begin
            prod[7:4]=prod[7:4]+adder[3:0];
        end
        if(sh) begin
            prod=prod[0]+prod[7:1];
        end
    end
endmodule
