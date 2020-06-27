module bcrx8 # (parameter EDGE_W = 96, parameter Bank_Num_W = 5)
(
	input wire 					clk,	
	input wire					rst,
	input wire					input_valid,
	input wire	[EDGE_W*8-1:0]	input_data,
	input wire					stall,
	output reg 	[EDGE_W-1:0]	output_data0,
	output reg					output_valid0,
	output reg 	[EDGE_W-1:0]	output_data1,
	output reg					output_valid1,	
	output reg 	[EDGE_W-1:0]	output_data2,
	output reg					output_valid2,
	output reg 	[EDGE_W-1:0]	output_data3,
	output reg					output_valid3,	
	output reg 	[EDGE_W-1:0]	output_data4,
	output reg					output_valid4,
	output reg 	[EDGE_W-1:0]	output_data5,
	output reg					output_valid5,	
	output reg 	[EDGE_W-1:0]	output_data6,
	output reg					output_valid6,
	output reg 	[EDGE_W-1:0]	output_data7,
	output reg					output_valid7,
	output reg					inc
);

reg	data0_outputed;
reg	data1_outputed;
reg	data2_outputed;
reg	data3_outputed;
reg	data4_outputed;
reg	data5_outputed;
reg	data6_outputed;
reg	data7_outputed;

reg input_valid_reg;
reg [EDGE_W*8-1:0] input_data_reg;
wire valid0, valid1, valid2, valid3, valid4, valid5, valid6, valid7, inc_wire;

always @(posedge clk) begin
	if(rst) begin
		input_valid_reg 	<= 1'b0;		 
		input_data_reg 		<= {(EDGE_W*8){1'b0}};		
	end else begin 	
		if(stall) begin
			input_valid_reg <= input_valid_reg;
			input_data_reg <= input_data_reg;
		end else begin
			input_valid_reg <= input_valid;
			input_data_reg <= input_data;		
		end
	end
end
	
wire [EDGE_W-1:0] data0;
wire [EDGE_W-1:0] data1;
wire [EDGE_W-1:0] data2;
wire [EDGE_W-1:0] data3;
wire [EDGE_W-1:0] data4;
wire [EDGE_W-1:0] data5;
wire [EDGE_W-1:0] data6;
wire [EDGE_W-1:0] data7;

assign	data0 = input_data_reg[EDGE_W-1:0];
assign	data1 = input_data_reg[EDGE_W*2-1:EDGE_W*1];
assign	data2 = input_data_reg[EDGE_W*3-1:EDGE_W*2];
assign	data3 = input_data_reg[EDGE_W*4-1:EDGE_W*3];
assign	data4 = input_data_reg[EDGE_W*5-1:EDGE_W*4];
assign	data5 = input_data_reg[EDGE_W*6-1:EDGE_W*5];
assign	data6 = input_data_reg[EDGE_W*7-1:EDGE_W*6];
assign	data7 = input_data_reg[EDGE_W*8-1:EDGE_W*7];

wire conflict01, conflict02, conflict03, conflict04, conflict05, conflict06, conflict07;
wire conflict12, conflict13, conflict14, conflict15, conflict16, conflict17;
wire conflict23, conflict24, conflict25, conflict26, conflict27;
wire conflict34, conflict35, conflict36, conflict37;
wire conflict45, conflict46, conflict47;
wire conflict56, conflict57;
wire conflict67;
wire conflict_free;

assign conflict01 = (data0[Bank_Num_W-1:0] == data1[Bank_Num_W-1:0]) ;
assign conflict02 = (data0[Bank_Num_W-1:0] == data2[Bank_Num_W-1:0]) ;
assign conflict03 = (data0[Bank_Num_W-1:0] == data3[Bank_Num_W-1:0]) ;
assign conflict04 = (data0[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0]) ;
assign conflict05 = (data0[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0]) ;
assign conflict06 = (data0[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0]) ;
assign conflict07 = (data0[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0]) ;
assign conflict12 = (data1[Bank_Num_W-1:0] == data2[Bank_Num_W-1:0]) ;
assign conflict13 = (data1[Bank_Num_W-1:0] == data3[Bank_Num_W-1:0]) ;
assign conflict14 = (data1[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0]) ;
assign conflict15 = (data1[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0]) ;
assign conflict16 = (data1[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0]) ;
assign conflict17 = (data1[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0]) ;
assign conflict23 = (data2[Bank_Num_W-1:0] == data3[Bank_Num_W-1:0]) ;
assign conflict24 = (data2[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0]) ;
assign conflict25 = (data2[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0]) ;
assign conflict26 = (data2[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0]) ;
assign conflict27 = (data2[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0]) ;
assign conflict34 = (data3[Bank_Num_W-1:0] == data4[Bank_Num_W-1:0]) ;
assign conflict35 = (data3[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0]) ;
assign conflict36 = (data3[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0]) ;
assign conflict37 = (data3[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0]) ;
assign conflict45 = (data4[Bank_Num_W-1:0] == data5[Bank_Num_W-1:0]) ;
assign conflict46 = (data4[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0]) ;
assign conflict47 = (data4[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0]) ;
assign conflict56 = (data5[Bank_Num_W-1:0] == data6[Bank_Num_W-1:0]) ;
assign conflict57 = (data5[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0]) ;
assign conflict67 = (data6[Bank_Num_W-1:0] == data7[Bank_Num_W-1:0]) ;
assign conflict_free =(~conflict01 && ~conflict02 && ~conflict03 && ~conflict04 && ~conflict05 && ~conflict06 && ~conflict07 && 
					   ~conflict12 && ~conflict13 && ~conflict14 && ~conflict15 && ~conflict16 && ~conflict17 &&  
					   ~conflict23 && ~conflict24 && ~conflict25 && ~conflict26 && ~conflict27 &&
					   ~conflict34 && ~conflict35 && ~conflict36 && ~conflict37 &&
					   ~conflict45 && ~conflict46 && ~conflict47 && ~conflict56 && ~conflict57 && ~conflict67);


assign	inc_wire = ~input_valid_reg ? 1'b0 :
			   (valid0 || data0_outputed) && (valid1 || data1_outputed) && (valid2 || data2_outputed)&&(valid3 || data3_outputed) && (valid4 || data4_outputed) && (valid5 || data5_outputed) && (valid6 || data6_outputed)	
			   && (valid7 || data7_outputed) ? 1'b1 :
			   conflict_free ? 1'b1 : 1'b0;	 
assign	valid0 = input_valid_reg && ~data0_outputed;
assign	valid1 = input_valid_reg && ~data1_outputed && (~valid0 || (valid0 && ~conflict01));
assign	valid2 = input_valid_reg && ~data2_outputed && (~valid0 || (valid0 && ~conflict02)) && (~valid1 || (valid1 && ~conflict12));
assign	valid3 = input_valid_reg && ~data3_outputed && (~valid0 || (valid0 && ~conflict03)) && (~valid1 || (valid1 && ~conflict13)) && (~valid2 || (valid2 && ~conflict23));
assign	valid4 = input_valid_reg && ~data4_outputed && (~valid0 || (valid0 && ~conflict04)) && (~valid1 || (valid1 && ~conflict14)) && (~valid2 || (valid2 && ~conflict24)) && (~valid3 || (valid3 && ~conflict34));
assign	valid5 = input_valid_reg && ~data5_outputed && (~valid0 || (valid0 && ~conflict05)) && (~valid1 || (valid1 && ~conflict15)) && (~valid2 || (valid2 && ~conflict25)) && (~valid3 || (valid3 && ~conflict35))
			 && (~valid4 || (valid4 && ~conflict45));
assign	valid6 = input_valid_reg && ~data6_outputed && (~valid0 || (valid0 && ~conflict06)) && (~valid1 || (valid1 && ~conflict16)) && (~valid2 || (valid2 && ~conflict26)) && (~valid3 || (valid3 && ~conflict36))
			 && (~valid4 || (valid4 && ~conflict46)) && (~valid5 || (valid5 && ~conflict56));		 
assign	valid7 = input_valid_reg && ~data7_outputed && (~valid0 || (valid0 && ~conflict07)) && (~valid1 || (valid1 && ~conflict17)) && (~valid2 || (valid2 && ~conflict27)) && (~valid3 || (valid3 && ~conflict37))
			 && (~valid4 || (valid4 && ~conflict47)) && (~valid5 || (valid5 && ~conflict57)) && (~valid6 || (valid6 && ~conflict67));			 

					   
always @(posedge clk) begin
	if(rst) begin
		output_data0 	<= 1'b0;		 
		output_data1 	<= 1'b0;
		output_data2 	<= 1'b0;		 
		output_data3 	<= 1'b0;
		output_data4 	<= 1'b0;		 
		output_data5 	<= 1'b0;
		output_data6 	<= 1'b0;		 
		output_data7 	<= 1'b0;
		output_valid0 	<= 1'b0;
		output_valid1	<= 1'b0;
		output_valid2 	<= 1'b0;
		output_valid3	<= 1'b0;
		output_valid4 	<= 1'b0;
		output_valid5	<= 1'b0;
		output_valid6 	<= 1'b0;
		output_valid7	<= 1'b0;
		data0_outputed 	<= 1'b0;
		data1_outputed  <= 1'b0;
		data2_outputed 	<= 1'b0;
		data3_outputed  <= 1'b0;
		data4_outputed 	<= 1'b0;
		data5_outputed  <= 1'b0;
		data6_outputed 	<= 1'b0;
		data7_outputed  <= 1'b0;
	end else begin 	
		output_data0 <= data0;
		output_data1 <= data1;
		output_data2 <= data2;
		output_data3 <= data3;
		output_data4 <= data4;
		output_data5 <= data5;
		output_data6 <= data6;
		output_data7 <= data7;		
		if(~stall) begin
			inc			 	<= inc_wire;
			output_valid0 	<= valid0;
			output_valid1 	<= valid1;
			output_valid2 	<= valid2;
			output_valid3 	<= valid3;
			output_valid4 	<= valid4;
			output_valid5 	<= valid5;
			output_valid6 	<= valid6;
			output_valid7 	<= valid7;
			data0_outputed  <= inc_wire ? 1'b0 : valid0   ? 1'b1 : data0_outputed;
			data1_outputed  <= inc_wire ? 1'b0 : valid1   ? 1'b1 : data1_outputed;
			data2_outputed  <= inc_wire ? 1'b0 : valid2   ? 1'b1 : data2_outputed;
			data3_outputed  <= inc_wire ? 1'b0 : valid3   ? 1'b1 : data3_outputed;
			data4_outputed  <= inc_wire ? 1'b0 : valid4   ? 1'b1 : data4_outputed;
			data5_outputed  <= inc_wire ? 1'b0 : valid5   ? 1'b1 : data5_outputed;
			data6_outputed  <= inc_wire ? 1'b0 : valid6   ? 1'b1 : data6_outputed;
			data7_outputed  <= inc_wire ? 1'b0 : valid7   ? 1'b1 : data7_outputed;			
		end else begin  
			output_valid0 	<= 1'b0;
			output_valid1	<= 1'b0;
			output_valid2 	<= 1'b0;
			output_valid3	<= 1'b0;
			output_valid4 	<= 1'b0;
			output_valid5	<= 1'b0;
			output_valid6 	<= 1'b0;
			output_valid7	<= 1'b0;
			data0_outputed 	<= data0_outputed;
			data1_outputed  <= data1_outputed;
			data2_outputed 	<= data2_outputed;
			data3_outputed  <= data3_outputed;
			data4_outputed 	<= data4_outputed;
			data5_outputed  <= data5_outputed;
			data6_outputed 	<= data6_outputed;
			data7_outputed  <= data7_outputed;
			inc				<= 1'b0;
		end
	end
end	
endmodule