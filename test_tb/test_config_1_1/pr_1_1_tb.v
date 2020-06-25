`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2020 06:34:33 PM
// Design Name: 
// Module Name: TB_PR
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


module TB_PR;
     parameter FIFO_WIDTH = 64;
 	 parameter PIPE_DEPTH = 5;
 	 parameter URAM_DATA_W = 64;
 	 parameter PAR_SIZE_W = 18;
 	 parameter Bank_Num_W = 4;
 	 parameter PAR_NUM   = 32;
 	 parameter PAR_NUM_W = 5;
 	 parameter EDGE_W = 64;
 	 parameter PIPE_NUM = 1;
 	 parameter PIPE_NUM_W = 0;
 	 parameter CLK_CYCLE = 10;
 	 
 	 reg clk;
	 reg rst;
	 reg  [FIFO_WIDTH-1:0] RData0;
	 reg  [0:0] RDataV0;
	 reg  [0:0] r_en0;
	 reg  [0:0] w_en0;
	 wire  [31:0]	RAddr0;
	 wire [511:0] WData0;
	 wire WDataV0;
	 reg start;
	 
	 always #(0.5 * CLK_CYCLE) clk = ~ clk;
	 task do_pr;
	   begin
	       RData0 = 64'h0000000100000000;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000200000001;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000200000003;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000400000003;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000500000004;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000200000005;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000100000000;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000200000001;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000200000003;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000400000003;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000500000004;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
        #(CLK_CYCLE);
        RData0 = 64'h0000000200000005;
        RDataV0 = 1;
        r_en0 = 1;
        w_en0 = 1;
        start = 1;
	   end 
	 endtask
	 
	 pr#(
	   .FIFO_WIDTH(FIFO_WIDTH),
 	   .PIPE_DEPTH(PIPE_DEPTH),
 	   .URAM_DATA_W (URAM_DATA_W),
 	 .PAR_SIZE_W(PAR_SIZE_W),
 	 .Bank_Num_W (Bank_Num_W),
 	 .PAR_NUM (PAR_NUM),
 	 .PAR_NUM_W(PAR_NUM_W),
 	 .EDGE_W(EDGE_W),
 	 .PIPE_NUM (PIPE_NUM),
 	.PIPE_NUM_W(PIPE_NUM_W)	 )
	 DUT(
	.clk(clk),
	.rst(rst),
	.RData0(RData0),
	.RDataV0(RDataV0),
	.r_en0(r_en0),
	.w_en0(w_en0),
	.RAddr0(RAddr0),
	.WData0(WData0),
	.WDataV0(WDataV0),
    .start(start)
	 );
	 initial
	 begin: test
	    clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE);
        rst = 0;
        do_pr;
        do_pr;
        do_pr;
	 end
	 
endmodule
