`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/29/2026 01:56:11 AM
// Design Name: 
// Module Name: simul
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


module simul; 
    logic [7:0]y;    
    logic a,b,c,d;
    
    master umas(
        .y(y),.a(a),.b(b),.c(c),.d(d)
    );
    initial begin
        $monitor("t=%0t y=%b -> abc=%b%b%b d=%b", $time, y, a, b, c, d);
    end
    initial begin
        y=8'b0000_0001; #10;
        y=8'b0000_0010 ;#10;
        y=8'b0000_0100; #10;
        y=8'b0000_1000; #10;
        y=8'b0001_0000; #10;
        y=8'b0010_0000; #10;
        y=8'b0100_0000; #10;
        y=8'b1000_0000; #10;
        y=8'b1100_0010; #10;
        y=8'b1111_1111; #10;
        y=8'b0000_0000; #10;
        $finish;
    end
endmodule
