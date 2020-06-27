`define data_width 8
 `define dimension 16
 `timescale 1ns/1ps

module tb_CaC;
    parameter DATA_W = 32;
	parameter PIPE_DEPTH = 3;
    parameter CLK_CYCLE = 5; // cycle time
    parameter seed = 1;
    
    reg         		clk;
    reg         		rst;
    reg  [0:0]         	InputValid_A;
    reg  [0:0]         	InputValid_B;
	reg  [DATA_W-1:0]   	InDestVid_A;
    reg  [DATA_W-1:0]   	InDestVid_B;
    reg  [DATA_W-1:0]   	InUpdate_A;
    reg  [DATA_W-1:0]   	InUpdate_B;
    wire [DATA_W-1:0]   	OutUpdate_A;
    wire [DATA_W-1:0]   	OutUpdate_B;
	wire [DATA_W-1:0]  	OutDestVid_A;
    wire [DATA_W-1:0]  	OutDestVid_B;
    wire [0:0]  			OutValid_A;
	wire [0:0]  			OutValid_B;
	
    
    
    always #(0.5 * CLK_CYCLE) clk = ~ clk;

    // Instanation
    CaC #(
        .DATA_W(DATA_W),
        .PIPE_DEPTH(PIPE_DEPTH)
    )
    dut(
        .clk(clk),
        .rst(rst),    
        .InputValid_A(InputValid_A),
        .InputValid_B(InputValid_B),
	    .InDestVid_A(InDestVid_A),
        .InDestVid_B(InDestVid_B),
        .InUpdate_A(InUpdate_A),
        .InUpdate_B(InUpdate_B),
        .OutUpdate_A(OutUpdate_A),
        .OutUpdate_B(OutUpdate_B),
	    .OutDestVid_A(OutDestVid_A),
        .OutDestVid_B(OutDestVid_B),
        .OutValid_A(OutValid_A),
	    .OutValid_B(OutValid_B)
	    
    );
   
    initial 
    begin: test
        clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE)
        rst = 0;
        InputValid_A = 1;
        InputValid_B = 1;
        InDestVid_A = 32'h0000002E ;
        InDestVid_B = 32'h0000002E ;
        InUpdate_A = 32'h00000001;
        InUpdate_B = 32'h00000004;
        #(CLK_CYCLE);
        /*InputValid_A = 1;
        InputValid_B = 1;
        InDestVid_A = 32'h0000001F ;
        InDestVid_B = 32'h0000001F ;
        InUpdate_A = 32'h00000001;
        InUpdate_B = 32'h00000001;
        #(CLK_CYCLE);
        InputValid_A = 1;
        InputValid_B = 1;
        InDestVid_A = 32'h0000001E ;
        InDestVid_B = 32'h0000001E ;
        InUpdate_A = 32'h00000001;
        InUpdate_B = 32'h00000001;
        #(CLK_CYCLE);
        InputValid_A = 1;
        InputValid_B = 0;
        InDestVid_A = 32'h0000001F ;
        InDestVid_B = 32'h0000001E ;
        InUpdate_A = 32'h00000001;
        InUpdate_B = 32'h00000001;
        #(CLK_CYCLE);
        InputValid_A = 0;
        InputValid_B = 0;
        InDestVid_A = 32'h0000001F ;
        InDestVid_B = 32'h0000001E ;
        InUpdate_A = 32'h00000001;
        InUpdate_B = 32'h00000001;*/
    end
    
endmodule