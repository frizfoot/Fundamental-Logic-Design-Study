`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2026 09:59:49 PM
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
    logic rb,clk,rst_n,rst;
    logic won,lost,display1,display2;
    
    main dut(.*);
    int errors=0;
    
    initial clk=0;
    always#5 clk=~clk;
    
    task automatic check(input string name, input logic ok);
        if (ok)
            $display("[PASS] %-32s t=%0t", name, $time);
        else begin
            errors++;
            $error("[FAIL] %s t=%0t | state=%s | c1=%0d c2=%0d sum=%0d point=%0d | rb=%b rst=%b | won=%b lost=%b",
                   name, $time, dut.current.name(),
                   dut.counter1, dut.counter2, dut.sum, dut.point,
                   rb, rst,
                   won, lost);
        end
    endtask    
    
    initial begin
    
        rst_n=0;
        rb=0;
        rst=0;
        repeat (2)@(negedge clk); //2 times for initial settle
        
        //reset everything
        rst_n=1;
        #1 check("Reset", dut.current.name() =="standby1");
        
        rb=1;
        repeat (2)@(negedge clk); //2 times for settle
        
        #1 check("Roll1", dut.current.name()=="roll1");
        
        //make rb=0 for roll1 to get sum
        rb=0;
        

        $finish;
    end
        
endmodule
