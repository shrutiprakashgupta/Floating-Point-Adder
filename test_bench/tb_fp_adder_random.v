`define E_WIDTH 8
`define M_WIDTH 31-`E_WIDTH

class stimulus;
    rand bit rst;
    rand bit A_sign;
  	rand bit B_sign;
  	rand bit [`E_WIDTH-1:0] A_exp;
  	rand bit [5:0] exp_diff_AB;
  	//bit [`E_WIDTH-1:0] B_exp;
  	rand bit [`M_WIDTH-1:0] A_mnt;
  	rand bit [`M_WIDTH-1:0] B_mnt;
    bit [`E_WIDTH+`M_WIDTH:0] res;

    integer exp_A;
    integer exp_B;
    integer exp_diff;
    integer val_A;
    integer val_B;
    integer shift_by;
    integer val;
    integer exp;

  constraint reset {rst dist {0:/0,1:/100};}
  

    function void expected();
      exp_A = $signed(A_exp-127);
      exp_B = $signed(A_exp+$signed(exp_diff_AB)-127);
      exp_diff = $signed(exp_diff_AB);
        if (exp_diff < 0) begin
            shift_by = -1*exp_diff;
            val_A = A_mnt>>shift_by;
            val_B = B_mnt;
            exp = exp_B + 127;
          if(A_sign == B_sign) 
                val = val_A + val_B;
                if((val>>`M_WIDTH)==1) begin
                    val = val - 1;
                    exp = exp + 1;
                end
            else
                val = val_B - val_A; 
        end
        else begin
            shift_by = exp_diff;
            val_A = A_mnt;
            val_B = B_mnt>>shift_by;
            exp = exp_A + 127;
          if(A_sign == B_sign) 
                val = val_A + val_B;
                if((val>>`M_WIDTH)==1) begin
                    val = val - 1;
                    exp = exp + 1;
                end
            else
                val = val_A - val_B; 
        end
        //$display("val: %d, exp: %d",val,exp);
    endfunction
endclass

module fp_adder_tb;

    reg clk;
    reg rst;
    reg [`E_WIDTH+`M_WIDTH:0] A;
    reg [`E_WIDTH+`M_WIDTH:0] B;
    wire [`E_WIDTH+`M_WIDTH:0] res;
    
    fp_adder #(`E_WIDTH, `M_WIDTH) uut (.clk(clk), .rst(rst), .A(A), .B(B), .res(res));

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
    
    task show;
      $display("[%0t] rst = %d, A = %b, B = %b, Res = %b", $time(), rst, A, B, res);
      $display("[>>>] rst = %d, A = %d,%d,%d, B = %d,%d,%d, Res = %d,%d,%d", rst, A[`E_WIDTH+`M_WIDTH], A[`E_WIDTH+`M_WIDTH-1:`M_WIDTH], A[`M_WIDTH-1:0], B[`E_WIDTH+`M_WIDTH], B[`E_WIDTH+`M_WIDTH-1:`M_WIDTH], B[`M_WIDTH-1:0],  res[`E_WIDTH+`M_WIDTH], res[`E_WIDTH+`M_WIDTH-1:`M_WIDTH], res[`M_WIDTH-1:0]);
    endtask
    
    initial begin 
        clk <= 0;
    end

    initial begin
        stimulus io = new();
        reset;
        show;
    	
      	repeat(20) begin
			io.randomize();	
            rst <= io.rst;
          	A <= {io.A_sign,io.A_exp,io.A_mnt};
          B <= {io.B_sign,io.A_exp+$signed(io.exp_diff_AB),io.B_mnt};
            tick;
            show;
            io.expected();
        end
    end
endmodule