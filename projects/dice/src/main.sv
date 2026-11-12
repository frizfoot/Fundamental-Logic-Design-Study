`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2026 12:59:03 AM
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
    input logic rb,clk,
    input logic rst,rst_n,//rst is reset input button while rst_n is total reset no matter what
    output logic won, lost,
    output logic [3:0]display1,
    output logic [3:0]display2
    );
    //6 states
    typedef enum logic [2:0]{
        standby1=3'b000,
        roll1=3'b001,
        win=3'b010,
        standby2=3'b011,
        lose=3'b101,
        roll2=3'b100
        } state_t;
        
        state_t current,next;
        
        always_ff@(posedge clk or negedge rst_n) begin
            if (!rst_n)  
                current<=standby1;
            else current<=next;
        end
                
        logic [2:0]counter1;
        logic [2:0]counter2;
        logic [3:0]sum;
        logic roll;
        logic lp;
        logic [3:0]point;
        
        //fsm sm chart to SV
        always_comb begin
            next=current;
            roll=1'b0;//set default it is a signal that enables counter to roll
            won=1'b0;
            lost=1'b0;
            lp=1'b0;
            
            case(current)
                standby1: begin //s0
                    if (!rb) next=standby1;
                    else if (rb) next=roll1;
                end
                
                roll1: begin //s1
                    if(rb) begin
                        next=roll1;
                        roll=1'b1; //use roll to roll counter
                    end
                    
                    else if (!rb) begin
                        roll=1'b0;
                        if (sum==7||sum==11) begin // for or, you need to use ||
                            next=win;
                            
                        end
                        else if (sum==2||sum==3||sum==12) begin 
                            next=lose;
                            
                        end
                        else begin
                            lp=1'b1; //point is saved by sum
                            next=standby2;
                        end
                    end
                end
                
                standby2: begin //s3
                    if (!rb) next=standby2;
                    else if (rb) next=roll2;
                end
                
                roll2: begin //s5
                    if(rb) begin
                        next=roll2;
                        roll=1'b1;//use roll to roll counter
                    end
                    
                    else if (!rb) begin
                        roll=1'b0;
                        if (sum==point) begin//check if the sum is equal topoint that is saved
                            next=win;
                            
                        end
                        else if (sum==7) begin
                            next=lose;
                            
                        end
                        else
                            next=standby2;
                    end                        
                end
               
                win: begin //s2
                    
                    if(!rst) begin
                        next=win;
                        won=1'b1;
                    end
                    else begin
                        next=standby1;
                        won=1'b0;
                    end
                end
                lose: begin //s2
                    
                    if(!rst) begin 
                        next=lose;
                        lost=1'b1;
                    end
                    else begin 
                        next=standby1;
                        lost=1'b0;
                    end
                end
                default: begin        // 110, 111 states that are not used
                    next=standby1;    // reset
                end
            endcase
        end
        

        //Dice counter module
        always_ff@(posedge clk or negedge rst_n) begin
            if(!rst_n)begin
                counter1<=3'd1;
                counter2<=3'd1;
            end
            else if(roll==1) begin
                if(counter1==3'd6) begin
                    counter1<=3'd1;
                    if(counter2==3'd6) begin
                        counter2<=3'd1;
                    end
                    else counter2<=counter2+3'd1;
                end
                else counter1<=counter1+3'd1;
                  
            end
        end
        assign display1=counter1;
        assign display2=counter2;
        //sum does not us ff because it has to be assigned immediately when counter numbers are in
        assign sum=counter1+counter2;    
            
        //point ff module
        always_ff@(posedge clk or negedge rst_n) begin
            if(!rst_n)
                point<=4'b0;
            else if (lp)//load point
                point<=sum;
        end
        
endmodule


