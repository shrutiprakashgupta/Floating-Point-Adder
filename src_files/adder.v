// adder.v
module adder #(parameter E_WIDTH=8, M_WIDTH=23) (clk, rst, add_sub, A, B, sign_res, exp_res, sum_spc_case, s_case, sum);   

    // Control Signal
    input clk;
    input rst;

    // Input-Output Signal
    input add_sub;
    input [M_WIDTH-1:0] A;
    input [M_WIDTH-1:0] B;
    input sign_res;
    input [E_WIDTH-1:0] exp_res;
    input [E_WIDTH+M_WIDTH:0] sum_spc_case;
    input s_case;
    output reg [E_WIDTH+M_WIDTH+1:0] sum;
    
    always @(posedge clk or negedge rst) begin
      
        if (rst == 1'b0) begin
            sum <= 0;
        end
        else if (s_case == 1'b1) begin
            sum <= {sum_spc_case[E_WIDTH+M_WIDTH:M_WIDTH],1'b0,sum_spc_case[M_WIDTH-1:0]};
        end
        else begin
          if (add_sub == 1'b0) begin
                sum[E_WIDTH+M_WIDTH+1:M_WIDTH+1] <= {sign_res,exp_res};
                sum[M_WIDTH:0] <= A + B;
            end
            else begin
                sum[E_WIDTH+M_WIDTH+1:M_WIDTH+1] <= {sign_res,exp_res};
                sum[M_WIDTH:0] <= A - B;
            end 
        end

    end
    
endmodule    