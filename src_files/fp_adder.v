`include "decode.v"
`include "spc_case.v"
`include "align.v"
`include "adder.v"
`include "normalize.v"

// Top module
module fp_adder #(parameter E_WIDTH=8, M_WIDTH=23) (clk, rst, A, B, res);
  
  // Control Signals
  input clk;
  input rst;
  
  // Input-Output Signals
  input [E_WIDTH+M_WIDTH:0] A;
  input [E_WIDTH+M_WIDTH:0] B;
  output [E_WIDTH+M_WIDTH:0] res;

  // Wires to connect modules
  wire sign_A;
  wire sign_B;
  wire [E_WIDTH-1:0] exp_A;
  wire [E_WIDTH-1:0] exp_B;
  wire [M_WIDTH-1:0] mnt_A; 
  wire [M_WIDTH-1:0] mnt_B; 
  wire [E_WIDTH-1:0] exp_diff;
  wire gt_lt;
  reg gt_lt_prev;
  wire [E_WIDTH+M_WIDTH:0] res_spc_case;
  wire s_case;
  wire [M_WIDTH-1:0] align_A; 
  wire [M_WIDTH-1:0] align_B; 
  wire sign_res;
  wire [E_WIDTH-1:0] exp_res;
  wire add_sub;
  wire [E_WIDTH+M_WIDTH+1:0] res_adder;
  
  decode #(E_WIDTH,M_WIDTH) unit1
                (
                .clk(clk),
                .rst(rst),
                .A(A),
                .B(B),
                .sign_A(sign_A),
                .sign_B(sign_B),
                .exp_A(exp_A),
                .exp_B(exp_B),
                .mnt_A(mnt_A),
                .mnt_B(mnt_B),
                .exp_diff(exp_diff),
                .gt_lt(gt_lt)
                );
                    
  spc_case #(E_WIDTH,M_WIDTH) unit21
               (
                .clk(clk),
                .rst(rst),
                .sign_A(sign_A),
                .sign_B(sign_B),
                .exp_A(exp_A),
                .exp_B(exp_B),
                .exp_A_org(A[E_WIDTH+M_WIDTH-1:M_WIDTH]),
                .exp_B_org(B[E_WIDTH+M_WIDTH-1:M_WIDTH]),
                .mnt_A(mnt_A),
                .mnt_B(mnt_B),
                .res(res_spc_case),
                .s_case(s_case)
                );

  align #(E_WIDTH,M_WIDTH) unit22
                (
                .clk(clk), 
                .rst(rst),
                .sign_A(sign_A),
                .sign_B(sign_B),
                .A(mnt_A),
                .B(mnt_B),
                .exp_A(exp_A),
                .exp_B(exp_B),
                .exp_diff(exp_diff),
                .gt_lt(gt_lt_prev),
                .align_A(align_A),
                .align_B(align_B),
                .sign_res(sign_res),
                .exp_res(exp_res),
                .add_sub(add_sub)
                );   

  adder #(E_WIDTH,M_WIDTH) unit3
                (
                .clk(clk), 
                .rst(rst),
                .add_sub(add_sub),
                .A(align_A),
                .B(align_B),
                .sign_res(sign_res),
                .exp_res(exp_res),
                .sum_spc_case(res_spc_case),
                .s_case(s_case),
                .sum(res_adder)
                );   

  normalize #(E_WIDTH,M_WIDTH) unit4
                (
                .clk(clk),
                .rst(rst),
                .sum(res_adder),
                .res(res)
                );

  always @(negedge clk) begin
    gt_lt_prev <= gt_lt; 
    //$display("sign_A: %b sign_B: %b", sign_A, sign_B);
    //$display("exp_A: %d exp_B: %d ", $signed(exp_A), $signed(exp_B));
    //$display("mnt_A: %d mnt_B: %d ", mnt_A, mnt_B);
    //$display("exp_diff: %d gt_lt: %d ", exp_diff, gt_lt);
    //$display("---------------------------------------");
    //$display("Aligned A: %d Aligned B: %d",align_A,align_B);
    //$display("Res: Sign: %d, Exp: %d, Add_sub: %d",sign_res,exp_res,add_sub);
    //$display("---------------------------------------");
    //$display("Spc case: %d, Res: %d",s_case,res_spc_case);
    //$display("---------------------------------------");
    //$display("Adder Result: %b, %d,%d,%d",res_adder,res_adder[E_WIDTH+M_WIDTH+1],res_adder[E_WIDTH+M_WIDTH:M_WIDTH+1],res_adder[M_WIDTH:0]);
  	//$display("---------------------------------------");
    //$display("Result: %b, %d,%d,%d",res,res[E_WIDTH+M_WIDTH],res[E_WIDTH+M_WIDTH-1:M_WIDTH],res[M_WIDTH-1:0]);
  	//$display("---------------------------------------");
 end
endmodule
