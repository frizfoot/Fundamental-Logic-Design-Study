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
    output logic won, lost
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
        
        always_comb begin
            next=state;
            case(state)
                if

endmodule
