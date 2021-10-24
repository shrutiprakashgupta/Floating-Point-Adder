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