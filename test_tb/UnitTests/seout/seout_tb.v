`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 12:53:38 PM
// Design Name: 
// Module Name: seout_tb
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


module seout_tb;

    parameter CLK_CYCLE = 5;
    reg clk;
	reg rst;
	reg [63:0]	input_update0;
	reg [63:0]	input_update1;
	reg [63:0]	input_update2;
	reg [63:0]	input_update3;
	reg [63:0]	input_update4;
	reg [63:0]	input_update5;
	reg [63:0]	input_update6;
	reg [63:0]	input_update7;	
	reg input_valid0;
	reg input_valid1;
	reg input_valid2;
	reg input_valid3;
	reg input_valid4;
	reg input_valid5;
	reg input_valid6;
	reg input_valid7;
	wire	[63:0]	output_word;
	wire	output_valid;
	wire 	se_stall_request;
	
	always #(0.5 * CLK_CYCLE) clk = ~ clk;
	
	seout 
	DUT(
	   .clk(clk),
	   .rst(rst),
	   .input_update0(input_update0),
	   .input_update1(input_update1),
	   .input_update2(input_update2),
	   .input_update3(input_update3),
	   .input_update4(input_update4),
	   .input_update5(input_update5),
	   .input_update6(input_update6),
	   .input_update7(input_update7),	
	   .input_valid0(input_valid0),
	   .input_valid1(input_valid1),
	   .input_valid2(input_valid2),
	   .input_valid3(input_valid3),
	   .input_valid4(input_valid4),
	   .input_valid5(input_valid5),
	   .input_valid6(input_valid6),
	   .input_valid7(input_valid7),
	   .output_word(output_word),
	   .output_valid(output_valid),
	   .se_stall_request(se_stall_request)
	);
	
	 initial 
    begin: test
        clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE)
        rst = 0;
        input_valid0 = 1;
        input_valid1 = 1;
        input_valid2 = 1;
        input_valid3 = 1;
        input_valid4 = 1;
        input_valid5 = 1;
        input_valid6 = 1;
        input_valid7 = 1;
        input_update0 = 64'h0000000A0000000A;
        input_update1 = 64'h0000000B0000000B;
        input_update2 = 64'h0000000C0000000C;
        input_update3 = 64'h0000000D0000000D;
        input_update4 = 64'h0000000E0000000E;
        input_update5 = 64'h0000000F0000000F;
        input_update6 = 64'h0000000100000001;
        input_update7 = 64'h0000000200000002;
        #(10*CLK_CYCLE);
        $stop;
    end
endmodule
