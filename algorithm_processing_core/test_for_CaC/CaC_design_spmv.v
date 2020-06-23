module CaC # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 3
)(
	input wire          		clk,
    input wire          		rst,    
    input wire  [0:0]         	InputValid_A,
    input wire  [0:0]         	InputValid_B,
	input wire  [DATA_W-1:0]   	InDestVid_A,
    input wire  [DATA_W-1:0]   	InDestVid_B,
    input wire  [DATA_W-1:0]   	InUpdate_A,
    input wire  [DATA_W-1:0]   	InUpdate_B,
    
    output reg [0:0]   	Valid_reg_A0,
    output reg [0:0]   	Valid_reg_A1,
    output reg [0:0]   	Valid_reg_A2,
    output reg [DATA_W-1:0]   	DestVid_reg_A0,
    output reg [DATA_W-1:0]   	DestVid_reg_A1,
    output reg [DATA_W-1:0]   	DestVid_reg_A2,
    output reg [DATA_W-1:0]   	Update_reg_A0,
    output reg [DATA_W-1:0]   	Update_reg_A1,
    output reg [DATA_W-1:0]   	Update_reg_A2,
    output reg [0:0]   	Valid_reg_B0,
    output reg [0:0]   	Valid_reg_B1,
    output reg [0:0]   	Valid_reg_B2,
    output reg [DATA_W-1:0]   	DestVid_reg_B0,
    output reg [DATA_W-1:0]   	DestVid_reg_B1,
    output reg [DATA_W-1:0]   	DestVid_reg_B2,
    output reg [DATA_W-1:0]   	Update_reg_B0,
    output reg [DATA_W-1:0]   	Update_reg_B1,
    output reg [DATA_W-1:0]   	Update_reg_B2,
    
    output wire [DATA_W-1:0]   	OutUpdate_A,
    output wire [DATA_W-1:0]   	OutUpdate_B,
	output wire [DATA_W-1:0]  	OutDestVid_A,
    output wire [DATA_W-1:0]  	OutDestVid_B,
    output wire [0:0]  			OutValid_A,
	output wire [0:0]  			OutValid_B
);

reg [0:0]			Valid_reg_A 	[PIPE_DEPTH-1:0];
reg [0:0]			Valid_reg_B 	[PIPE_DEPTH-1:0];
reg [DATA_W-1:0]	DestVid_reg_A 	[PIPE_DEPTH-1:0];
reg [DATA_W-1:0]	DestVid_reg_B 	[PIPE_DEPTH-1:0];
reg [DATA_W-1:0]	Update_reg_A 	[PIPE_DEPTH-1:0];
reg [DATA_W-1:0]	Update_reg_B 	[PIPE_DEPTH-1:0];
integer i;

always @(*)begin
    Valid_reg_A0 = Valid_reg_A[0];
    Valid_reg_A1 = Valid_reg_A[1];
    Valid_reg_A2 = Valid_reg_A[2];
    DestVid_reg_A0 = DestVid_reg_A[0];
    DestVid_reg_A1 = DestVid_reg_A[1];
    DestVid_reg_A2 = DestVid_reg_A[2];
    Update_reg_A0 = Update_reg_A[0];
    Update_reg_A1 = Update_reg_A[1];
    Update_reg_A2 = Update_reg_A[2];
    Valid_reg_B0 = Valid_reg_B[0];
    Valid_reg_B1 = Valid_reg_B[1];
    Valid_reg_B2 = Valid_reg_B[2];
    DestVid_reg_B0 = DestVid_reg_B[0];
    DestVid_reg_B1 = DestVid_reg_B[1];
    DestVid_reg_B2 = DestVid_reg_B[2];
    Update_reg_B0 = Update_reg_B[0];
    Update_reg_B1 = Update_reg_B[1];
    Update_reg_B2 = Update_reg_B[2];
end

always @(posedge clk) begin
	if (rst) begin
		for(i=0; i<PIPE_DEPTH; i=i+1) begin 
            Valid_reg_A [i] <= 0;    
			Valid_reg_B [i] <= 0;
			DestVid_reg_A [i] <= 0;
			DestVid_reg_B [i] <= 0;
			Update_reg_A [i] <= 0;
			Update_reg_B [i] <= 0;
        end 
	end	else begin
		Valid_reg_A[0] <= (InputValid_A & InputValid_B & InDestVid_B<InDestVid_A) ? InputValid_B : InputValid_A;
		Valid_reg_B[0] <= (InputValid_A & InputValid_B & InDestVid_B>InDestVid_A) ? InputValid_A : InputValid_B;
		DestVid_reg_A[0] <= (InputValid_A & InputValid_B & InDestVid_B<InDestVid_A) ? InDestVid_B : InDestVid_A;
		DestVid_reg_B[0] <= (InputValid_A & InputValid_B & InDestVid_B>InDestVid_A) ? InDestVid_A : InDestVid_B;
		Update_reg_A [0] <= (InputValid_A & InputValid_B & InDestVid_B<InDestVid_A) ? InUpdate_B : InUpdate_A;
		Update_reg_B [0] <= (InputValid_A & InputValid_B & InDestVid_B>InDestVid_A) ? InUpdate_A : InUpdate_B;
		for(i=1; i<PIPE_DEPTH; i=i+1) begin 
            Valid_reg_A [i] <= Valid_reg_A [i-1];    
			Valid_reg_B [i] <= Valid_reg_B [i-1];
			DestVid_reg_A [i] <= DestVid_reg_A [i-1];
			DestVid_reg_B [i] <= DestVid_reg_B [i-1];
			Update_reg_A [i] <= Update_reg_A [i-1];
			Update_reg_B [i] <= Update_reg_B [i-1];
        end 		
	end
end
	
wire [DATA_W-1:0] result; 
	
combine_unit combiner(
    .clk    (clk),    
    .update_A (Update_reg_A [0]),    
    .update_B (Update_reg_B [0]),                          
    .combined_update (result),
    .rst(rst)
);
assign OutDestVid_A = 	DestVid_reg_A[PIPE_DEPTH-1];
assign OutDestVid_B = 	DestVid_reg_A[PIPE_DEPTH-1];
assign OutValid_A	= 	Valid_reg_A[PIPE_DEPTH-1];
assign OutValid_B 	= 	(Valid_reg_A[PIPE_DEPTH-1] & Valid_reg_B[PIPE_DEPTH-1] & (DestVid_reg_A[PIPE_DEPTH-1]==DestVid_reg_B[PIPE_DEPTH-1])) ? 1'b0 : Valid_reg_B[PIPE_DEPTH-1];
assign OutUpdate_A 	= 	(Valid_reg_A[PIPE_DEPTH-1] & Valid_reg_B[PIPE_DEPTH-1] & (DestVid_reg_A[PIPE_DEPTH-1]==DestVid_reg_B[PIPE_DEPTH-1])) ? result : Update_reg_A [PIPE_DEPTH-1];
assign OutUpdate_B 	= 	(Valid_reg_A[PIPE_DEPTH-1] & Valid_reg_B[PIPE_DEPTH-1] & (DestVid_reg_A[PIPE_DEPTH-1]==DestVid_reg_B[PIPE_DEPTH-1])) ? 0 : Update_reg_B [PIPE_DEPTH-1];
	
endmodule

module combine_unit (
 	 input wire clk,
 	 input wire [31:0] update_A, 
 	 input wire [31:0] update_B, 
 	 input wire rst,
	 output wire [31:0] combined_update
);
	add add(
	.clk(clk),
	.a(update_A),
	.b(update_B),
	.q(combined_update),
	.areset(rst),
	.en(1'b1));
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