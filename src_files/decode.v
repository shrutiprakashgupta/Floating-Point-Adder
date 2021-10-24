// Decode.v
module decode #(parameter E_WIDTH=8, M_WIDTH=23) (clk, rst, A, B, sign_A, sign_B, exp_A, exp_B, mnt_A, mnt_B, exp_diff, gt_lt);
    
    // Control Signals
    input clk;
    input rst;

    // Input-Output Signals
    input [E_WIDTH+M_WIDTH:0] A;
    input [E_WIDTH+M_WIDTH:0] B;
    output reg sign_A;
    output reg sign_B;
    output reg [E_WIDTH-1:0] exp_A;
    output reg [E_WIDTH-1:0] exp_B;
    output reg [M_WIDTH-1:0] mnt_A; 
    output reg [M_WIDTH-1:0] mnt_B; 
    output reg [E_WIDTH-1:0] exp_diff;
    output reg gt_lt;
    
    parameter BIAS = (1 << (E_WIDTH-1)) - 1;

    always @(posedge clk or negedge rst) begin
        // Reset
        if(rst == 1'b0) begin
            sign_A <= 0;
            sign_B <= 0;
            exp_A <= 0;
            exp_B <= 0;
            mnt_A <= 0;
            mnt_B <= 0;
            exp_diff <= 0;
            gt_lt <= 0;
        end

        else begin
            sign_A <= A[E_WIDTH+M_WIDTH];
            sign_B <= B[E_WIDTH+M_WIDTH];
          exp_A <= $signed(A[E_WIDTH+M_WIDTH-1:M_WIDTH]) - BIAS;
          exp_B <= $signed(B[E_WIDTH+M_WIDTH-1:M_WIDTH]) - BIAS;
            mnt_A <= A[M_WIDTH-1:0];
            mnt_B <= B[M_WIDTH-1:0];
            if (A[E_WIDTH+M_WIDTH-1:M_WIDTH] > B[E_WIDTH+M_WIDTH-1:M_WIDTH]) begin
                gt_lt = 1'b1;       //gt_lt = 1 if A > B
                exp_diff <= A[E_WIDTH+M_WIDTH-1:M_WIDTH] - B[E_WIDTH+M_WIDTH-1:M_WIDTH];
            end
            else begin
                gt_lt = 1'b0;       //gt_lt = 0 otherwise
                exp_diff <= B[E_WIDTH+M_WIDTH-1:M_WIDTH] - A[E_WIDTH+M_WIDTH-1:M_WIDTH];
            end 
        end

    end
    
endmodule 