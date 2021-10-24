// decode_tb.v
// E_WIDTH can vary between 5 and 8
`define E_WIDTH 8
`define M_WIDTH 31-`E_WIDTH

class stimulus;
    rand bit rst;
    rand bit [`E_WIDTH+`M_WIDTH:0] A;
    rand bit [`E_WIDTH+`M_WIDTH:0] B;
    
    constraint reset {rst dist {0:/10,1:/90};}
endclass

module decode_tb;

    reg clk;
    reg rst;
    reg [`E_WIDTH+`M_WIDTH:0] A;
    reg [`E_WIDTH+`M_WIDTH:0] B;
    wire sign_A;
    wire sign_B;
    wire signed [`E_WIDTH-1:0] exp_A;
    wire signed [`E_WIDTH-1:0] exp_B;
    wire [`M_WIDTH-1:0] mnt_A;
    wire [`M_WIDTH-1:0] mnt_B;
    wire [`E_WIDTH-1:0] exp_diff;
    wire gt_lt;
    
    decode #(`E_WIDTH, `M_WIDTH) uut (.clk(clk), .rst(rst), .A(A), .B(B), .sign_A(sign_A), .sign_B(sign_B), .exp_A(exp_A), .exp_B(exp_B), .mnt_A(mnt_A), .mnt_B(mnt_B), .exp_diff(exp_diff), .gt_lt(gt_lt));

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
        string Sign_A;
        string Sign_B;
        string Compare;
        if (sign_A==0)
            Sign_A = "Positive";
        else
            Sign_A = "Negative";
        if (sign_B==0)
            Sign_B = "Positive";
        else
            Sign_B = "Negative";
        
        if (gt_lt==1)
            Compare = "A > B";
        else
            Compare = "A <= B";
        $display("[%0t] rst = %b, A = %b, B = %b\n", $time(), rst, A, B);
        $display("[>>>] A: Sign: %s, Exp: %d, Mnt: %d\n", Sign_A, exp_A, mnt_A);
        $display("[>>>] B: Sign: %s, Exp: %d, Mnt: %d\n", Sign_B, exp_B, mnt_B);
        $display("[>>>] Compare: %s, Exp_diff: %d", Compare, exp_diff);        
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

            rst = io.rst;
            A = io.A;
            B = io.B;
            tick;
            show;
        end
    end
endmodule