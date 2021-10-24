// spc_case_tb.v
// E_WIDTH can vary between 5 and 8
`define E_WIDTH 8
`define M_WIDTH 31-`E_WIDTH

class stimulus;
    rand bit rst;
    rand bit sign_A;
    rand bit sign_B;
    rand bit [`E_WIDTH-1:0] exp_A;
    rand bit [`E_WIDTH-1:0] exp_B;
    rand bit [`M_WIDTH-1:0] mnt_A;
    rand bit [`M_WIDTH-1:0] mnt_B;
    
    constraint reset {rst dist {0:/10,1:/90};}
    constraint spc_case_A {exp_A inside {128,0,-127};}
    constraint spc_case_B {exp_B inside {128,0,-127};}
    constraint create_nans_A {mnt_A inside {0,4};}
  	constraint create_nans_B {mnt_B inside {0,4};}
endclass

module spc_case_tb;

    reg clk;
    reg rst;
    reg sign_A;
    reg sign_B;
    reg signed [`E_WIDTH-1:0] exp_A;
    reg signed [`E_WIDTH-1:0] exp_B;
    reg [`M_WIDTH-1:0] mnt_A;
    reg [`M_WIDTH-1:0] mnt_B;
    wire [`E_WIDTH+`M_WIDTH:0] res;
    wire s_case;

    parameter [`E_WIDTH-1:0] BIAS = 1 << (`E_WIDTH-1);
    parameter [`E_WIDTH-1:0] nBIAS = -BIAS + 1;
    
    spc_case #(`E_WIDTH, `M_WIDTH) uut (.clk(clk),
                .rst(rst),
                .sign_A(sign_A),
                .sign_B(sign_B),
                .exp_A(exp_A),
                .exp_B(exp_B),
                .exp_A_org(exp_A - nBIAS),
                .exp_B_org(exp_B - nBIAS),
                .mnt_A(mnt_A),
                .mnt_B(mnt_B),
                .res(res),
                .s_case(s_case));

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
        string Spc_case;
        if (((io.exp_A==BIAS)&(io.mnt_A!=0))| ((io.exp_B==BIAS)&(io.mnt_B!=0))) 
            Spc_case = "NAN1";
      else if ((io.exp_A==BIAS)&(io.exp_B==BIAS)&(io.sign_A != io.sign_B))
            Spc_case = "NAN2";
        else if (io.exp_A==BIAS)
            Spc_case = "InfA";
        else if (io.exp_B==BIAS)
            Spc_case = "InfB";
        else if ($signed(io.exp_A)==nBIAS)
            Spc_case = "Zero";
      	else if ($signed(io.exp_B)==nBIAS)
            Spc_case = "Zero";
        else
            Spc_case = "None";
        $display("[%0t] rst = %b, Spc_case: %s\n", $time(), rst, Spc_case);
      $display("[>>>] A: sign: %d, Exp: %d, Mnt: %d\n", sign_A, exp_A, mnt_A);
      $display("[>>>] B: sign: %d, Exp: %d, Mnt: %d\n", sign_B, exp_B, mnt_B);
        $display("[>>>] Res: %b, Spc_case: %d", res, s_case);        
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

            rst <= io.rst;
            sign_A <= io.sign_A;
            sign_B <= io.sign_B;
          	exp_A <= io.exp_A;
            exp_B <= io.exp_B;
            mnt_A <= io.mnt_A;
            mnt_B <= io.mnt_B;
            tick;
          	show(io);
        end
    end
endmodule