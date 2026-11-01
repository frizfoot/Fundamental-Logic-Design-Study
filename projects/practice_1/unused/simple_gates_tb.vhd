----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2026 11:51:41 PM
-- Design Name: 
-- Module Name: simple_gates_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

`timescale 1ns / 1ps

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
        tb_a = 0; tb_b = 0; #10; 
        tb_a = 0; tb_b = 1; #10; 
        tb_a = 1; tb_b = 0; #10; 
        tb_a = 1; tb_b = 1; #10; 
        
        $finish; 
    end

endmodule