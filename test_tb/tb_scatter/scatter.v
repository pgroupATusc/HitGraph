module spmv_scatter_pipe # (
    parameter PIPE_DEPTH = 3,
    parameter URAM_DATA_W = 32
)(
    input wire                      clk,
    input wire                      rst,    
    input wire [31:0]               edge_weight,
    input wire [URAM_DATA_W-1:0]    src_attr,
    input wire [31:0]               edge_dest,
    input wire [0:0]                input_valid,    
    output wire [31:0]              update_value,
    output wire [31:0]              update_dest,    
    output wire [0:0]               output_valid  
);
    reg [31:0] dest_reg [PIPE_DEPTH-1:0];    
    assign update_dest = dest_reg[PIPE_DEPTH-1];
    reg [0:0] dest_valid [PIPE_DEPTH-1:0]; 
    assign output_valid = dest_valid[PIPE_DEPTH-1];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for(i=0; i<PIPE_DEPTH; i=i+1) begin
                dest_reg[i] <= 0;
                dest_valid[i] <= 0;
            end
        end	else begin
            for(i=1; i<PIPE_DEPTH; i=i+1) begin
               dest_reg[i] <= dest_reg[i-1];
               dest_valid[i] <= dest_valid[i-1];
            end
            dest_reg [0] <=  edge_dest;  
            dest_valid[0] <= input_valid;          
        end
    end
    
   /* fp_mul multiplier(              
        .aclk(clk),
        .s_axis_a_tvalid(input_valid),        
        .s_axis_a_tdata(edge_weight),
        .s_axis_b_tvalid(input_valid),
        .s_axis_b_tdata(src_attr),
        .m_axis_result_tvalid (output_valid),
        //.m_axis_result_tready(1'b1),      
        .m_axis_result_tdata(update_value)              
    );*/
	mult mult(
	.clk(clk),
	.a(edge_weight),
	.b(src_attr),
	.q(update_value),
	.areset(rst),
	.en(input_valid)
);
    
endmodule
module mult(
	input wire clk,
	input wire [31 : 0] a,
	input wire [31 : 0] b,
	input wire areset,
	input wire en,
	output reg [31 : 0] q

);
	always @(posedge clk)begin
		if (areset)begin
		  q <= 0;
		end
		else begin
			if (en)begin
			  q <= a * b;
			end
		end
	end
endmodule