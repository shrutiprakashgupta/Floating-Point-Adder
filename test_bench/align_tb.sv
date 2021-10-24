// align_tb.v
// E_WIDTH can vary between 5 and 8
`define E_WIDTH 8
`define M_WIDTH 31-`E_WIDTH

class stimulus;
    rand bit rst;
    rand bit sign_A;
    rand bit sign_B;
    rand bit [`M_WIDTH-1:0] A;
    rand bit [`M_WIDTH-1:0] B;
    rand bit [`E_WIDTH-1:0] exp_A;
    bit [`E_WIDTH-1:0] exp_B;
    rand bit [`E_WIDTH-1:0] exp_diff;
    rand bit gt_lt;
    bit [`M_WIDTH-1:0] align_A;
    bit [`M_WIDTH-1:0] small_no;
    bit [`M_WIDTH-1:0] align_B;
    bit sign_res;
    bit [`E_WIDTH-1:0] exp_res;
    bit add_sub;
    
    constraint reset {rst dist {0:/10,1:/90};}
    constraint reduce_test_size {exp_diff inside {[0:32]};}
    
  	function void set_exp();
    	if (gt_lt==1) begin
      		exp_B = exp_A - exp_diff;
    	end
      	else begin
          	exp_B = exp_A + exp_diff;
        end
    endfunction
endclass

module align_tb;

    reg clk;
    reg rst;
    reg sign_A;
    reg sign_B;
    reg [`M_WIDTH-1:0] A;
    reg [`M_WIDTH-1:0] B;
    reg signed [`E_WIDTH-1:0] exp_A;
    reg signed [`E_WIDTH-1:0] exp_B;
    reg [`E_WIDTH-1:0] exp_diff;
    reg gt_lt;
    wire [`M_WIDTH-1:0] align_A;
    wire [`M_WIDTH-1:0] align_B;
    wire sign_res;
    wire signed [`E_WIDTH-1:0] exp_res;
    wire add_sub;

    parameter [`E_WIDTH-1:0] BIAS = 1 << (`E_WIDTH-1);
    parameter [`E_WIDTH-1:0] nBIAS = -BIAS + 1;
    
    align #(`E_WIDTH, `M_WIDTH) uut ( 
                .clk(clk), 
                .rst(rst),
                .sign_A(sign_A),
                .sign_B(sign_B),
                .A(A),
                .B(B),
                .exp_A(exp_A),
                .exp_B(exp_B),
                .exp_diff(exp_diff),
                .gt_lt(gt_lt),
                .align_A(align_A),
                .align_B(align_B),
                .sign_res(sign_res),
                .exp_res(exp_res),
                .add_sub(add_sub));

    //Check the immediate value of the generated stimulus
    task tick;
        #5; clk = ~clk;
        #5; clk = ~clk;
    endtask
 
    task reset;
        rst <= 0; 
        tick;
        rst <= 1;
    endtask
    
  	function void show(stimulus io);
        io.align_A = (io.gt_lt)?io.A:io.B;
        io.small_no = (io.gt_lt)?io.B:io.A;
        io.align_B = io.small_no>>io.exp_diff;
        $display("[%0t] rst = %b, A: %d, B: %d", $time(), rst, io.A, io.B);
      	$display("[>>>] rst = %b, exp_A: %d, exp_B: %d, gt_lt: %d", rst, $signed(io.exp_A), $signed(io.exp_B), io.gt_lt);
        $display("[>>>] rst = %b, align_A: %d, align_B: %d", rst, io.align_A, io.align_B);
      $display("[>>>] align_A: %d, align_B: %d\n", align_A, align_B);        
    endfunction

    initial begin 
        clk <= 0;
    end

    initial begin
        stimulus io;
      	io = new();
        reset;
      	show(io);
    
        repeat(10) begin
            io.randomize();
          	io.set_exp();

            rst <= io.rst;
            sign_A <= io.sign_A;
            sign_B <= io.sign_B;
            A <= io.A;
            B <= io.B;
          	exp_A <= io.exp_A;
            exp_B <= io.exp_B;
            exp_diff <= io.exp_diff;
            gt_lt <= io.gt_lt;
            tick;
          	show(io);
        end
    end
endmodule