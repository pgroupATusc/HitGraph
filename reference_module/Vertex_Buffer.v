module bufferx8 # (parameter DATA_W = 32, parameter ADDR_W =16, parameter Bank_Num_W = 5)
(	
	input wire 					clk,
	input wire 					rst,
	input wire [ADDR_W-1:0]		R_Addr0,
	input wire [ADDR_W-1:0]		R_Addr1,
	input wire [ADDR_W-1:0]		R_Addr2,
	input wire [ADDR_W-1:0]		R_Addr3,
	input wire [ADDR_W-1:0]		R_Addr4,
	input wire [ADDR_W-1:0]		R_Addr5,
	input wire [ADDR_W-1:0]		R_Addr6,
	input wire [ADDR_W-1:0]		R_Addr7,
	input wire [ADDR_W-1:0]		W_Addr0,
	input wire [ADDR_W-1:0]		W_Addr1,
	input wire [ADDR_W-1:0]		W_Addr2,
	input wire [ADDR_W-1:0]		W_Addr3,
	input wire [ADDR_W-1:0]		W_Addr4,
	input wire [ADDR_W-1:0]		W_Addr5,
	input wire [ADDR_W-1:0]		W_Addr6,
	input wire [ADDR_W-1:0]		W_Addr7,
	input wire [DATA_W-1:0]		W_Data0,
	input wire [DATA_W-1:0]		W_Data1,
	input wire [DATA_W-1:0]		W_Data2,
	input wire [DATA_W-1:0]		W_Data3,
	input wire [DATA_W-1:0]		W_Data4,
	input wire [DATA_W-1:0]		W_Data5,
	input wire [DATA_W-1:0]		W_Data6,
	input wire [DATA_W-1:0]		W_Data7,
	input wire					R_valid0,
	input wire					R_valid1,
	input wire					R_valid2,
	input wire					R_valid3,
	input wire					R_valid4,
	input wire					R_valid5,
	input wire					R_valid6,
	input wire					R_valid7,
	input wire 					W_valid0,
	input wire 					W_valid1,
	input wire 					W_valid2,
	input wire 					W_valid3,
	input wire 					W_valid4,
	input wire 					W_valid5,
	input wire 					W_valid6,
	input wire 					W_valid7,
	output reg					R_out_valid0,
	output reg					R_out_valid1,
	output reg					R_out_valid2,
	output reg					R_out_valid3,
	output reg					R_out_valid4,
	output reg					R_out_valid5,
	output reg					R_out_valid6,
	output reg					R_out_valid7,
	output wire [DATA_W-1:0]	R_Data0,
	output wire [DATA_W-1:0]	R_Data1,
	output wire [DATA_W-1:0]	R_Data2,
	output wire [DATA_W-1:0]	R_Data3,
	output wire [DATA_W-1:0]	R_Data4,
	output wire [DATA_W-1:0]	R_Data5,
	output wire [DATA_W-1:0]	R_Data6,
	output wire [DATA_W-1:0]	R_Data7
);

localparam Bank_Num = (2**Bank_Num_W);

wire [DATA_W-1:0] 				bank_rdata 	[Bank_Num-1:0];
wire [DATA_W-1:0] 				bank_wdata 	[Bank_Num-1:0];
wire [ADDR_W-Bank_Num_W-1:0] 	bank_raddr 	[Bank_Num-1:0];
wire [ADDR_W-Bank_Num_W-1:0] 	bank_waddr 	[Bank_Num-1:0];
wire 			  				bank_w_en  	[Bank_Num-1:0];
reg	 [Bank_Num_W-1:0] 		  	sel		 	[Bank_Num-1:0];

genvar numbank; 
generate for(numbank=0; numbank < Bank_Num; numbank = numbank+1) 
	begin: elements	
		/*URAM #(.DATA_W(DATA_W), .ADDR_W(ADDR_W-Bank_Num_W))
		bank (
			.Data_in(bank_wdata[numbank]),
			.R_Addr(bank_raddr[numbank]),
			.W_Addr(bank_waddr[numbank]),
			.W_En(bank_w_en[numbank]),
			.En(1'b1),
			.clk(clk),
			.Data_out(bank_rdata[numbank])
		);*/
		bank buffer(
		.data(bank_wdata[numbank]),
		.rdaddress(bank_raddr[numbank]),
		.wraddress(bank_waddr[numbank]),
		.wren(bank_w_en[numbank]),
		.clock(clk),
		.q(bank_rdata[numbank])
	);	
	end
endgenerate