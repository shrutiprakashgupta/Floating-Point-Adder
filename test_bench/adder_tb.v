// align_tb.v
// E_WIDTH can vary between 5 and 8
`define E_WIDTH 8
`define M_WIDTH 31-`E_WIDTH

class stimulus;
    rand bit rst;
    rand bit add_sub;
    rand bit [`M_WIDTH-1:0] A;
    rand bit [`M_WIDTH-1:0] B;
    rand bit sign_res;
    rand bit [`E_WIDTH-1:0] exp_res;
    bit [`E_WIDTH+`M_WIDTH:0] sum_spc_case;
    rand bit s_case;
    bit [`E_WIDTH+`M_WIDTH+1:0] sum;
    
    constraint reset {rst dist {0:/10,1:/90};}
    
    function void fix_values();
        if (s_case==1)
            sum = {1'b0,`E_WIDTH'b1,(`M_WIDTH+1)'b0};
        else begin
            if (add_sub==0)
                sum = A+B;
            else 
                sum = A-B;
            end
        sum_spc_case = {1'b0,`E_WIDTH'b1,`M_WIDTH'b0};
    endfunction

endclass

module adder_tb;

    reg clk;
    reg rst;
    reg add_sub;
    reg [`M_WIDTH-1:0] A;
    reg [`M_WIDTH-1:0] B;
    reg sign_res;
    reg signed [`E_WIDTH-1:0] exp_res;
    reg [`E_WIDTH+`M_WIDTH:0] sum_spc_case;
    reg s_case;
    wire [`E_WIDTH+`M_WIDTH+1:0] sum;
    
    align #(`E_WIDTH, `M_WIDTH) uut ( 
                .clk(clk), 
                .rst(rst),
                .add_sub(add_sub),
                .A(A),
                .B(B),
                .sign_res(sign_res),
                .exp_res(exp_res),
                .sum_spc_case(sum_spc_case),
                .s_case(s_case),
                .sum(sum));

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
        io.fix_values();
        $display("[%0t] rst = %b, sum: %d", $time(), rst, io.sum);
        $display("[>>>] rst = %b, sum_res: %d\n", $time(), rst, sum);    
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
            add_sub <= io.add_sub;
            A <= io.A;
            B <= io.B;
            sign_res <= io.sign_res;
          	exp_res <= io.exp_res;
            sum_spc_case <= io.sum_spc_case;
            s_case <= io.s_case;
            tick;
          	show(io);
        end
    end
endmodule