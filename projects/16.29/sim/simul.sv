`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 01:13:54 AM
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
    logic fb1,fb2,call1,call2,fs1,fs2,clk,rst_n;
    logic up,down,od,cd,r1,r2;
    
    main dut(
        .fb1(fb1),
        .fb2(fb2),
        .call1(call1),
        .call2(call2),
        .fs1(fs1),
        .fs2(fs2),
        .clk(clk),
        .cd(cd),
        .rst_n(rst_n));
    initial clk=0; // 클럭 생성
        always #5 clk=~clk;
    initial cd=1;//door is closed
    always begin
        wait(od==1);//wait until door open
        cd=0;//when door opens, close door
        repeat(3)@(posedge clk); //after 3 clk
        cd=1;// close door
        wait(od==0);//when cd od will go to 0
    end
    
    initial begin
        //reset to first floor
        rst_n=1; fb1=0; fb2=0; call1=0; call2=0; fs1=1; fs2=0;//reset is 1
        #20;//output check all has to be 0 since reset
        assert(up==0&&down==0&&od==0&&cd==0&&r1==0&&r2==0) $display("no0 PASS", $time); else $error("no0 fail", $time); 
        
        //press outside from ev at 1st floor, fs1 because ev is at 1st floor, and call 1=1 because I called from outside 1st floor
        #20;//input check
        rst_n=0; fb1=0; fb2=0; call1=1; call2=0; fs1=1; fs2=0; // ev expected to door open
        #20;// output check
        assert(up==0&&down==0&&od==1&&cd==0&&r1==1&&r2==0) $display("no0 PASS", $time); else $error("no0 fail", $time);
        #20;
        //door is automatically closed since 3 clock has passed.
        
        // Now I want to move on to second floor since I am in the EV
        #20;//input check
        rst_n=0; fb1=0; fb2=1; call1=0; call2=0; fs1=0; fs2=0; // ev expected to door open, n1'n2,dc=1(initial)
        #20;// output check
        assert(up==1&&down==0&&od==0&&cd==0&&r1==0&&r2==0) $display("no0 PASS", $time); else $error("no0 fail", $time);
  
                
        $finish;
    end
    
    
endmodule
