`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 05:18:30 PM
// Design Name: 
// Module Name: PR_pipeline
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module pr_PP # (
    parameter PIPE_DEPTH = 5,
    parameter URAM_DATA_W = 32,
    parameter PAR_SIZE_W = 10,
    parameter EDGE_W = 64
)(
    input wire                      clk,
    input wire                      rst,     
    input wire [1:0]                control,

    input wire [URAM_DATA_W-1:0]    buffer_Din,
    input wire                      buffer_Din_valid, 
      
    input wire [64-1:0]             Update_input_word,
    input wire [0:0]                Update_input_valid,
     
    input wire [31:0]               source_outcome,
    input wire [EDGE_W-1:0]         Edge_input_word,
    input wire [0:0]                Edge_input_valid,
    
    output wire [URAM_DATA_W-1:0]   buffer_Dout,
    output wire [PAR_SIZE_W-1:0]    buffer_Dout_Addr,
    output wire                     buffer_Dout_valid, 
       
    output wire [63:0]              output_word,    
    output wire [0:0]               output_valid,
    output wire [0:0]               par_active  
);
    reg [31:0]  Vertex_source_outcome;
    reg [EDGE_W-1:0] Edge_input_word_reg;
    reg [0:0]  Edge_input_valid_reg; 
    
    reg [64-1:0] Update_input_word_reg;
    reg [0:0]  Update_input_valid_reg; 
    
     always @(posedge clk) begin
        if (rst) begin
            Edge_input_word_reg <= 0;
            Edge_input_valid_reg <= 0;
            Update_input_word_reg <= 0;
            Update_input_valid_reg <= 0;
            Vertex_source_outcome <= 0;
        end  else begin
            Edge_input_word_reg <= Edge_input_word;
            Edge_input_valid_reg <= Edge_input_valid;
            Update_input_word_reg <= Update_input_word;
            Update_input_valid_reg <= Update_input_valid;
            Vertex_source_outcome <= source_outcome;
        end
      end
       
    pr_scatter_pipe # (.PIPE_DEPTH (PIPE_DEPTH), .URAM_DATA_W(URAM_DATA_W))
    scatter_unit (
        .clk(clk),
        .rst(rst),
        .src_attr(buffer_Din),
        .edge_dest(Edge_input_word_reg[63:32]),
        .src_outcome(Vertex_source_outcome),
        .input_valid(Edge_input_valid_reg && buffer_Din_valid && control==1),    
        .update_value(output_word[63:32]),
        .update_dest(output_word[31:0]),    
        .output_valid(output_valid)
    );

    pr_gather_pipe # (.PIPE_DEPTH (PIPE_DEPTH), .PAR_SIZE_W(PAR_SIZE_W), .URAM_DATA_W(URAM_DATA_W))
    gather_unit (
        .clk(clk),
        .rst(rst),
        .update_value(Update_input_word_reg[63:32]),
        .update_dest(Update_input_word_reg[31:0]),
        .dest_attr(buffer_Din),
        .input_valid(Update_input_valid_reg && buffer_Din_valid && control==2),    
        .WData(buffer_Dout),
        .WAddr(buffer_Dout_Addr),    
        .Wvalid(buffer_Dout_valid),
        .par_active(par_active)
    );
    
endmodule

module pr_gather_pipe # (
    parameter PIPE_DEPTH = 3,
    parameter PAR_SIZE_W = 18,
    parameter URAM_DATA_W = 32
)(
    input wire                      clk,
    input wire                      rst,        
    input wire [31:0]               update_value,
    input wire [31:0]               update_dest,
    
    input wire [URAM_DATA_W-1:0]    dest_attr,
    input wire [0:0]                input_valid,
        
    output wire [URAM_DATA_W-1:0]   WData,
    output wire [PAR_SIZE_W-1:0]    WAddr,    
    output wire [0:0]               Wvalid,
    output wire [0:0]               par_active  
);

    reg [0:0] valid_reg [PIPE_DEPTH-1:0];
    reg [31:0] dest_reg [PIPE_DEPTH-1:0];    
    assign WAddr = dest_reg[PIPE_DEPTH-1][PAR_SIZE_W-1:0];
    assign par_active = 1'b1;
    assign Wvalid = valid_reg[PIPE_DEPTH-1];    
       	
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for(i=0; i<PIPE_DEPTH; i=i+1) begin
                dest_reg[i] <= 0;
				valid_reg [i]<= 0;
            end
        end	else begin
            for(i=1; i<PIPE_DEPTH; i=i+1) begin
               dest_reg[i] <= dest_reg[i-1];
			   valid_reg[i] <= valid_reg[i-1];
            end
            dest_reg [0] <=  update_dest;            
			valid_reg[0] <= input_valid;
        end
    end    
    
    /*fp_add adder(              
        .aclk(clk),
        .s_axis_a_tvalid(input_valid),        
        .s_axis_a_tdata(update_value),
        .s_axis_b_tvalid(input_valid),
        .s_axis_b_tdata(dest_attr[31:0]),
        .m_axis_result_tvalid (Wvalid),
        //.m_axis_result_tready(1'b1),      
        .m_axis_result_tdata(WData[31:0])              
    );*/
    add add(
	.clk(clk),
	.a(update_value),
	.b(dest_attr),
	.q(WData),
	.areset(rst),
	.en(input_valid)
	);
    
	
endmodule
module pr_scatter_pipe # (
    parameter PIPE_DEPTH = 3,
    parameter URAM_DATA_W = 32
)(
    input wire                      clk,
    input wire                      rst,    
    
    input wire [URAM_DATA_W-1:0]    src_attr,
    input wire [31:0]               edge_dest,
    input wire [31:0]               src_outcome, //the outgoing edges of the src vertex
    input wire [0:0]                input_valid,
        
    output wire [31:0]              update_value,
    output wire [31:0]              update_dest,    
    output wire [0:0]               output_valid  
);
    reg [31:0] dest_reg [PIPE_DEPTH-1:0];
    reg [0:0]   Valid_out   [PIPE_DEPTH-1:0];    
    assign update_dest = dest_reg[PIPE_DEPTH-1];
    assign output_valid = Valid_out[PIPE_DEPTH-1];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for(i=0; i<PIPE_DEPTH; i=i+1) begin
                dest_reg[i] <= 0;
                Valid_out[i] <= 0;
            end
        end	else begin
            for(i=1; i<PIPE_DEPTH; i=i+1) begin
               dest_reg[i] <= dest_reg[i-1];
               Valid_out[i] <= Valid_out[i-1];
            end
            dest_reg [0] <=  edge_dest;
            Valid_out[0] <=   input_valid;          
        end
    end
    
    /*fp_mul multiplier(              
        .aclk(clk),
        .s_axis_a_tvalid(input_valid),        
        .s_axis_a_tdata(src_attr[31:0]),
        .s_axis_b_tvalid(input_valid),
        .s_axis_b_tdata(src_attr[63:32]),
        .m_axis_result_tvalid (output_valid),      
        .m_axis_result_tdata(update_value)
                      
    );*/
    mult mult(
	.clk(clk),
	.a(src_outcome),
	.b(src_attr),
	.q(update_value),
	.areset(rst),
	.en(input_valid));
    
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
module add(
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
			  q <= a + b;
			end
		end
	end
endmodule