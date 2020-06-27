`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2020 09:52:38 PM
// Design Name: 
// Module Name: Ubuffx8_TB
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


module Ubuffx8_TB;
    reg clk;
    reg  rst;    
    reg last_input_in;
    reg [64*8-1:0] word_in;
	reg [7:0] word_in_valid;
    //input wire [1:0] control,        
    wire [64*8-1:0] word_out; 
    wire [7:0] valid_out;
    parameter CLK_CYCLE = 5;
    
    Ubuffx8
    DUT(
        .clk(clk),
        .rst(rst),
        .last_input_in(last_input_in),
        .word_in(word_in),
        .word_in_valid(word_in_valid),
        .word_out(word_out),
        .valid_out(valid_out)
        );
    always #(0.5 * CLK_CYCLE) clk = ~ clk;
    initial 
    begin: test
        clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE)
        rst = 0;
        last_input_in = 0;
        word_in = 512'h00000001000000020000000300000004000000050000000600000007000000080000000100000002000000030000000400000005000000060000000700000008;
        word_in_valid = 8'b11110000; 
        #(CLK_CYCLE);
        last_input_in = 0;
        word_in = 512'h0000000A0000000B0000000C0000000D0000000E0000000F0000000A0000000F0000000A0000000B0000000C0000000D0000000E0000000F0000000A0000000F;
        word_in_valid = 8'b10000000;
        #(CLK_CYCLE);
        last_input_in = 1;
        word_in = 512'h00000001000000020000000300000004000000050000000600000007000000080000000100000002000000030000000400000005000000060000000700000008;
        word_in_valid = 8'b10000000;
        #(10*CLK_CYCLE);
        $stop;
        //the waveform should be 00000001000000020000000300000004000000050000000600000007000000080000000A0000000B
        //the other should be zero
    end
endmodule
