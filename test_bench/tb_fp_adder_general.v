`define E_WIDTH 8
`define M_WIDTH 31-`E_WIDTH

module fp_adder_tb;
  reg clk;
  reg rst;
  reg [`E_WIDTH+`M_WIDTH:0]A;
  reg [`E_WIDTH+`M_WIDTH:0]B;
  wire [`E_WIDTH+`M_WIDTH:0]res;
  
  fp_adder uut (.clk(clk), .rst(rst), .A(A), .B(B), .res(res));
  
  always #5 clk <= ~clk;
  
  task show;
    //$display("%b : %d",res,res);
  endtask
  
  initial begin
  	clk <= 1'b0; rst <= 1'b0; #10; show;
    rst <= 1'b1; #10; show;
    A <= 1; B <= 102; #10; show;
    A <= 2; B <= 73; #10; show;
    A <= 3; B <= 92; #10; show;
    A <= 4; B <= 40; #10; show;
    B <= 5; A <= 84; #10; show;
    B <= 6; A <= 92; #10; show;  
    B <= 7; A <= 72; #10; show;  
    B <= 8; A <= 93; #10; show;  
    #10; show;
    #10; show;
    #10; show;
    $finish();
  end
endmodule
  