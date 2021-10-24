`define E_WIDTH 8
`define M_WIDTH 31-`E_WIDTH

class stimulus;
    rand bit rst;
    rand bit [`E_WIDTH+`M_WIDTH:0] A;
    rand bit [`E_WIDTH+`M_WIDTH:0] B;
    bit [`E_WIDTH+`M_WIDTH:0] res;

    integer exp_A;
    integer exp_B;
    integer exp_diff;
    integer val_A;
    integer val_B;
    integer shift_by;
    integer val;
    integer exp;

    constraint reset {rst dist {0:/10,1:/90};}

    function void expected();
        exp_A = $signed(A[`E_WIDTH+`M_WIDTH-1:`M_WIDTH]-127);
        exp_B = $signed(A[`E_WIDTH+`M_WIDTH-1:`M_WIDTH]-127);
        exp_diff = $signed(exp_A-exp_B);
        if (exp_diff < 0) begin
            shift_by = -1*exp_diff;
            val_A = A[`M_WIDTH-1:0]>>shift_by;
            val_B = B[`M_WIDTH-1:0];
            exp = exp_B + 127;
            if(A[`E_WIDTH+`M_WIDTH] == B[`E_WIDTH+`M_WIDTH]) 
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
            val_A = A[`M_WIDTH-1:0];
            val_B = B[`M_WIDTH-1:0]>>shift_by;
            exp = exp_A + 127;
            if(A[`E_WIDTH+`M_WIDTH] == B[`E_WIDTH+`M_WIDTH]) 
                val = val_A + val_B;
                if((val>>`M_WIDTH)==1) begin
                    val = val - 1;
                    exp = exp + 1;
                end
            else
                val = val_A - val_B; 
        end
        $display("val: %d, exp: %d",val,exp);
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
        $display("[%0t] rst = %d, A = %d, B = %d, Res = %d", $time(), rst, A, B, res);
        $display("[>>>] sign_A = %d, exp_A = %d, mnt_A = %d", A[`E_WIDTH+`M_WIDTH:0], $signed(A[`E_WIDTH+`M_WIDTH-1:`M_WIDTH] - 127), A[`M_WIDTH-1:0]);
        $display("[>>>] sign_B = %d, exp_B = %d, mnt_B = %d\n", B[`E_WIDTH+`M_WIDTH:0], $signed(B[`E_WIDTH+`M_WIDTH-1:`M_WIDTH] - 127), B[`M_WIDTH-1:0]);
        $display("[>>>] sign_res = %d, exp_res = %d, mnt_res = %d\n", res[`E_WIDTH+`M_WIDTH:0], $signed(res[`E_WIDTH+`M_WIDTH-1:`M_WIDTH] - 127), res[`M_WIDTH-1:0]);
    endtask
    
    initial begin 
        clk <= 0;
    end

    initial begin
        stimulus io = new();
        reset;
        show;
    
        repeat(10) begin
            io.randomize();

            rst <= io.rst;
            A <= io.A;
            B <= io.B;
            tick;
            show;
            io.expected();
        end
    end
endmodule