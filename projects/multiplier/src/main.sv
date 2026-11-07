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
    input logic [3:0]ier,cand,
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
    //flip flop that sends current to next state
    always_ff@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            current<=standby;
        end else begin
            current<=next;
        end
    //combinational logic about states(they tell you conditions of state jumps)
    always_comb begin
        next=current;
        load=1'b0;
        sh=1'b0;
        ad=1'b0;
        done=1'b0;
        
        case (current)
            standby: begin
                //#1
                if(!st) begin
                    load=1'b0;
                    next=standby;
                end
                //#2
                else if(st) begin
                    next=min;
                    load=1'b1;
                end
            end
            min: begin
                //#3
                if(M==0&&k==0) begin
                    next=min;
                    ad=1'b0;
                    sh=1'b1;
                end
                //#4
                else if(M==1) begin
                    next=add;
                    ad=1'b1;
                end
                //#6
                else if(M==0&&k==1) begin
                    next=fin;
                    sh=1'b1;
                end
            end
            
            add: begin 
            //#5
                if(!k) begin
                    next=min;
                    sh=1'b1;
                end
                //#7
                else if (k) begin
                    next=fin;
                    sh=1'b1;
                end
            end
            fin: begin
                //#8
                if(!st) begin
                    next=standby;
                    done=1'b1;
                end
                //#9
                else if (st) begin
                    next=min;
                    done=1'b1;
                    load=1'b1;
                end
            end
        endcase
    end
    
    logic [8:0]acc;
    //
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n)     acc <= 9'b0;
        else if(load) acc<={5'b0,ier};
        
        else if(ad) acc[8:4]<=acc[8:4]+cand[3:0];
        else if (sh) acc[8:0]<={1'b0,acc[8:1]};
    
    logic [1:0]cnt;
    //coutner that counts to 3
    always_ff@(posedge clk or negedge rst_n)
        if(!rst_n) cnt<=2'd0;
        else if (load)  cnt <= 2'd0;
        else if (sh) cnt<=cnt+2'd1;
    assign k=(cnt==2'd3);
    assign M= acc[0];
    assign prod=acc[7:0];
endmodule
