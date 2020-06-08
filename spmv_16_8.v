module sspmv #(
 	 parameter FIFO_WIDTH = 768,
 	 parameter PIPE_DEPTH = 5, 
 	 parameter URAM_DATA_W = 32,
 	 parameter PAR_SIZE_W = 18,
 	 parameter Bank_Num_W = 4,
 	 parameter PAR_NUM   = 32,
 	 parameter PAR_NUM_W = 5,
 	 parameter EDGE_W = 96,
 	 parameter PIPE_NUM = 8,
 	 parameter PIPE_NUM_W = 3
)(
	 input wire clk,
	 input wire rst,
	 input wire  [FIFO_WIDTH-1:0] RData0,
	 input wire  [0:0] RDataV0,
	 input wire  [0:0] r_en0,
	 input wire  [0:0] w_en0,
	 output reg  [31:0]	RAddr0,
	 output wire [511:0] WData0,
	 output wire WDataV0,
	 input wire  [FIFO_WIDTH-1:0] RData1,
	 input wire  [0:0] RDataV1,
	 input wire  [0:0] r_en1,
	 input wire  [0:0] w_en1,
	 output reg  [31:0]	RAddr1,
	 output wire [511:0] WData1,
	 output wire WDataV1,
	 input wire  [FIFO_WIDTH-1:0] RData2,
	 input wire  [0:0] RDataV2,
	 input wire  [0:0] r_en2,
	 input wire  [0:0] w_en2,
	 output reg  [31:0]	RAddr2,
	 output wire [511:0] WData2,
	 output wire WDataV2,
	 input wire  [FIFO_WIDTH-1:0] RData3,
	 input wire  [0:0] RDataV3,
	 input wire  [0:0] r_en3,
	 input wire  [0:0] w_en3,
	 output reg  [31:0]	RAddr3,
	 output wire [511:0] WData3,
	 output wire WDataV3,
	 input wire  [FIFO_WIDTH-1:0] RData4,
	 input wire  [0:0] RDataV4,
	 input wire  [0:0] r_en4,
	 input wire  [0:0] w_en4,
	 output reg  [31:0]	RAddr4,
	 output wire [511:0] WData4,
	 output wire WDataV4,
	 input wire  [FIFO_WIDTH-1:0] RData5,
	 input wire  [0:0] RDataV5,
	 input wire  [0:0] r_en5,
	 input wire  [0:0] w_en5,
	 output reg  [31:0]	RAddr5,
	 output wire [511:0] WData5,
	 output wire WDataV5,
	 input wire  [FIFO_WIDTH-1:0] RData6,
	 input wire  [0:0] RDataV6,
	 input wire  [0:0] r_en6,
	 input wire  [0:0] w_en6,
	 output reg  [31:0]	RAddr6,
	 output wire [511:0] WData6,
	 output wire WDataV6,
	 input wire  [FIFO_WIDTH-1:0] RData7,
	 input wire  [0:0] RDataV7,
	 input wire  [0:0] r_en7,
	 input wire  [0:0] w_en7,
	 output reg  [31:0]	RAddr7,
	 output wire [511:0] WData7,
	 output wire WDataV7,
	 input wire  [FIFO_WIDTH-1:0] RData8,
	 input wire  [0:0] RDataV8,
	 input wire  [0:0] r_en8,
	 input wire  [0:0] w_en8,
	 output reg  [31:0]	RAddr8,
	 output wire [511:0] WData8,
	 output wire WDataV8,
	 input wire  [FIFO_WIDTH-1:0] RData9,
	 input wire  [0:0] RDataV9,
	 input wire  [0:0] r_en9,
	 input wire  [0:0] w_en9,
	 output reg  [31:0]	RAddr9,
	 output wire [511:0] WData9,
	 output wire WDataV9,
	 input wire  [FIFO_WIDTH-1:0] RData10,
	 input wire  [0:0] RDataV10,
	 input wire  [0:0] r_en10,
	 input wire  [0:0] w_en10,
	 output reg  [31:0]	RAddr10,
	 output wire [511:0] WData10,
	 output wire WDataV10,
	 input wire  [FIFO_WIDTH-1:0] RData11,
	 input wire  [0:0] RDataV11,
	 input wire  [0:0] r_en11,
	 input wire  [0:0] w_en11,
	 output reg  [31:0]	RAddr11,
	 output wire [511:0] WData11,
	 output wire WDataV11,
	 input wire  [FIFO_WIDTH-1:0] RData12,
	 input wire  [0:0] RDataV12,
	 input wire  [0:0] r_en12,
	 input wire  [0:0] w_en12,
	 output reg  [31:0]	RAddr12,
	 output wire [511:0] WData12,
	 output wire WDataV12,
	 input wire  [FIFO_WIDTH-1:0] RData13,
	 input wire  [0:0] RDataV13,
	 input wire  [0:0] r_en13,
	 input wire  [0:0] w_en13,
	 output reg  [31:0]	RAddr13,
	 output wire [511:0] WData13,
	 output wire WDataV13,
	 input wire  [FIFO_WIDTH-1:0] RData14,
	 input wire  [0:0] RDataV14,
	 input wire  [0:0] r_en14,
	 input wire  [0:0] w_en14,
	 output reg  [31:0]	RAddr14,
	 output wire [511:0] WData14,
	 output wire WDataV14,
	 input wire  [FIFO_WIDTH-1:0] RData15,
	 input wire  [0:0] RDataV15,
	 input wire  [0:0] r_en15,
	 input wire  [0:0] w_en15,
	 output reg  [31:0]	RAddr15,
	 output wire [511:0] WData15,
	 output wire WDataV15,
	 input wire start
);
localparam  IDLE=0, SCATTER=1, GATHER=2;
reg   [1:0] 	state, nxtState;
wire  [15:0] 	PE_DONE;
wire 	[0:0] 	new_par_start [15:0];
wire 	[0:0] 	new_par_active [15:0];
wire 	[0:0] 	par_active [15:0];
wire 	[0:0] 	w_stall_request [15:0];
wire 	[0:0]		FIFO_full [15:0];
wire 	[0:0]		par_complete_sig [15:0];
wire 	[31:0]	work_size [15:0];
wire  [31:0]  new_Raddr [15:0];
always @(posedge clk) begin
	 if (rst) begin state <= IDLE;  end else begin state <= nxtState; end
end
always @(posedge clk) begin
	 if (rst) begin RAddr0 <= 0;
	 end else begin;
	 	 if (new_par_start[0]) begin RAddr0 <= new_Raddr[0]; end else if (~FIFO_full[0] && r_en0) begin RAddr0 <= RAddr0 +1'b1; end else begin RAddr0 <= RAddr0; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr1 <= 0;
	 end else begin;
	 	 if (new_par_start[1]) begin RAddr1 <= new_Raddr[1]; end else if (~FIFO_full[1] && r_en1) begin RAddr1 <= RAddr1 +1'b1; end else begin RAddr1 <= RAddr1; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr2 <= 0;
	 end else begin;
	 	 if (new_par_start[2]) begin RAddr2 <= new_Raddr[2]; end else if (~FIFO_full[2] && r_en2) begin RAddr2 <= RAddr2 +1'b1; end else begin RAddr2 <= RAddr2; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr3 <= 0;
	 end else begin;
	 	 if (new_par_start[3]) begin RAddr3 <= new_Raddr[3]; end else if (~FIFO_full[3] && r_en3) begin RAddr3 <= RAddr3 +1'b1; end else begin RAddr3 <= RAddr3; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr4 <= 0;
	 end else begin;
	 	 if (new_par_start[4]) begin RAddr4 <= new_Raddr[4]; end else if (~FIFO_full[4] && r_en4) begin RAddr4 <= RAddr4 +1'b1; end else begin RAddr4 <= RAddr4; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr5 <= 0;
	 end else begin;
	 	 if (new_par_start[5]) begin RAddr5 <= new_Raddr[5]; end else if (~FIFO_full[5] && r_en5) begin RAddr5 <= RAddr5 +1'b1; end else begin RAddr5 <= RAddr5; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr6 <= 0;
	 end else begin;
	 	 if (new_par_start[6]) begin RAddr6 <= new_Raddr[6]; end else if (~FIFO_full[6] && r_en6) begin RAddr6 <= RAddr6 +1'b1; end else begin RAddr6 <= RAddr6; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr7 <= 0;
	 end else begin;
	 	 if (new_par_start[7]) begin RAddr7 <= new_Raddr[7]; end else if (~FIFO_full[7] && r_en7) begin RAddr7 <= RAddr7 +1'b1; end else begin RAddr7 <= RAddr7; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr8 <= 0;
	 end else begin;
	 	 if (new_par_start[8]) begin RAddr8 <= new_Raddr[8]; end else if (~FIFO_full[8] && r_en8) begin RAddr8 <= RAddr8 +1'b1; end else begin RAddr8 <= RAddr8; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr9 <= 0;
	 end else begin;
	 	 if (new_par_start[9]) begin RAddr9 <= new_Raddr[9]; end else if (~FIFO_full[9] && r_en9) begin RAddr9 <= RAddr9 +1'b1; end else begin RAddr9 <= RAddr9; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr10 <= 0;
	 end else begin;
	 	 if (new_par_start[10]) begin RAddr10 <= new_Raddr[10]; end else if (~FIFO_full[10] && r_en10) begin RAddr10 <= RAddr10 +1'b1; end else begin RAddr10 <= RAddr10; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr11 <= 0;
	 end else begin;
	 	 if (new_par_start[11]) begin RAddr11 <= new_Raddr[11]; end else if (~FIFO_full[11] && r_en11) begin RAddr11 <= RAddr11 +1'b1; end else begin RAddr11 <= RAddr11; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr12 <= 0;
	 end else begin;
	 	 if (new_par_start[12]) begin RAddr12 <= new_Raddr[12]; end else if (~FIFO_full[12] && r_en12) begin RAddr12 <= RAddr12 +1'b1; end else begin RAddr12 <= RAddr12; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr13 <= 0;
	 end else begin;
	 	 if (new_par_start[13]) begin RAddr13 <= new_Raddr[13]; end else if (~FIFO_full[13] && r_en13) begin RAddr13 <= RAddr13 +1'b1; end else begin RAddr13 <= RAddr13; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr14 <= 0;
	 end else begin;
	 	 if (new_par_start[14]) begin RAddr14 <= new_Raddr[14]; end else if (~FIFO_full[14] && r_en14) begin RAddr14 <= RAddr14 +1'b1; end else begin RAddr14 <= RAddr14; end
	 end
end
always @(posedge clk) begin
	 if (rst) begin RAddr15 <= 0;
	 end else begin;
	 	 if (new_par_start[15]) begin RAddr15 <= new_Raddr[15]; end else if (~FIFO_full[15] && r_en15) begin RAddr15 <= RAddr15 +1'b1; end else begin RAddr15 <= RAddr15; end
	 end
end
genvar pe_num;

always @(*) begin
	 nxtState = state;
	 case (state)
	 	 IDLE : begin if (start) nxtState = SCATTER; end
	 	 SCATTER : begin if (PE_DONE==16'b1111111111111111) nxtState = GATHER; end 
	 	 GATHER : begin if (PE_DONE==16'b1111111111111111) nxtState = IDLE; end 
	 endcase
end

generate for(pe_num=0; pe_num <16; pe_num = pe_num+1)
begin: schedulers scheduler # (.PAR_NUM(PAR_NUM),.PAR_NUM_W(PAR_NUM_W)) sched (
		.clk(clk),
		.rst(rst),
		.control(state),
		.par_complete_sig(par_complete_sig[pe_num]),
		.par_active(par_active[pe_num]),
		.Raddr(new_Raddr[pe_num]),
		.work_size(work_size[pe_num]),
		.new_par_start(new_par_start[pe_num]),
		.new_par_active(new_par_active[pe_num]),
		.PE_DONE(PE_DONE[pe_num:pe_num]));
end
endgenerate

wire [FIFO_WIDTH-1:0]	PE_input_word [15:0];
wire [0:0]	PE_input_valid [15:0];
wire [511:0]	PE_output_word [15:0];
wire [0:0]	PE_output_valid [15:0];
wire [0:0]	PE_w_en [15:0];
assign PE_input_word[0] = RData0;
assign PE_input_valid[0] = RDataV0;
assign PE_w_en[0] = w_en0;
assign WData0 = PE_output_word[0];
assign WDataV0 = PE_output_valid[0];
assign w_stall_request[0] = ~w_en0;
assign PE_input_word[1] = RData1;
assign PE_input_valid[1] = RDataV1;
assign PE_w_en[1] = w_en1;
assign WData1 = PE_output_word[1];
assign WDataV1 = PE_output_valid[1];
assign w_stall_request[1] = ~w_en1;
assign PE_input_word[2] = RData2;
assign PE_input_valid[2] = RDataV2;
assign PE_w_en[2] = w_en2;
assign WData2 = PE_output_word[2];
assign WDataV2 = PE_output_valid[2];
assign w_stall_request[2] = ~w_en2;
assign PE_input_word[3] = RData3;
assign PE_input_valid[3] = RDataV3;
assign PE_w_en[3] = w_en3;
assign WData3 = PE_output_word[3];
assign WDataV3 = PE_output_valid[3];
assign w_stall_request[3] = ~w_en3;
assign PE_input_word[4] = RData4;
assign PE_input_valid[4] = RDataV4;
assign PE_w_en[4] = w_en4;
assign WData4 = PE_output_word[4];
assign WDataV4 = PE_output_valid[4];
assign w_stall_request[4] = ~w_en4;
assign PE_input_word[5] = RData5;
assign PE_input_valid[5] = RDataV5;
assign PE_w_en[5] = w_en5;
assign WData5 = PE_output_word[5];
assign WDataV5 = PE_output_valid[5];
assign w_stall_request[5] = ~w_en5;
assign PE_input_word[6] = RData6;
assign PE_input_valid[6] = RDataV6;
assign PE_w_en[6] = w_en6;
assign WData6 = PE_output_word[6];
assign WDataV6 = PE_output_valid[6];
assign w_stall_request[6] = ~w_en6;
assign PE_input_word[7] = RData7;
assign PE_input_valid[7] = RDataV7;
assign PE_w_en[7] = w_en7;
assign WData7 = PE_output_word[7];
assign WDataV7 = PE_output_valid[7];
assign w_stall_request[7] = ~w_en7;
assign PE_input_word[8] = RData8;
assign PE_input_valid[8] = RDataV8;
assign PE_w_en[8] = w_en8;
assign WData8 = PE_output_word[8];
assign WDataV8 = PE_output_valid[8];
assign w_stall_request[8] = ~w_en8;
assign PE_input_word[9] = RData9;
assign PE_input_valid[9] = RDataV9;
assign PE_w_en[9] = w_en9;
assign WData9 = PE_output_word[9];
assign WDataV9 = PE_output_valid[9];
assign w_stall_request[9] = ~w_en9;
assign PE_input_word[10] = RData10;
assign PE_input_valid[10] = RDataV10;
assign PE_w_en[10] = w_en10;
assign WData10 = PE_output_word[10];
assign WDataV10 = PE_output_valid[10];
assign w_stall_request[10] = ~w_en10;
assign PE_input_word[11] = RData11;
assign PE_input_valid[11] = RDataV11;
assign PE_w_en[11] = w_en11;
assign WData11 = PE_output_word[11];
assign WDataV11 = PE_output_valid[11];
assign w_stall_request[11] = ~w_en11;
assign PE_input_word[12] = RData12;
assign PE_input_valid[12] = RDataV12;
assign PE_w_en[12] = w_en12;
assign WData12 = PE_output_word[12];
assign WDataV12 = PE_output_valid[12];
assign w_stall_request[12] = ~w_en12;
assign PE_input_word[13] = RData13;
assign PE_input_valid[13] = RDataV13;
assign PE_w_en[13] = w_en13;
assign WData13 = PE_output_word[13];
assign WDataV13 = PE_output_valid[13];
assign w_stall_request[13] = ~w_en13;
assign PE_input_word[14] = RData14;
assign PE_input_valid[14] = RDataV14;
assign PE_w_en[14] = w_en14;
assign WData14 = PE_output_word[14];
assign WDataV14 = PE_output_valid[14];
assign w_stall_request[14] = ~w_en14;
assign PE_input_word[15] = RData15;
assign PE_input_valid[15] = RDataV15;
assign PE_w_en[15] = w_en15;
assign WData15 = PE_output_word[15];
assign WDataV15 = PE_output_valid[15];
assign w_stall_request[15] = ~w_en15;
generate for(pe_num=0; pe_num <16; pe_num = pe_num+1)
begin: PEs
	 PE #(.FIFO_WIDTH(FIFO_WIDTH), .PIPE_DEPTH(PIPE_DEPTH),.URAM_DATA_W(URAM_DATA_W),.PAR_SIZE_W(PAR_SIZE_W), .PAR_NUM_W(PAR_NUM_W)) engine (
		.clk(clk),
		.rst(rst),
		.control(state),
		.input_word(PE_input_word[pe_num]),
		.input_valid(PE_input_valid[pe_num]),
		.stall_request(w_stall_request[pe_num]),
		.work_size(work_size[pe_num]),
		.new_par_start(new_par_start[pe_num]),
		.new_par_active(new_par_active[pe_num]),
		.w_en(PE_w_en[pe_num]),
		.DRAM_W(PE_output_word[pe_num]),
		.DRAM_W_valid(PE_output_valid[pe_num]),
		.par_complete_sig(par_complete_sig[pe_num]),
		.FIFO_full(FIFO_full[pe_num]),
		.par_active(par_active[pe_num]));
end
endgenerate

endmodule