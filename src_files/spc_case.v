// Spc_case.v
module spc_case #(parameter E_WIDTH=8, M_WIDTH=23) (clk, rst, sign_A, sign_B, exp_A, exp_B, exp_A_org, exp_B_org, mnt_A, mnt_B, res, s_case);

    // Control Signals
    input clk;
    input rst;

    // Input-Output Signals
    input sign_A;
    input sign_B;
    input [E_WIDTH-1:0] exp_A;
    input [E_WIDTH-1:0] exp_B;
    input [E_WIDTH-1:0] exp_A_org;
    input [E_WIDTH-1:0] exp_B_org;
    input [M_WIDTH-1:0] mnt_A; 
    input [M_WIDTH-1:0] mnt_B; 
    output reg [E_WIDTH+M_WIDTH:0] res;
    output reg s_case;

    // Parameters 
    parameter BIAS = 1 << (E_WIDTH-1);
    parameter nBIAS = BIAS + 1'b1;

    always @(posedge clk or negedge rst) begin 

        if(rst == 1'b0) begin 
            res <= 0;
            s_case <= 0;
        end

        else begin
            // If any of them is Nan
            if (((exp_A==BIAS) && (mnt_A!=0)) || ((exp_B==BIAS) && (mnt_B!=0))) begin
                res[E_WIDTH+M_WIDTH] <= 1'b0;
                res[E_WIDTH+M_WIDTH-1:M_WIDTH] <= (BIAS<<1) - 1;
                res[M_WIDTH-1:0] <= 1;
                s_case <= 1'b1;
            end
            // -> None of them is Nan
            // If A is Inf
            else if (exp_A==BIAS) begin
                res <= {sign_A,exp_A_org,mnt_A};
                s_case <= 1'b1;
                // If B is also Inf and signs don't match
                if ((exp_B==BIAS) && (sign_A!=sign_B)) begin
                    res[E_WIDTH+M_WIDTH:M_WIDTH] <= {sign_A,exp_A_org};
                    res[M_WIDTH-1:0] <= 1;
                    s_case = 1'b1;
                end
            end
            // -> None of them is Nan and A is not Inf
            // If B is Inf
            else if (exp_B==BIAS) begin
                res <= {sign_B,exp_B_org,mnt_B};
                s_case <= 1'b1;
            end
            // -> None of them is Nan or Inf
            // If A is Zero
            else if (($signed(exp_A)==nBIAS) && (mnt_A==0)) begin
                res <= {sign_B,exp_B_org,mnt_B};
                s_case <= 1'b1;
            end
            // -> None of them is Nan or Inf, A is non Zero
            // If B is Zero
            else if (($signed(exp_B)==nBIAS) && (mnt_B==0)) begin
                res <= {sign_A,exp_A_org,mnt_A};
                s_case <= 1'b1;
            end
            // -> None of the special cases met
            else begin
                res <= 0;
                s_case <= 1'b0;
            end
        end
    end
endmodule