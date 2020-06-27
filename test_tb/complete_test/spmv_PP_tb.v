`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 03:13:38 PM
// Design Name: 
// Module Name: spmv_PP_tb
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


module spmv_PP_tb;
    parameter PIPE_DEPTH = 5;
    parameter URAM_DATA_W = 32;
    parameter PAR_SIZE_W = 10;
    parameter EDGE_W = 96;
    parameter CLK_CYCLE = 5;
    reg                      clk;
    reg                      rst;     
    reg [1:0]                control;
    
    reg [URAM_DATA_W-1:0]    buffer_Din;
    
    reg                      buffer_Din_valid; 
    reg [EDGE_W-1:0]         Edge_input_word;
    
    reg [63:0]               Update_input;
    reg [0:0]                input_valid;
    
    wire [63:0]              output_Update;
    wire [0:0]               output_Update_Valid;
    
    wire [PAR_SIZE_W-1:0]    buffer_Dout_Addr;   
    wire [31:0]              output_New_Vertex;   
    wire [0:0]               output_Vertex_valid;
    
    wire [0:0]               par_active;
    
    spmv_PP #(
        .PIPE_DEPTH(PIPE_DEPTH),
        .URAM_DATA_W(URAM_DATA_W),
        .PAR_SIZE_W(PAR_SIZE_W),
        .EDGE_W(EDGE_W)
    )
    DUT(
        .clk(clk),
        .rst(rst),
        .control(control),
        .buffer_Din(buffer_Din),
        .buffer_Din_valid(buffer_Din_valid),
        
        .Update_input(Update_input),
        .Edge_input_word(Edge_input_word),
        .input_valid(input_valid),
        
        .output_Update(output_Update),
        .output_Update_Valid(output_Update_Valid),
        
        .buffer_Dout_Addr(buffer_Dout_Addr),
        .output_New_Vertex(output_New_Vertex),
        .output_Vertex_valid(output_Vertex_valid),
        
        .par_active(par_active)
    );
    always #(0.5 * CLK_CYCLE) clk = ~ clk;
    initial 
        begin: test
        clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE)
        rst = 0;
        control = 2'b01;
        buffer_Din = 32'h0000002;
        buffer_Din_valid = 1;
        Edge_input_word = 96'h000000020000000A0000000B;
        Update_input = 0;
        input_valid = 1;
        #(3 * CLK_CYCLE);
        control = 2'b10;
        buffer_Din = 32'h0000002;
        buffer_Din_valid = 1;
        Edge_input_word = 96'h000000020000000A0000000B;
        Update_input = 64'h000000010000000A;
        input_valid = 1;
        end
      
endmodule
