module CNx8 # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 5
)(
	input wire          			clk,
    input wire          			rst,    
    input wire  [7:0]         		InputValid,
	input wire  [DATA_W*8-1:0]   	InDestVid,    
    input wire  [DATA_W*8-1:0]   	InUpdate,    
    output wire [DATA_W*8-1:0]   	OutUpdate,
    output wire [DATA_W*8-1:0]  	OutDestVid,
	output wire [7:0]  				OutValid
);

wire [7:0]  			Valid_wire  	[4:0];
wire [DATA_W*8-1:0] 	Update_wire 	[4:0];
wire [DATA_W*8-1:0] 	DestVid_wire 	[4:0];
    
// stage 0 
CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage00 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(InputValid[0:0]),
	.InputValid_B(InputValid[1:1]),
	.InDestVid_A(InDestVid[DATA_W*0+DATA_W-1:DATA_W*0]),
	.InDestVid_B(InDestVid[DATA_W*1+DATA_W-1:DATA_W*1]),
	.InUpdate_A(InUpdate[DATA_W*0+DATA_W-1:DATA_W*0]),
	.InUpdate_B(InUpdate[DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutUpdate_A(Update_wire[0][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(Update_wire[0][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_A(DestVid_wire[0][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(DestVid_wire[0][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutValid_A(Valid_wire[0][0:0]),
	.OutValid_B(Valid_wire[0][1:1])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage01 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(InputValid[2:2]),
	.InputValid_B(InputValid[3:3]),
	.InDestVid_A(InDestVid[DATA_W*2+DATA_W-1:DATA_W*2]),
	.InDestVid_B(InDestVid[DATA_W*3+DATA_W-1:DATA_W*3]),
	.InUpdate_A(InUpdate[DATA_W*2+DATA_W-1:DATA_W*2]),
	.InUpdate_B(InUpdate[DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutUpdate_A(Update_wire[0][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutUpdate_B(Update_wire[0][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutDestVid_A(DestVid_wire[0][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutDestVid_B(DestVid_wire[0][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutValid_A(Valid_wire[0][2:2]),
	.OutValid_B(Valid_wire[0][3:3])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage02 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(InputValid[4:4]),
	.InputValid_B(InputValid[5:5]),
	.InDestVid_A(InDestVid[DATA_W*4+DATA_W-1:DATA_W*4]),
	.InDestVid_B(InDestVid[DATA_W*5+DATA_W-1:DATA_W*5]),
	.InUpdate_A(InUpdate[DATA_W*4+DATA_W-1:DATA_W*4]),
	.InUpdate_B(InUpdate[DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutUpdate_A(Update_wire[0][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutUpdate_B(Update_wire[0][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutDestVid_A(DestVid_wire[0][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutDestVid_B(DestVid_wire[0][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutValid_A(Valid_wire[0][4:4]),
	.OutValid_B(Valid_wire[0][5:5])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage03 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(InputValid[6:6]),
	.InputValid_B(InputValid[7:7]),
	.InDestVid_A(InDestVid[DATA_W*6+DATA_W-1:DATA_W*6]),
	.InDestVid_B(InDestVid[DATA_W*7+DATA_W-1:DATA_W*7]),
	.InUpdate_A(InUpdate[DATA_W*6+DATA_W-1:DATA_W*6]),
	.InUpdate_B(InUpdate[DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutUpdate_A(Update_wire[0][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutUpdate_B(Update_wire[0][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutDestVid_A(DestVid_wire[0][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutDestVid_B(DestVid_wire[0][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutValid_A(Valid_wire[0][6:6]),
	.OutValid_B(Valid_wire[0][7:7])
);

// stage 1
CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage10 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[0][0:0]),
	.InputValid_B(Valid_wire[0][2:2]),
	.InDestVid_A(DestVid_wire[0][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InDestVid_B(DestVid_wire[0][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InUpdate_A(Update_wire[0][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InUpdate_B(Update_wire[0][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutUpdate_A(Update_wire[1][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(Update_wire[1][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutDestVid_A(DestVid_wire[1][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(DestVid_wire[1][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutValid_A(Valid_wire[1][0:0]),
	.OutValid_B(Valid_wire[1][2:2])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage11 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[0][1:1]),
	.InputValid_B(Valid_wire[0][3:3]),
	.InDestVid_A(DestVid_wire[0][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InDestVid_B(DestVid_wire[0][DATA_W*3+DATA_W-1:DATA_W*3]),
	.InUpdate_A(Update_wire[0][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InUpdate_B(Update_wire[0][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutUpdate_A(Update_wire[1][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutUpdate_B(Update_wire[1][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutDestVid_A(DestVid_wire[1][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_B(DestVid_wire[1][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutValid_A(Valid_wire[1][1:1]),
	.OutValid_B(Valid_wire[1][3:3])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage12 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[0][4:4]),
	.InputValid_B(Valid_wire[0][6:6]),
	.InDestVid_A(DestVid_wire[0][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InDestVid_B(DestVid_wire[0][DATA_W*6+DATA_W-1:DATA_W*6]),
	.InUpdate_A(Update_wire[0][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InUpdate_B(Update_wire[0][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutUpdate_A(Update_wire[1][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutUpdate_B(Update_wire[1][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutDestVid_A(DestVid_wire[1][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutDestVid_B(DestVid_wire[1][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutValid_A(Valid_wire[1][4:4]),
	.OutValid_B(Valid_wire[1][6:6])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage13 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[0][5:5]),
	.InputValid_B(Valid_wire[0][7:7]),
	.InDestVid_A(DestVid_wire[0][DATA_W*5+DATA_W-1:DATA_W*5]),
	.InDestVid_B(DestVid_wire[0][DATA_W*7+DATA_W-1:DATA_W*7]),
	.InUpdate_A(Update_wire[0][DATA_W*5+DATA_W-1:DATA_W*5]),
	.InUpdate_B(Update_wire[0][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutUpdate_A(Update_wire[1][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutUpdate_B(Update_wire[1][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutDestVid_A(DestVid_wire[1][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutDestVid_B(DestVid_wire[1][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutValid_A(Valid_wire[1][5:5]),
	.OutValid_B(Valid_wire[1][7:7])
);

// stage 2
CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage20 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[1][0:0]),
	.InputValid_B(Valid_wire[1][1:1]),
	.InDestVid_A(DestVid_wire[1][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InDestVid_B(DestVid_wire[1][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InUpdate_A(Update_wire[1][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InUpdate_B(Update_wire[1][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutUpdate_A(Update_wire[2][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(Update_wire[2][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_A(DestVid_wire[2][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(DestVid_wire[2][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutValid_A(Valid_wire[2][0:0]),
	.OutValid_B(Valid_wire[2][1:1])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage21 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[1][2:2]),
	.InputValid_B(Valid_wire[1][3:3]),
	.InDestVid_A(DestVid_wire[1][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InDestVid_B(DestVid_wire[1][DATA_W*3+DATA_W-1:DATA_W*3]),
	.InUpdate_A(Update_wire[1][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InUpdate_B(Update_wire[1][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutUpdate_A(Update_wire[2][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutUpdate_B(Update_wire[2][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutDestVid_A(DestVid_wire[2][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutDestVid_B(DestVid_wire[2][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutValid_A(Valid_wire[2][2:2]),
	.OutValid_B(Valid_wire[2][3:3])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage22 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[1][4:4]),
	.InputValid_B(Valid_wire[1][5:5]),
	.InDestVid_A(DestVid_wire[1][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InDestVid_B(DestVid_wire[1][DATA_W*5+DATA_W-1:DATA_W*5]),
	.InUpdate_A(Update_wire[1][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InUpdate_B(Update_wire[1][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutUpdate_A(Update_wire[2][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutUpdate_B(Update_wire[2][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutDestVid_A(DestVid_wire[2][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutDestVid_B(DestVid_wire[2][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutValid_A(Valid_wire[2][4:4]),
	.OutValid_B(Valid_wire[2][5:5])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage23 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[1][6:6]),
	.InputValid_B(Valid_wire[1][7:7]),
	.InDestVid_A(DestVid_wire[1][DATA_W*6+DATA_W-1:DATA_W*6]),
	.InDestVid_B(DestVid_wire[1][DATA_W*7+DATA_W-1:DATA_W*7]),
	.InUpdate_A(Update_wire[1][DATA_W*6+DATA_W-1:DATA_W*6]),
	.InUpdate_B(Update_wire[1][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutUpdate_A(Update_wire[2][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutUpdate_B(Update_wire[2][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutDestVid_A(DestVid_wire[2][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutDestVid_B(DestVid_wire[2][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutValid_A(Valid_wire[2][6:6]),
	.OutValid_B(Valid_wire[2][7:7])
);

// stage 3
CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage30 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[2][0:0]),
	.InputValid_B(Valid_wire[2][4:4]),
	.InDestVid_A(DestVid_wire[2][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InDestVid_B(DestVid_wire[2][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InUpdate_A(Update_wire[2][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InUpdate_B(Update_wire[2][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutUpdate_A(Update_wire[3][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(Update_wire[3][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutDestVid_A(DestVid_wire[3][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(DestVid_wire[3][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutValid_A(Valid_wire[3][0:0]),
	.OutValid_B(Valid_wire[3][4:4])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage31 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[2][1:1]),
	.InputValid_B(Valid_wire[2][5:5]),
	.InDestVid_A(DestVid_wire[2][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InDestVid_B(DestVid_wire[2][DATA_W*5+DATA_W-1:DATA_W*5]),
	.InUpdate_A(Update_wire[2][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InUpdate_B(Update_wire[2][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutUpdate_A(Update_wire[3][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutUpdate_B(Update_wire[3][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutDestVid_A(DestVid_wire[3][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_B(DestVid_wire[3][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutValid_A(Valid_wire[3][1:1]),
	.OutValid_B(Valid_wire[3][5:5])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage32 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[2][2:2]),
	.InputValid_B(Valid_wire[2][6:6]),
	.InDestVid_A(DestVid_wire[2][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InDestVid_B(DestVid_wire[2][DATA_W*6+DATA_W-1:DATA_W*6]),
	.InUpdate_A(Update_wire[2][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InUpdate_B(Update_wire[2][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutUpdate_A(Update_wire[3][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutUpdate_B(Update_wire[3][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutDestVid_A(DestVid_wire[3][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutDestVid_B(DestVid_wire[3][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutValid_A(Valid_wire[3][2:2]),
	.OutValid_B(Valid_wire[3][6:6])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage33 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[2][3:3]),
	.InputValid_B(Valid_wire[2][7:7]),
	.InDestVid_A(DestVid_wire[2][DATA_W*3+DATA_W-1:DATA_W*3]),
	.InDestVid_B(DestVid_wire[2][DATA_W*7+DATA_W-1:DATA_W*7]),
	.InUpdate_A(Update_wire[2][DATA_W*3+DATA_W-1:DATA_W*3]),
	.InUpdate_B(Update_wire[2][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutUpdate_A(Update_wire[3][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutUpdate_B(Update_wire[3][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutDestVid_A(DestVid_wire[3][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutDestVid_B(DestVid_wire[3][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutValid_A(Valid_wire[3][3:3]),
	.OutValid_B(Valid_wire[3][7:7])
);

// stage 4
CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage40 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[3][0:0]),
	.InputValid_B(Valid_wire[3][2:2]),
	.InDestVid_A(DestVid_wire[3][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InDestVid_B(DestVid_wire[3][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InUpdate_A(Update_wire[3][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InUpdate_B(Update_wire[3][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutUpdate_A(Update_wire[4][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(Update_wire[4][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutDestVid_A(DestVid_wire[4][DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(DestVid_wire[4][DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutValid_A(Valid_wire[4][0:0]),
	.OutValid_B(Valid_wire[4][2:2])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage41 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[3][1:1]),
	.InputValid_B(Valid_wire[3][3:3]),
	.InDestVid_A(DestVid_wire[3][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InDestVid_B(DestVid_wire[3][DATA_W*3+DATA_W-1:DATA_W*3]),
	.InUpdate_A(Update_wire[3][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InUpdate_B(Update_wire[3][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutUpdate_A(Update_wire[4][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutUpdate_B(Update_wire[4][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutDestVid_A(DestVid_wire[4][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_B(DestVid_wire[4][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutValid_A(Valid_wire[4][1:1]),
	.OutValid_B(Valid_wire[4][3:3])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage42 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[3][4:4]),
	.InputValid_B(Valid_wire[3][6:6]),
	.InDestVid_A(DestVid_wire[3][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InDestVid_B(DestVid_wire[3][DATA_W*6+DATA_W-1:DATA_W*6]),
	.InUpdate_A(Update_wire[3][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InUpdate_B(Update_wire[3][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutUpdate_A(Update_wire[4][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutUpdate_B(Update_wire[4][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutDestVid_A(DestVid_wire[4][DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutDestVid_B(DestVid_wire[4][DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutValid_A(Valid_wire[4][4:4]),
	.OutValid_B(Valid_wire[4][6:6])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage43 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[3][5:5]),
	.InputValid_B(Valid_wire[3][7:7]),
	.InDestVid_A(DestVid_wire[3][DATA_W*5+DATA_W-1:DATA_W*5]),
	.InDestVid_B(DestVid_wire[3][DATA_W*7+DATA_W-1:DATA_W*7]),
	.InUpdate_A(Update_wire[3][DATA_W*5+DATA_W-1:DATA_W*5]),
	.InUpdate_B(Update_wire[3][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutUpdate_A(Update_wire[4][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutUpdate_B(Update_wire[4][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutDestVid_A(DestVid_wire[4][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutDestVid_B(DestVid_wire[4][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutValid_A(Valid_wire[4][5:5]),
	.OutValid_B(Valid_wire[4][7:7])
);

// stage 5
CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage50 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[4][0:0]),
	.InputValid_B(Valid_wire[4][1:1]),
	.InDestVid_A(DestVid_wire[4][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InDestVid_B(DestVid_wire[4][DATA_W*1+DATA_W-1:DATA_W*1]),
	.InUpdate_A(Update_wire[4][DATA_W*0+DATA_W-1:DATA_W*0]),
	.InUpdate_B(Update_wire[4][DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutUpdate_A(OutUpdate[DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(OutUpdate[DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_A(OutDestVid[DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(OutDestVid[DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutValid_A(OutValid[0:0]),
	.OutValid_B(OutValid[1:1])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage51 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[4][2:2]),
	.InputValid_B(Valid_wire[4][3:3]),
	.InDestVid_A(DestVid_wire[4][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InDestVid_B(DestVid_wire[4][DATA_W*3+DATA_W-1:DATA_W*3]),
	.InUpdate_A(Update_wire[4][DATA_W*2+DATA_W-1:DATA_W*2]),
	.InUpdate_B(Update_wire[4][DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutUpdate_A(OutUpdate[DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutUpdate_B(OutUpdate[DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutDestVid_A(OutDestVid[DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutDestVid_B(OutDestVid[DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutValid_A(OutValid[2:2]),
	.OutValid_B(OutValid[3:3])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage52 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[4][4:4]),
	.InputValid_B(Valid_wire[4][5:5]),
	.InDestVid_A(DestVid_wire[4][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InDestVid_B(DestVid_wire[4][DATA_W*5+DATA_W-1:DATA_W*5]),
	.InUpdate_A(Update_wire[4][DATA_W*4+DATA_W-1:DATA_W*4]),
	.InUpdate_B(Update_wire[4][DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutUpdate_A(OutUpdate[DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutUpdate_B(OutUpdate[DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutDestVid_A(OutDestVid[DATA_W*4+DATA_W-1:DATA_W*4]),
	.OutDestVid_B(OutDestVid[DATA_W*5+DATA_W-1:DATA_W*5]),
	.OutValid_A(OutValid[4:4]),
	.OutValid_B(OutValid[5:5])
);

CaC #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
stage53 (
	.clk(clk),
	.rst(rst),
	.InputValid_A(Valid_wire[4][6:6]),
	.InputValid_B(Valid_wire[4][7:7]),
	.InDestVid_A(DestVid_wire[4][DATA_W*6+DATA_W-1:DATA_W*6]),
	.InDestVid_B(DestVid_wire[4][DATA_W*7+DATA_W-1:DATA_W*7]),
	.InUpdate_A(Update_wire[4][DATA_W*6+DATA_W-1:DATA_W*6]),
	.InUpdate_B(Update_wire[4][DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutUpdate_A(OutUpdate[DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutUpdate_B(OutUpdate[DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutDestVid_A(OutDestVid[DATA_W*6+DATA_W-1:DATA_W*6]),
	.OutDestVid_B(OutDestVid[DATA_W*7+DATA_W-1:DATA_W*7]),
	.OutValid_A(OutValid[6:6]),
	.OutValid_B(OutValid[7:7])
);

endmodule