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
 end
endmodule

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

//align.v
module align #(parameter E_WIDTH=8, M_WIDTH=23) (clk, rst, sign_A, sign_B, A, B, exp_A, exp_B, exp_diff, gt_lt, align_A, align_B, sign_res, exp_res, add_sub);

    // Control Signal
    input clk;
    input rst;

    // Input-Output Signal
    input sign_A;
    input sign_B;
    input [M_WIDTH-1:0] A;
    input [M_WIDTH-1:0] B;
    input [E_WIDTH-1:0] exp_A;
    input [E_WIDTH-1:0] exp_B;
    input [E_WIDTH-1:0] exp_diff;
    input gt_lt;
    output reg [M_WIDTH-1:0] align_A;
    output reg [M_WIDTH-1:0] align_B;
    output reg sign_res;
    output reg [E_WIDTH-1:0] exp_res;
    output reg add_sub;
    
    // Wires
    wire [M_WIDTH-1:0] small_no;
    wire [M_WIDTH-1:0] align_A_wire;
    wire [M_WIDTH-1:0] align_B_wire;
    wire add_sub_wire;
  
    assign small_no = gt_lt?B:A;
    assign align_A_wire = gt_lt?A:B;
  	assign align_B_wire = small_no>>exp_diff;
    assign add_sub_wire = rst?(sign_A^sign_B):1'b0;
    
    always @(posedge clk or negedge rst) begin
        
        if (rst == 1'b0) begin
          	align_A <= 0;
          	align_B <= 0;
          	add_sub <= 0;
            sign_res <= 1'b0;
            exp_res <= 0;
        end
        else begin
          align_A <= align_A_wire;
          align_B <= align_B_wire;
          add_sub <= add_sub_wire;
          $display("gt_lt: %d",gt_lt);
          if (gt_lt == 1'b0) begin
            sign_res <= sign_B;
            exp_res <= $signed(exp_B)+127; 
          end
          else begin
            sign_res <= sign_A;
            exp_res <= $signed(exp_A)+127;
          end
        end
    end
endmodule    

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

module normalize #(parameter E_WIDTH=8, M_WIDTH=23) (clk, rst, sum, res);

    // Control Signals
    input clk;
    input rst;

    // Input-Output Signals
    input [E_WIDTH+M_WIDTH+1:0] sum;
    output reg [E_WIDTH+M_WIDTH:0] res;

    wire [E_WIDTH-1:0] exp;
    wire [M_WIDTH-1:0] val;
    parameter BIAS = 1 << (E_WIDTH-1);

    assign exp = sum[M_WIDTH]?sum[E_WIDTH+M_WIDTH:M_WIDTH+1]+1:sum[E_WIDTH+M_WIDTH:M_WIDTH+1];
    assign val = sum[M_WIDTH]?sum[M_WIDTH:1]:sum[M_WIDTH-1:0];

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            res <= 0;
        end
        else begin
            if (exp == BIAS) begin
                res[E_WIDTH+M_WIDTH:M_WIDTH] <= {sum[E_WIDTH+M_WIDTH+1],exp};
                res[M_WIDTH-1:0] <= 0; 
            end
            else begin
                res[E_WIDTH+M_WIDTH:M_WIDTH] <= {sum[E_WIDTH+M_WIDTH+1],exp};
                res[M_WIDTH-1:0] <= val;
            end
        end
    end
endmodule