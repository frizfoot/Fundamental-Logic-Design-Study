`timescale 1ns / 1ps

module ad42_tbvcd();

    logic tb_a;
    logic tb_b;
    logic tb_c;
    logic tb_d;
    logic tb_y;
    
    ad42 uut(
    .A(tb_a),
    .B(tb_b),
    .C(tb_c),
    .D(tb_d),
    .Y(tb_y)
    );
    
    initial begin
    $dumpfile("C:/Users/noelk/practice_1/practice_1.sim/sim_1/behav/xsim/ad42_waveform.vcd");
    $dumpvars(0,ad42_tbvcd);
    
        tb_a=0; tb_b=0; tb_c=0; tb_d=0; #10;
        tb_a=0; tb_b=1; tb_c=0; tb_d=1;  #10;
        tb_a=1; tb_b=0; tb_c=1; tb_d=0;  #10;
        tb_a=1; tb_b=1; tb_c=1; tb_d=1;  #10;
    
        $finish;
    end
    
endmodule