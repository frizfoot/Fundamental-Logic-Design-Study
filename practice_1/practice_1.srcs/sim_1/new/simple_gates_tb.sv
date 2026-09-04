`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2026 12:06:24 AM
// Design Name: 
// Module Name: simple_gates_tb
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


module simple_gates_tb();

    logic tb_a;
    logic tb_b;
    logic tb_and_out;
    logic tb_or_out;
    
    simple_gates uut (
        .a(tb_a),
        .b(tb_b),
        .and_out(tb_and_out),
        .or_out(tb_or_out)
    );
    
    initial begin
        tb_a = 0; tb_b = 0; #10; // 0ns: a=0, b=0 넣고 10ns 대기
        tb_a = 0; tb_b = 1; #10; // 10ns: a=0, b=1 넣고 10ns 대기
        tb_a = 1; tb_b = 0; #10; // 20ns: a=1, b=0 넣고 10ns 대기
        tb_a = 1; tb_b = 1; #10; // 30ns: a=1, b=1 넣고 10ns 대기
        
        $finish;
    end
endmodule
