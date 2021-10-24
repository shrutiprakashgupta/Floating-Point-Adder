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