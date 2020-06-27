`timescale 1ns / 1ps

module CNx8_tb;
    parameter DATA_W = 32;
	parameter PIPE_DEPTH = 5;
	parameter CLK_CYCLE = 5;
	reg          			clk;
    reg          			rst;    
    reg  [7:0]         		InputValid;
	reg  [DATA_W*8-1:0]   	InDestVid;   
    reg  [DATA_W*8-1:0]   	InUpdate;   
    wire [DATA_W*8-1:0]   	OutUpdate;
    wire [DATA_W*8-1:0]  	OutDestVid;
	wire [7:0]  				OutValid;
	always #(0.5 * CLK_CYCLE) clk = ~ clk;
	CNx8 #(
	   .DATA_W(DATA_W),
	   .PIPE_DEPTH(PIPE_DEPTH)
	)
	DUT(
	   .clk(clk),
	   .rst(rst),
	   .InputValid(InputValid),
	   .InDestVid(InDestVid),
	   .InUpdate(InUpdate),
	   .OutUpdate(OutUpdate),
	   .OutDestVid(OutDestVid),
	   .OutValid(OutValid)  
	);
	initial 
    begin: test
        clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE)
        rst = 0;
        // 8 input with different address 
        #(CLK_CYCLE);
        InputValid = 8'b11111111;
        InDestVid = 256'h0000000100000002000000030000000400000005000000060000000700000008;
        InUpdate = 256'h0000000100000001000000010000000100000001000000010000000100000001;
        #(CLK_CYCLE);
        InputValid = 8'b11111111;
        InDestVid = 256'h0000000200000002000000020000000500000005000000010000000500000001;
        InUpdate = 256'h0000000100000001000000010000000100000001000000010000000100000001;
        end
endmodule
