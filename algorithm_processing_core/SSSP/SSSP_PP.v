`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 05:39:55 PM
// Design Name: 
// Module Name: SSSP_PP
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

module SSSP_PP # (
	 parameter PIPE_DEPTH = 5,
	 parameter URAM_DATA_W = 32,
	 parameter PAR_SIZE_W = 18,
	 parameter EDGE_W = 64
)(
		input wire clk,
	 input wire                      rst,
	 input wire [1:0]                control,
	 
	 input wire [URAM_DATA_W-1:0]    buffer_Din,
	 input wire                      buffer_Din_valid,
	 
	 input wire [EDGE_W-1:0]         Edge_input_word,
	 input wire [0:0]                Edge_input_valid,
	 
	 input wire [64-1:0]             Update_input_word,
	 input wire [0:0]                Update_input_valid,
	 
	 output wire [URAM_DATA_W-1:0]   buffer_Dout,
	 output wire [PAR_SIZE_W-1:0]    buffer_Dout_Addr,
	 output wire                     buffer_Dout_valid,
	 
	 output wire [63:0]              output_word,
	 output wire [0:0]               output_valid,
	 
	 output wire [0:0]               par_active,
	 input wire [PAR_SIZE_W+URAM_DATA_W:0]	forward_input0,
	 output wire [PAR_SIZE_W+URAM_DATA_W:0]	forward_output
);
	 reg [EDGE_W-1:0] Edge_input_word_reg;
	 reg [0:0]  Edge_input_valid_reg;
	 
	 reg [64-1:0] Update_input_word_reg;
	 reg [0:0]  Update_input_valid_reg;
	 
	 wire [31:0] dest_attr;
	 always @(posedge clk) begin 
	 if (rst) begin 
         Edge_input_word_reg <= 0; 
         Edge_input_valid_reg <= 0;
         Update_input_word_reg <= 0 ; 
         Update_input_valid_reg <= 0;
	 end  
	 else begin 
         Edge_input_word_reg <= Edge_input_word; 
         Edge_input_valid_reg <= Edge_input_valid; 
         Update_input_word_reg <= Update_input_word;
         Update_input_valid_reg <= Update_input_valid;
	 end 
	 end
	 assign dest_attr =((control==2) && (forward_input0[PAR_SIZE_W+URAM_DATA_W:PAR_SIZE_W+URAM_DATA_W]) && (Update_input_word_reg[PAR_SIZE_W-1:0]==forward_input0[PAR_SIZE_W+URAM_DATA_W-1:URAM_DATA_W])) ? forward_input0[URAM_DATA_W-1:0] : buffer_Din;
	 assign forward_output = {buffer_Dout_valid, buffer_Dout_Addr, buffer_Dout};
	 
	 
	 sssp_scatter_pipe # 
	 (.PIPE_DEPTH (PIPE_DEPTH), .URAM_DATA_W(URAM_DATA_W)) 
	 scatter_unit (.clk(clk), 
	 .rst(rst), 
	 .edge_weight(Edge_input_word[63:48]), 
	 .src_attr(buffer_Din), 
	 .edge_dest(Edge_input_word[47:24]), 
	 .input_valid(Edge_input_valid_reg && buffer_Din_valid && control==1), 
	 .update_value(output_word[63:32]),
	 .update_dest(output_word[31:0]),
	 .output_valid(output_valid));
	 
	 
	 sssp_gather_pipe # (.PIPE_DEPTH (PIPE_DEPTH), 
	   .PAR_SIZE_W(PAR_SIZE_W), 
	   .URAM_DATA_W(URAM_DATA_W)) 
	   gather_unit (.clk(clk),
	   .rst(rst),
	   .update_value(Update_input_word_reg[63:32]),
	   .update_dest(Update_input_word_reg[31:0]),
	   .dest_attr(dest_attr),
	   .input_valid(Update_input_valid_reg && buffer_Din_valid && control==2),
	   .WData(buffer_Dout),
	   .WAddr(buffer_Dout_Addr),
	   .Wvalid(buffer_Dout_valid),
	   .par_active(par_active));
 
endmodule

module sssp_gather_pipe # (
    parameter PIPE_DEPTH = 1,
    parameter PAR_SIZE_W = 18,
    parameter URAM_DATA_W = 32
)(
    input wire                      clk,
    input wire                      rst,        
    input wire [31:0]               update_value,
    input wire [31:0]               update_dest,
    input wire [URAM_DATA_W-1:0]    dest_attr,
    input wire [0:0]                input_valid,    
    output reg [URAM_DATA_W-1:0]   WData,
    output reg [PAR_SIZE_W-1:0]    WAddr,    
    output reg [0:0]               Wvalid,
    output reg [0:0]               par_active  
);
    always @(posedge clk) begin
        if (rst) begin
            WData <= 0;
            WAddr <= 0;
            Wvalid <= 0;
            par_active <= 0;  
        end  else begin
            WAddr <= update_dest[PAR_SIZE_W-1:0];
            WData[30:0] <= (update_value < dest_attr) ? update_value[30:0] : dest_attr[30:0];            
            WData[31:31] <= input_valid && (update_value < dest_attr[30:0]);
			Wvalid <= input_valid && (update_value < dest_attr[30:0]);
            par_active <= input_valid && (update_value < dest_attr[30:0]);
        end
     end     
	
endmodule


module sssp_scatter_pipe # (
    parameter PIPE_DEPTH = 3,
    parameter URAM_DATA_W = 32
)(
    input wire                      clk,
    input wire                      rst,    
    input wire [15:0]               edge_weight,
    input wire [URAM_DATA_W-1:0]    src_attr,
    input wire [23:0]               edge_dest,
    input wire [0:0]                input_valid,    
    output reg [31:0]              update_value,
    output reg [31:0]              update_dest,    
    output reg [0:0]               output_valid  
);
    always @(posedge clk) begin
        if (rst) begin
            output_valid <= 0;
            update_value <= 0;
            update_dest <= 0;
        end else begin
            output_valid <= input_valid && src_attr[URAM_DATA_W-1:URAM_DATA_W-1];
            update_value <= edge_weight + src_attr[URAM_DATA_W-2:0];
            update_dest <= edge_dest;
        end
    end    
endmodule
