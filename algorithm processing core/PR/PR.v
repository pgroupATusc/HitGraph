module PR #(parameter EDGE_W = 64)(
	 input wire  clk,
	 input wire  rst,
	 input wire  start,
	 input wire  [EDGE_W-1:0] RData,
	 input wire  RDataV,
	 input wire 	r_en0,
	 input wire 	w_en0,
	 output wire WDataV0,
	 input wire 	r_en1,
	 input wire 	w_en1,
	 output wire WDataV1,
	 input wire 	r_en2,
	 input wire 	w_en2,
	 output wire WDataV2,
	 input wire 	r_en3,
	 input wire 	w_en3,
	 output wire WDataV3,
		output reg [31:0]	RAddr,
		output reg [511:0] WData);
reg [EDGE_W-1:0]  RData_reg [31:0];
reg [4:0]   counter;
integer i;
always @(posedge clk) begin
	 if (rst) begin
	 	 counter <= 0;
	 	 for(i=0; i<32; i=i+1) begin RData_reg[i] <= 0; end
	  end else begin
	 	 if (RDataV) begin
	 	 	 for(i=1; i<32; i=i+1) begin RData_reg[i] <= RData_reg[i-1]; end
	 	 	 RData_reg[0] <= RData; counter <= counter+1;
	 	 end else begin
	 	 	 counter <= counter;
	 	 	 for(i=0; i<32; i=i+1) begin RData_reg[i] <= RData_reg[i]; end
	 	 end
	 end
end
wire [31:0]	RAddr_wire [3:0];
wire [511:0]	WData_wire [3:0];
ppr accelerator(
	 .clk(clk),
	 .rst(rst),
	 .RData0({RData_reg[0],RData_reg[1],RData_reg[2],RData_reg[3],RData_reg[4],RData_reg[5],RData_reg[6],RData_reg[7]}),
	 .RDataV0(counter == 31),
	 .r_en0(r_en0),
	 .w_en0(w_en0),
	 .RAddr0(RAddr_wire[0]),
	 .WData0(WData_wire[0]),
	 .WDataV0(WDataV0),
	 .RData1({RData_reg[8],RData_reg[9],RData_reg[10],RData_reg[11],RData_reg[12],RData_reg[13],RData_reg[14],RData_reg[15]}),
	 .RDataV1(counter == 31),
	 .r_en1(r_en1),
	 .w_en1(w_en1),
	 .RAddr1(RAddr_wire[1]),
	 .WData1(WData_wire[1]),
	 .WDataV1(WDataV1),
	 .RData2({RData_reg[16],RData_reg[17],RData_reg[18],RData_reg[19],RData_reg[20],RData_reg[21],RData_reg[22],RData_reg[23]}),
	 .RDataV2(counter == 31),
	 .r_en2(r_en2),
	 .w_en2(w_en2),
	 .RAddr2(RAddr_wire[2]),
	 .WData2(WData_wire[2]),
	 .WDataV2(WDataV2),
	 .RData3({RData_reg[24],RData_reg[25],RData_reg[26],RData_reg[27],RData_reg[28],RData_reg[29],RData_reg[30],RData_reg[31]}),
	 .RDataV3(counter == 31),
	 .r_en3(r_en3),
	 .w_en3(w_en3),
	 .RAddr3(RAddr_wire[3]),
	 .WData3(WData_wire[3]),
	 .WDataV3(WDataV3),
	 .start(start)
);
always @(posedge clk) begin
	 if (rst) begin 
	 		RAddr <= 0; WData <= 0;
	 end else begin 
	 	 RAddr <= (counter[1:0]==2'b11) ? RAddr_wire[3] : (counter[1:0]==2'b10) ? RAddr_wire[2] :	(counter[1:0]==2'b01) ? RAddr_wire[1] :	RAddr_wire[0];
	 	 WData <= (counter[1:0]==2'b11) ? WData_wire[3] : (counter[1:0]==2'b10) ? WData_wire[2] :	(counter[1:0]==2'b01) ? WData_wire[1] :	WData_wire[0];
	 end 
end
endmodule

module ppr #(
 	 parameter FIFO_WIDTH = 512,
 	 parameter PIPE_DEPTH = 8, 
 	 parameter URAM_DATA_W = 64,
 	 parameter PAR_SIZE_W = 18,
 	 parameter Bank_Num_W = 4,
 	 parameter PAR_NUM   = 32,
 	 parameter PAR_NUM_W = 5,
 	 parameter EDGE_W = 64,
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
	 input wire start
);
localparam  IDLE=0, SCATTER=1, GATHER=2;
reg   [1:0] 	state, nxtState;
wire  [7:0] 	PE_DONE;
wire 	[0:0] 	new_par_start [7:0];
wire 	[0:0] 	new_par_active [7:0];
wire 	[0:0] 	par_active [7:0];
wire 	[0:0] 	w_stall_request [7:0];
wire 	[0:0]		FIFO_full [7:0];
wire 	[0:0]		par_complete_sig [7:0];
wire 	[31:0]	work_size [7:0];
wire  [31:0]  new_Raddr [7:0];
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
genvar pe_num;

always @(*) begin
	 nxtState = state;
	 case (state)
	 	 IDLE : begin if (start) nxtState = SCATTER; end
	 	 SCATTER : begin if (PE_DONE==4'b1111) nxtState = GATHER; end 
	 	 GATHER : begin if (PE_DONE==4'b1111) nxtState = IDLE; end 
	 endcase
end

generate for(pe_num=0; pe_num <8; pe_num = pe_num+1)
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

wire [FIFO_WIDTH-1:0]	PE_input_word [7:0];
wire [0:0]	PE_input_valid [7:0];
wire [511:0]	PE_output_word [7:0];
wire [0:0]	PE_output_valid [7:0];
wire [0:0]	PE_w_en [7:0];
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
generate for(pe_num=0; pe_num <8; pe_num = pe_num+1)
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

module PE #(
 	 parameter FIFO_WIDTH = 512,
 	 parameter PIPE_DEPTH = 8, 
 	 parameter URAM_DATA_W = 64,
 	 parameter PAR_SIZE_W = 18,
 	 parameter Bank_Num_W = 4,
 	 parameter PAR_NUM   = 32,
 	 parameter PAR_NUM_W = 5,
 	 parameter EDGE_W = 64,
 	 parameter PIPE_NUM = 8,
 	 parameter PIPE_NUM_W = 3
)(
	 input wire 	 	 clk,
	 input wire 	 	 rst,
	 input wire [1:0] 	 	 control,
	 input wire [FIFO_WIDTH-1:0] 	 	 input_word,
	 input wire [0:0] 	 	 input_valid,
	 input wire [0:0] 	 	 stall_request,
	 input wire [31:0] 	 	 work_size,
	 input wire 	 	 new_par_start,
	 input wire 	 	 new_par_active,
	 input wire [0:0]		 	 w_en,
	 output wire [511:0] 	 	 DRAM_W,
	 output wire  	 	 DRAM_W_valid,	
	 output wire [0:0] 	 		 par_complete_sig,
	 output wire 	 	 FIFO_full,
	 output reg  [0:0] 	 	 par_active);
	 wire [URAM_DATA_W-1:0]	 	 buffer_DR [PIPE_NUM-1:0];
	 wire 	 	 buffer_DR_valid [PIPE_NUM-1:0];
	 wire [URAM_DATA_W-1:0]	 	 buffer_DW	[PIPE_NUM-1:0];
	 wire [PAR_SIZE_W-1:0]	 	 buffer_DW_Addr	[PIPE_NUM-1:0];
	 wire 	 	 buffer_DW_valid [PIPE_NUM-1:0]; 
	 wire [0:0] 	 	 PE_stall;
	 wire [FIFO_WIDTH-1:0] 	 	 fifo_out;
	 wire [FIFO_WIDTH-1:0] 	 	 pp_input_word;
	 wire [0:0] 	 		pp_input_word_valid	[PIPE_NUM-1:0];
	 reg 	[FIFO_WIDTH-1:0] 	 		pp_input_word_reg;
	 reg 	[0:0] 	 		pp_input_word_valid_reg	[PIPE_NUM-1:0];
	 wire [0:0] 	 	 FIFO_empty; 
	 wire [0:0] 	 	 bcr_r_en;
	 wire [63:0] 	 		pp_output_word [PIPE_NUM-1:0];
	 wire [0:0] 	 	 pp_output_valid [PIPE_NUM-1:0];
	 wire [PIPE_NUM-1:0] 	 	 par_active_wire;
	 wire [0:0] 	 	 se_request;
	 reg [31:0]		 	 done_work;
	 reg [31:0]		 	 total_work;
	 assign par_complete_sig = (done_work>=total_work);

	 always @(posedge clk) begin
	 	 if (rst) begin
	 	 	 pp_input_word_valid_reg [0] <= 1'b0;
	 	 	 pp_input_word_valid_reg [1] <= 1'b0;
	 	 	 pp_input_word_valid_reg [2] <= 1'b0;
	 	 	 pp_input_word_valid_reg [3] <= 1'b0;
	 	 	 pp_input_word_valid_reg [4] <= 1'b0;
	 	 	 pp_input_word_valid_reg [5] <= 1'b0;
	 	 	 pp_input_word_valid_reg [6] <= 1'b0;
	 	 	 pp_input_word_valid_reg [7] <= 1'b0;
	 	 	 pp_input_word_reg <= {(FIFO_WIDTH){1'b0}};
	 		end else begin
	 	 	 if(PE_stall) begin
	 	 	 		pp_input_word_reg <= pp_input_word_reg;
	 	 	 	 pp_input_word_valid_reg [0]<= pp_input_word_valid_reg [0];
	 	 	 	 pp_input_word_valid_reg [1]<= pp_input_word_valid_reg [1];
	 	 	 	 pp_input_word_valid_reg [2]<= pp_input_word_valid_reg [2];
	 	 	 	 pp_input_word_valid_reg [3]<= pp_input_word_valid_reg [3];
	 	 	 	 pp_input_word_valid_reg [4]<= pp_input_word_valid_reg [4];
	 	 	 	 pp_input_word_valid_reg [5]<= pp_input_word_valid_reg [5];
	 	 	 	 pp_input_word_valid_reg [6]<= pp_input_word_valid_reg [6];
	 	 	 	 pp_input_word_valid_reg [7]<= pp_input_word_valid_reg [7];
	 	 	 end else begin
	 	 	 		pp_input_word_valid_reg [0] <= pp_input_word_valid [0];
	 	 	 		pp_input_word_valid_reg [1] <= pp_input_word_valid [1];
	 	 	 		pp_input_word_valid_reg [2] <= pp_input_word_valid [2];
	 	 	 		pp_input_word_valid_reg [3] <= pp_input_word_valid [3];
	 	 	 		pp_input_word_valid_reg [4] <= pp_input_word_valid [4];
	 	 	 		pp_input_word_valid_reg [5] <= pp_input_word_valid [5];
	 	 	 		pp_input_word_valid_reg [6] <= pp_input_word_valid [6];
	 	 	 		pp_input_word_valid_reg [7] <= pp_input_word_valid [7];
	 	 	 	 pp_input_word_reg <= pp_input_word;
	 	 	 end
	 		end 
	 end

	 always @(posedge clk) begin 
	 	 if (rst) begin
	 	 	 done_work <= 0; total_work <= 65536; par_active <= 1'b0;
	 	 end	else begin
	 	 	 if (new_par_start) begin
	 	 	 		done_work <= 0; total_work <= (~new_par_active && control==1) ? 0 : work_size;
	 	 	 end else begin
	 	 	 		done_work <= done_work+input_valid; total_work <= total_work;
	 	 	 end
	 	 	 if (par_complete_sig) begin
	 	 	 		par_active <= 0;
	 	 	 end else begin
	 	 	 		par_active <= (control==2 && par_active_wire>0) ? 1'b1 : par_active;
	 	 	 end
	 	 end
	 end

	 fifo #(.FIFO_WIDTH(FIFO_WIDTH)) input_FIFO(
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .we(input_valid),
	 	 .din(input_word),
	 	 .re(~PE_stall && bcr_r_en),
	 	 .dout(fifo_out),
	 	 .count(),
	 	 .empty(FIFO_empty),
	 	 .almostempty(),
	 	 .full(FIFO_full),
	 	 .almostfull()
	 );

	 bcrx8 #(.EDGE_W(EDGE_W), .Bank_Num_W(Bank_Num_W)) BCR(
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .input_valid(~FIFO_empty),
	 	 .input_data(fifo_out),
	 		.stall(PE_stall),
	 	 .output_data0(pp_input_word[EDGE_W*1-1:EDGE_W*0]),
	 	 .output_valid0(pp_input_word_valid[0]),
	 	 .output_data1(pp_input_word[EDGE_W*2-1:EDGE_W*1]),
	 	 .output_valid1(pp_input_word_valid[1]),
	 	 .output_data2(pp_input_word[EDGE_W*3-1:EDGE_W*2]),
	 	 .output_valid2(pp_input_word_valid[2]),
	 	 .output_data3(pp_input_word[EDGE_W*4-1:EDGE_W*3]),
	 	 .output_valid3(pp_input_word_valid[3]),
	 	 .output_data4(pp_input_word[EDGE_W*5-1:EDGE_W*4]),
	 	 .output_valid4(pp_input_word_valid[4]),
	 	 .output_data5(pp_input_word[EDGE_W*6-1:EDGE_W*5]),
	 	 .output_valid5(pp_input_word_valid[5]),
	 	 .output_data6(pp_input_word[EDGE_W*7-1:EDGE_W*6]),
	 	 .output_valid6(pp_input_word_valid[6]),
	 	 .output_data7(pp_input_word[EDGE_W*8-1:EDGE_W*7]),
	 	 .output_valid7(pp_input_word_valid[7]),
	 	 .inc(bcr_r_en)
	 );

	 genvar pp_num;
	 wire [0:0] HDU_stall;
	 assign PE_stall = (HDU_stall && (control==2)) || stall_request || se_request;
	 hdux8 # (.ADDR_W(PAR_SIZE_W), .Bank_Num_W (Bank_Num_W)) HDU (
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .Raddr0(pp_input_word[EDGE_W*0+PAR_SIZE_W-1:EDGE_W*0]),
	 	 .Raddr1(pp_input_word[EDGE_W*1+PAR_SIZE_W-1:EDGE_W*1]),
	 	 .Raddr2(pp_input_word[EDGE_W*2+PAR_SIZE_W-1:EDGE_W*2]),
	 	 .Raddr3(pp_input_word[EDGE_W*3+PAR_SIZE_W-1:EDGE_W*3]),
	 	 .Raddr4(pp_input_word[EDGE_W*4+PAR_SIZE_W-1:EDGE_W*4]),
	 	 .Raddr5(pp_input_word[EDGE_W*5+PAR_SIZE_W-1:EDGE_W*5]),
	 	 .Raddr6(pp_input_word[EDGE_W*6+PAR_SIZE_W-1:EDGE_W*6]),
	 	 .Raddr7(pp_input_word[EDGE_W*7+PAR_SIZE_W-1:EDGE_W*7]),
	 	 .Waddr0(buffer_DW_Addr[0]),
	 	 .Waddr1(buffer_DW_Addr[1]),
	 	 .Waddr2(buffer_DW_Addr[2]),
	 	 .Waddr3(buffer_DW_Addr[3]),
	 	 .Waddr4(buffer_DW_Addr[4]),
	 	 .Waddr5(buffer_DW_Addr[5]),
	 	 .Waddr6(buffer_DW_Addr[6]),
	 	 .Waddr7(buffer_DW_Addr[7]),
	 	 .Raddr_valid0(control==2 && pp_input_word_valid[0]),
	 	 .Raddr_valid1(control==2 && pp_input_word_valid[1]),
	 	 .Raddr_valid2(control==2 && pp_input_word_valid[2]),
	 	 .Raddr_valid3(control==2 && pp_input_word_valid[3]),
	 	 .Raddr_valid4(control==2 && pp_input_word_valid[4]),
	 	 .Raddr_valid5(control==2 && pp_input_word_valid[5]),
	 	 .Raddr_valid6(control==2 && pp_input_word_valid[6]),
	 	 .Raddr_valid7(control==2 && pp_input_word_valid[7]),
	 	 .Waddr_valid0(buffer_DW_valid[0] && control==2),
	 	 .Waddr_valid1(buffer_DW_valid[1] && control==2),
	 	 .Waddr_valid2(buffer_DW_valid[2] && control==2),
	 	 .Waddr_valid3(buffer_DW_valid[3] && control==2),
	 	 .Waddr_valid4(buffer_DW_valid[4] && control==2),
	 	 .Waddr_valid5(buffer_DW_valid[5] && control==2),
	 	 .Waddr_valid6(buffer_DW_valid[6] && control==2),
	 	 .Waddr_valid7(buffer_DW_valid[7] && control==2),
	 	 .stall_signal(HDU_stall));

	 generate for(pp_num=0; pp_num <PIPE_NUM; pp_num = pp_num+1)
	 	 begin: elements pr_PP #(.PIPE_DEPTH(PIPE_DEPTH), .URAM_DATA_W(URAM_DATA_W), .PAR_SIZE_W(PAR_SIZE_W), .EDGE_W(EDGE_W)) pipeline (
	 	 	 .clk(clk),
	 	 	 .rst(rst),
	 	 	 .control(control),
	 	 	 .buffer_Din(buffer_DR[pp_num]),
	 	 	 .buffer_Din_valid(buffer_DR_valid[pp_num]),
	 	 	 .input_word(pp_input_word_reg[EDGE_W*pp_num+EDGE_W-1:EDGE_W*pp_num]),
	 	 	 .input_valid(pp_input_word_valid_reg[pp_num]),
	 	 	 .buffer_Dout(buffer_DW[pp_num]),
	 	 	 .buffer_Dout_Addr(buffer_DW_Addr[pp_num]),
	 	 	 .buffer_Dout_valid(buffer_DW_valid[pp_num]),
	 	 	 .output_word(pp_output_word[pp_num]),
	 	 	 .output_valid(pp_output_valid[pp_num]),
	 	 	 .par_active(par_active_wire[pp_num:pp_num]));
	 	 end
	 endgenerate

	 bufferx8 #(.DATA_W(URAM_DATA_W), .ADDR_W(PAR_SIZE_W), .Bank_Num_W(Bank_Num_W)) VBUFF(
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .R_Addr0(pp_input_word[EDGE_W*0+PAR_SIZE_W-1:EDGE_W*0]),
	 	 .R_Addr1(pp_input_word[EDGE_W*1+PAR_SIZE_W-1:EDGE_W*1]),
	 	 .R_Addr2(pp_input_word[EDGE_W*2+PAR_SIZE_W-1:EDGE_W*2]),
	 	 .R_Addr3(pp_input_word[EDGE_W*3+PAR_SIZE_W-1:EDGE_W*3]),
	 	 .R_Addr4(pp_input_word[EDGE_W*4+PAR_SIZE_W-1:EDGE_W*4]),
	 	 .R_Addr5(pp_input_word[EDGE_W*5+PAR_SIZE_W-1:EDGE_W*5]),
	 	 .R_Addr6(pp_input_word[EDGE_W*6+PAR_SIZE_W-1:EDGE_W*6]),
	 	 .R_Addr7(pp_input_word[EDGE_W*7+PAR_SIZE_W-1:EDGE_W*7]),
	 	 .W_Addr0(buffer_DW_Addr[0]),
	 	 .W_Addr1(buffer_DW_Addr[1]),
	 	 .W_Addr2(buffer_DW_Addr[2]),
	 	 .W_Addr3(buffer_DW_Addr[3]),
	 	 .W_Addr4(buffer_DW_Addr[4]),
	 	 .W_Addr5(buffer_DW_Addr[5]),
	 	 .W_Addr6(buffer_DW_Addr[6]),
	 	 .W_Addr7(buffer_DW_Addr[7]),
	 	 .W_Data0(buffer_DW[0]),
	 	 .W_Data1(buffer_DW[1]),
	 	 .W_Data2(buffer_DW[2]),
	 	 .W_Data3(buffer_DW[3]),
	 	 .W_Data4(buffer_DW[4]),
	 	 .W_Data5(buffer_DW[5]),
	 	 .W_Data6(buffer_DW[6]),
	 	 .W_Data7(buffer_DW[7]),
	 	 .R_valid0(pp_input_word_valid[0]),
	 	 .R_valid1(pp_input_word_valid[1]),
	 	 .R_valid2(pp_input_word_valid[2]),
	 	 .R_valid3(pp_input_word_valid[3]),
	 	 .R_valid4(pp_input_word_valid[4]),
	 	 .R_valid5(pp_input_word_valid[5]),
	 	 .R_valid6(pp_input_word_valid[6]),
	 	 .R_valid7(pp_input_word_valid[7]),
	 	 .W_valid0(buffer_DW_valid[0] && control==2),
	 	 .W_valid1(buffer_DW_valid[1] && control==2),
	 	 .W_valid2(buffer_DW_valid[2] && control==2),
	 	 .W_valid3(buffer_DW_valid[3] && control==2),
	 	 .W_valid4(buffer_DW_valid[4] && control==2),
	 	 .W_valid5(buffer_DW_valid[5] && control==2),
	 	 .W_valid6(buffer_DW_valid[6] && control==2),
	 	 .W_valid7(buffer_DW_valid[7] && control==2),
	 	 .R_out_valid0(buffer_DR_valid[0]),
	 	 .R_out_valid1(buffer_DR_valid[1]),
	 	 .R_out_valid2(buffer_DR_valid[2]),
	 	 .R_out_valid3(buffer_DR_valid[3]),
	 	 .R_out_valid4(buffer_DR_valid[4]),
	 	 .R_out_valid5(buffer_DR_valid[5]),
	 	 .R_out_valid6(buffer_DR_valid[6]),
	 	 .R_out_valid7(buffer_DR_valid[7]),
	 	 .R_Data0(buffer_DR[0]),
	 	 .R_Data1(buffer_DR[1]),
	 	 .R_Data2(buffer_DR[2]),
	 	 .R_Data3(buffer_DR[3]),
	 	 .R_Data4(buffer_DR[4]),
	 	 .R_Data5(buffer_DR[5]),
	 	 .R_Data6(buffer_DR[6]),
	 	. R_Data7(buffer_DR[7]));

	 combining_networkx8 #(.DATA_W(32),.PIPE_DEPTH(PIPE_DEPTH), .PAR_SIZE_W(PAR_SIZE_W), .PAR_NUM(PAR_NUM), .PAR_NUM_W(PAR_NUM_W)) CN (
	 	 .clk(clk),
	 	 .rst(rst),
	 	 .InputValid({pp_output_valid[7],pp_output_valid[6],pp_output_valid[5],pp_output_valid[4],pp_output_valid[3],pp_output_valid[2],pp_output_valid[1],pp_output_valid[0]}),
	 	 .InDestVid({pp_output_word[7][31:0],pp_output_word[6][31:0],pp_output_word[5][31:0],pp_output_word[4][31:0],pp_output_word[3][31:0],pp_output_word[2][31:0],pp_output_word[1][31:0],pp_output_word[0][31:0]}),
	 	 .InUpdate({pp_output_word[7][63:32],pp_output_word[6][63:32],pp_output_word[5][63:32],pp_output_word[4][63:32],pp_output_word[3][63:32],pp_output_word[2][63:32],pp_output_word[1][63:32],pp_output_word[0][63:32]}),
	 	 .DRAM_W(DRAM_W),
	 	 .DRAM_W_valid(DRAM_W_valid),
	 	 .stall_request(se_request));

endmodule

module hdux8 # (
	parameter ADDR_W = 16,
	parameter Bank_Num_W = 5
)(
	input   wire clk,
	input   wire rst,
	input   wire [ADDR_W-1:0] Raddr0,
	input   wire [ADDR_W-1:0] Raddr1,
	input   wire [ADDR_W-1:0] Raddr2,
	input   wire [ADDR_W-1:0] Raddr3,
	input   wire [ADDR_W-1:0] Raddr4,
	input   wire [ADDR_W-1:0] Raddr5,
	input   wire [ADDR_W-1:0] Raddr6,
	input   wire [ADDR_W-1:0] Raddr7,
	input   wire [ADDR_W-1:0] Waddr0,
	input   wire [ADDR_W-1:0] Waddr1,
	input   wire [ADDR_W-1:0] Waddr2,
	input   wire [ADDR_W-1:0] Waddr3,
	input   wire [ADDR_W-1:0] Waddr4,
	input   wire [ADDR_W-1:0] Waddr5,
	input   wire [ADDR_W-1:0] Waddr6,
	input   wire [ADDR_W-1:0] Waddr7,
	input   wire Raddr_valid0,
	input   wire Raddr_valid1,
	input   wire Raddr_valid2,
	input   wire Raddr_valid3,	
	input   wire Raddr_valid4,
	input   wire Raddr_valid5,
	input   wire Raddr_valid6,
	input   wire Raddr_valid7,	  
	input   wire Waddr_valid0,
	input   wire Waddr_valid1,
	input   wire Waddr_valid2,
	input   wire Waddr_valid3,	  
	input   wire Waddr_valid4,
	input   wire Waddr_valid5,
	input   wire Waddr_valid6,
	input   wire Waddr_valid7,
	output	wire stall_signal
);
    
localparam Bank_Num = (2**Bank_Num_W);
localparam Port_Num = 8;

wire flag_valid0;
wire flag_valid1;
wire flag_valid2;
wire flag_valid3;
wire flag_valid4;
wire flag_valid5;
wire flag_valid6;
wire flag_valid7;
wire flag0;
wire flag1;
wire flag2;
wire flag3;
wire flag4;
wire flag5;
wire flag6;
wire flag7;
	
wire [ADDR_W-Bank_Num_W-1:0] bank_raddr [Bank_Num-1:0];
wire [ADDR_W-Bank_Num_W-1:0] bank_waddr [Bank_Num-1:0];
wire [0:0] bank_rvalid [Bank_Num-1:0];
wire [0:0] bank_wvalid [Bank_Num-1:0];
wire [0:0] bank_fvalid [Bank_Num-1:0];
wire [0:0] bank_flag   [Bank_Num-1:0];

reg	 [Bank_Num_W-1:0] sel	[Port_Num-1:0];
reg	 [ADDR_W:0]		lock [Port_Num-1:0];
reg	 [ADDR_W-1:0]	Raddr_reg [Port_Num-1:0];
reg	 [0:0]	Raddr_valid_reg [Port_Num-1:0];

genvar numbank; 
generate for(numbank=0; numbank < Bank_Num; numbank = numbank+1) 
	begin: elements	
		hdu_unit # (.ADDR_W(ADDR_W-Bank_Num_W))	hdu_bank (
			.clk(clk),
			.rst(rst),
			.Raddr(bank_raddr[numbank]),
			.Waddr(bank_waddr[numbank]),
			.Raddr_valid(bank_rvalid[numbank]),
			.Waddr_valid(bank_wvalid[numbank]),
			.flag_valid(bank_fvalid[numbank]),
			.flag(bank_flag[numbank])
		);
	end
endgenerate 

	
genvar i;
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: read_addr assign bank_raddr[i] = (Raddr_valid0 && Raddr0[Bank_Num_W-1:0] == i) ? Raddr0[ADDR_W-1: Bank_Num_W] :
							(Raddr_valid1 && Raddr1[Bank_Num_W-1:0] == i) ? Raddr1[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid2 && Raddr2[Bank_Num_W-1:0] == i) ? Raddr2[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid3 && Raddr3[Bank_Num_W-1:0] == i) ? Raddr3[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid4 && Raddr4[Bank_Num_W-1:0] == i) ? Raddr4[ADDR_W-1: Bank_Num_W] :
							(Raddr_valid5 && Raddr5[Bank_Num_W-1:0] == i) ? Raddr5[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid6 && Raddr6[Bank_Num_W-1:0] == i) ? Raddr6[ADDR_W-1: Bank_Num_W] :	
							(Raddr_valid7 && Raddr7[Bank_Num_W-1:0] == i) ? Raddr7[ADDR_W-1: Bank_Num_W] : {(ADDR_W-Bank_Num_W){1'b0}};	  
   end 
endgenerate
	
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_addr assign bank_waddr[i] = (Waddr_valid0 && Waddr0[Bank_Num_W-1:0] == i) ? Waddr0[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid1 && Waddr1[Bank_Num_W-1:0] == i) ? Waddr1[ADDR_W-1: Bank_Num_W] :	
							(Waddr_valid2 && Waddr2[Bank_Num_W-1:0] == i) ? Waddr2[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid3 && Waddr3[Bank_Num_W-1:0] == i) ? Waddr3[ADDR_W-1: Bank_Num_W] :	
							(Waddr_valid4 && Waddr4[Bank_Num_W-1:0] == i) ? Waddr4[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid5 && Waddr5[Bank_Num_W-1:0] == i) ? Waddr5[ADDR_W-1: Bank_Num_W] :	
							(Waddr_valid6 && Waddr6[Bank_Num_W-1:0] == i) ? Waddr6[ADDR_W-1: Bank_Num_W] :
							(Waddr_valid7 && Waddr7[Bank_Num_W-1:0] == i) ? Waddr7[ADDR_W-1: Bank_Num_W] : {(ADDR_W-Bank_Num_W){1'b0}};	
   end 
endgenerate
																			
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: read_valid assign bank_rvalid[i] = (Raddr_valid0 && Raddr0[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Raddr_valid1 && Raddr1[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid2 && Raddr2[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid3 && Raddr3[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid4 && Raddr4[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Raddr_valid5 && Raddr5[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid6 && Raddr6[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Raddr_valid7 && Raddr7[Bank_Num_W-1:0] == i) ? 1'b1 : 1'b0;
   end 
endgenerate
							
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_valid assign bank_wvalid[i] = (Waddr_valid0 && Waddr0[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid1 && Waddr1[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Waddr_valid2 && Waddr2[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid3 && Waddr3[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Waddr_valid4 && Waddr4[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid5 && Waddr5[Bank_Num_W-1:0] == i) ? 1'b1 : 
							(Waddr_valid6 && Waddr6[Bank_Num_W-1:0] == i) ? 1'b1 :
							(Waddr_valid7 && Waddr7[Bank_Num_W-1:0] == i) ? 1'b1 : 1'b0;
   end 
endgenerate

wire stall;	
//assign stall = (lock[0]<{(ADDR_W+1){1'b1}}) || (lock[1]<{(ADDR_W+1){1'b1}}) || (lock[2]<{(ADDR_W+1){1'b1}}) || (lock[3]<{(ADDR_W+1){1'b1}}) || (lock[4]<{(ADDR_W+1){1'b1}}) || (lock[5]<{(ADDR_W+1){1'b1}}) || (lock[6]<{(ADDR_W+1){1'b1}}) || (lock[7]<{(ADDR_W+1){1'b1}}) || (flag_valid0 && flag0) || (flag_valid1 && flag1) || (flag_valid2 && flag2) || (flag_valid3 && flag3) || (flag_valid4 && flag4) || (flag_valid5 && flag5) || (flag_valid6 && flag6) || (flag_valid7 && flag7) ;

assign stall = (lock[0]<{(ADDR_W+1){1'b1}}) || (lock[1]<{(ADDR_W+1){1'b1}}) || (lock[2]<{(ADDR_W+1){1'b1}}) || (lock[3]<{(ADDR_W+1){1'b1}}) || (lock[4]<{(ADDR_W+1){1'b1}}) || (lock[5]<{(ADDR_W+1){1'b1}}) || (lock[6]<{(ADDR_W+1){1'b1}}) || (lock[7]<{(ADDR_W+1){1'b1}});
assign stall_signal = stall;
	
always @(posedge clk) begin
	if(rst) begin
		lock[0] <= {(ADDR_W+1){1'b1}};
		lock[1] <= {(ADDR_W+1){1'b1}};    
		lock[2] <= {(ADDR_W+1){1'b1}};
		lock[3] <= {(ADDR_W+1){1'b1}};
		lock[4] <= {(ADDR_W+1){1'b1}};
		lock[5] <= {(ADDR_W+1){1'b1}};    
		lock[6] <= {(ADDR_W+1){1'b1}};
		lock[7] <= {(ADDR_W+1){1'b1}};			
	end else begin
		if(stall_signal) begin
			if((lock[0] == {1'b0, Waddr0} && Waddr_valid0) || (lock[0] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[0] == {1'b0, Waddr2} && Waddr_valid2) || (lock[0] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[0] == {1'b0, Waddr4} && Waddr_valid4) || (lock[0] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[0] == {1'b0, Waddr6} && Waddr_valid6) || (lock[0] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[0] <= {(ADDR_W+1){1'b1}};
			end  
			if((lock[1] == {1'b0, Waddr0} && Waddr_valid0) || (lock[1] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[1] == {1'b0, Waddr2} && Waddr_valid2) || (lock[1] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[1] == {1'b0, Waddr4} && Waddr_valid4) || (lock[1] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[1] == {1'b0, Waddr6} && Waddr_valid6) || (lock[1] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[1] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[2] == {1'b0, Waddr0} && Waddr_valid0) || (lock[2] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[2] == {1'b0, Waddr2} && Waddr_valid2) || (lock[2] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[2] == {1'b0, Waddr4} && Waddr_valid4) || (lock[2] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[2] == {1'b0, Waddr6} && Waddr_valid6) || (lock[2] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[2] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[3] == {1'b0, Waddr0} && Waddr_valid0) || (lock[3] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[3] == {1'b0, Waddr2} && Waddr_valid2) || (lock[3] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[3] == {1'b0, Waddr4} && Waddr_valid4) || (lock[3] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[3] == {1'b0, Waddr6} && Waddr_valid6) || (lock[3] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[3] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[4] == {1'b0, Waddr0} && Waddr_valid0) || (lock[4] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[4] == {1'b0, Waddr2} && Waddr_valid2) || (lock[4] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[4] == {1'b0, Waddr4} && Waddr_valid4) || (lock[4] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[4] == {1'b0, Waddr6} && Waddr_valid6) || (lock[4] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[4] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[5] == {1'b0, Waddr0} && Waddr_valid0) || (lock[5] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[5] == {1'b0, Waddr2} && Waddr_valid2) || (lock[5] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[5] == {1'b0, Waddr4} && Waddr_valid4) || (lock[5] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[5] == {1'b0, Waddr6} && Waddr_valid6) || (lock[5] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[5] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[6] == {1'b0, Waddr0} && Waddr_valid0) || (lock[6] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[6] == {1'b0, Waddr2} && Waddr_valid2) || (lock[6] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[6] == {1'b0, Waddr4} && Waddr_valid4) || (lock[6] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[6] == {1'b0, Waddr6} && Waddr_valid6) || (lock[6] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[6] <= {(ADDR_W+1){1'b1}};
			end
			if((lock[7] == {1'b0, Waddr0} && Waddr_valid0) || (lock[7] == {1'b0, Waddr1} && Waddr_valid1) || 
			   (lock[7] == {1'b0, Waddr2} && Waddr_valid2) || (lock[7] == {1'b0, Waddr3} && Waddr_valid3) ||
			   (lock[7] == {1'b0, Waddr4} && Waddr_valid4) || (lock[7] == {1'b0, Waddr5} && Waddr_valid5) || 
			   (lock[7] == {1'b0, Waddr6} && Waddr_valid6) || (lock[7] == {1'b0, Waddr7} && Waddr_valid7)) begin
				lock[7] <= {(ADDR_W+1){1'b1}};
			end
		end else begin
			if(Raddr_reg [0] && Raddr_valid_reg [0] && flag_valid0 && flag0) begin lock[0] <= {1'b0, Raddr_reg [0]}; end
			if(Raddr_reg [1] && Raddr_valid_reg [1] && flag_valid1 && flag1) begin lock[1] <= {1'b0, Raddr_reg [1]}; end
			if(Raddr_reg [2] && Raddr_valid_reg [2] && flag_valid2 && flag2) begin lock[2] <= {1'b0, Raddr_reg [2]}; end
			if(Raddr_reg [3] && Raddr_valid_reg [3] && flag_valid3 && flag3) begin lock[3] <= {1'b0, Raddr_reg [3]}; end
			if(Raddr_reg [4] && Raddr_valid_reg [4] && flag_valid4 && flag4) begin lock[4] <= {1'b0, Raddr_reg [4]}; end
			if(Raddr_reg [5] && Raddr_valid_reg [5] && flag_valid5 && flag5) begin lock[5] <= {1'b0, Raddr_reg [5]}; end
			if(Raddr_reg [6] && Raddr_valid_reg [6] && flag_valid6 && flag6) begin lock[6] <= {1'b0, Raddr_reg [6]}; end
			if(Raddr_reg [7] && Raddr_valid_reg [7] && flag_valid7 && flag7) begin lock[7] <= {1'b0, Raddr_reg [7]}; end
		end
	end
end
							
always @(posedge clk) begin
	if(rst) begin
		sel[0] <=0;
		sel[1] <=1;    
		sel[2] <=2;
		sel[3] <=3;
		sel[4] <=4;
		sel[5] <=5;    
		sel[6] <=6;
		sel[7] <=7;	
		Raddr_reg [0] <= {(ADDR_W){1'b0}};
		Raddr_reg [1] <= {(ADDR_W){1'b0}};
		Raddr_reg [2] <= {(ADDR_W){1'b0}};
		Raddr_reg [3] <= {(ADDR_W){1'b0}};
		Raddr_reg [4] <= {(ADDR_W){1'b0}};
		Raddr_reg [5] <= {(ADDR_W){1'b0}};
		Raddr_reg [6] <= {(ADDR_W){1'b0}};
		Raddr_reg [7] <= {(ADDR_W){1'b0}};
		Raddr_valid_reg [0] <= 1'b0;
		Raddr_valid_reg [1] <= 1'b0;
		Raddr_valid_reg [2] <= 1'b0;
		Raddr_valid_reg [3] <= 1'b0;
		Raddr_valid_reg [4] <= 1'b0;
		Raddr_valid_reg [5] <= 1'b0;
		Raddr_valid_reg [6] <= 1'b0;
		Raddr_valid_reg [7] <= 1'b0;
	end else begin
		if(~stall) begin
			sel[0] <= Raddr0[Bank_Num_W-1:0];			
			sel[1] <= Raddr1[Bank_Num_W-1:0];			  
			sel[2] <= Raddr2[Bank_Num_W-1:0];			
			sel[3] <= Raddr3[Bank_Num_W-1:0];			  
			sel[4] <= Raddr4[Bank_Num_W-1:0];			
			sel[5] <= Raddr5[Bank_Num_W-1:0];			  
			sel[6] <= Raddr6[Bank_Num_W-1:0];			
			sel[7] <= Raddr7[Bank_Num_W-1:0];
			Raddr_reg [0] <= Raddr0;
			Raddr_reg [1] <= Raddr1;
			Raddr_reg [2] <= Raddr2;
			Raddr_reg [3] <= Raddr3;
			Raddr_reg [4] <= Raddr4;
			Raddr_reg [5] <= Raddr5;
			Raddr_reg [6] <= Raddr6;
			Raddr_reg [7] <= Raddr7;
			Raddr_valid_reg [0] <= Raddr_valid0;
			Raddr_valid_reg [1] <= Raddr_valid1;
			Raddr_valid_reg [2] <= Raddr_valid2;
			Raddr_valid_reg [3] <= Raddr_valid3;
			Raddr_valid_reg [4] <= Raddr_valid4;
			Raddr_valid_reg [5] <= Raddr_valid5;
			Raddr_valid_reg [6] <= Raddr_valid6;
			Raddr_valid_reg [7] <= Raddr_valid7;	
		end else begin
			sel[0] <= sel[0];			
			sel[1] <= sel[1];			  
			sel[2] <= sel[2];			
			sel[3] <= sel[3];			  
			sel[4] <= sel[4];			
			sel[5] <= sel[5];			  
			sel[6] <= sel[6];			
			sel[7] <= sel[7];
			Raddr_reg [0] <= Raddr_reg [0];
			Raddr_reg [1] <= Raddr_reg [1];
			Raddr_reg [2] <= Raddr_reg [2];
			Raddr_reg [3] <= Raddr_reg [3];
			Raddr_reg [4] <= Raddr_reg [4];
			Raddr_reg [5] <= Raddr_reg [5];
			Raddr_reg [6] <= Raddr_reg [6];
			Raddr_reg [7] <= Raddr_reg [7];
			Raddr_valid_reg [0] <= Raddr_valid_reg [0];
			Raddr_valid_reg [1] <= Raddr_valid_reg [1];
			Raddr_valid_reg [2] <= Raddr_valid_reg [2];
			Raddr_valid_reg [3] <= Raddr_valid_reg [3];
			Raddr_valid_reg [4] <= Raddr_valid_reg [4];
			Raddr_valid_reg [5] <= Raddr_valid_reg [5];
			Raddr_valid_reg [6] <= Raddr_valid_reg [6];
			Raddr_valid_reg [7] <= Raddr_valid_reg [7];
		end
	end
end

assign flag_valid0 = bank_fvalid[sel[0]];
assign flag_valid1 = bank_fvalid[sel[1]];
assign flag_valid2 = bank_fvalid[sel[2]];
assign flag_valid3 = bank_fvalid[sel[3]];
assign flag_valid4 = bank_fvalid[sel[4]];
assign flag_valid5 = bank_fvalid[sel[5]];
assign flag_valid6 = bank_fvalid[sel[6]];
assign flag_valid7 = bank_fvalid[sel[7]];	
assign flag0 = bank_flag[sel[0]];
assign flag1 = bank_flag[sel[1]];
assign flag2 = bank_flag[sel[2]];
assign flag3 = bank_flag[sel[3]];	
assign flag4 = bank_flag[sel[4]];
assign flag5 = bank_flag[sel[5]];
assign flag6 = bank_flag[sel[6]];
assign flag7 = bank_flag[sel[7]];

endmodule

module combining_networkx8 # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 8,
	parameter PAR_SIZE_W = 17,
    parameter PAR_NUM   = 16,
    parameter PAR_NUM_W = 4
)(
	input wire          			clk,
    input wire          			rst,    
    input wire  [7:0]         		InputValid,
	input wire  [DATA_W*8-1:0]   	InDestVid,    
    input wire  [DATA_W*8-1:0]   	InUpdate,    
    output reg [511:0]              DRAM_W,
    output reg                      DRAM_W_valid,
    output wire                     stall_request
);

wire [DATA_W*8-1:0] OutUpdate [2:0];
wire [DATA_W*8-1:0] OutDestVid [2:0];
wire [8-1:0] OutValid [4:0];
wire [DATA_W*2*8-1:0] Ubuff_out [1:0];
wire [63:0]	  se_output_word;
wire         se_output_valid;
    
CNx8 #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
CNstage0 (
	.clk(clk),
    .rst(rst),    
    .InputValid(InputValid),
	.InDestVid(InDestVid),    
    .InUpdate(InUpdate),    
    .OutUpdate(OutUpdate[0]),
    .OutDestVid(OutDestVid[0]),
	.OutValid(OutValid[0])
);

Ubuffx8
Ubuff0 (
    .clk(clk),
    .rst(rst),    
    .last_input_in(1'b0),
    .word_in({OutUpdate[0][DATA_W*8-1:DATA_W*7],OutDestVid[0][DATA_W*8-1:DATA_W*7],OutUpdate[0][DATA_W*7-1:DATA_W*6],OutDestVid[0][DATA_W*7-1:DATA_W*6],
              OutUpdate[0][DATA_W*6-1:DATA_W*5],OutDestVid[0][DATA_W*6-1:DATA_W*5],OutUpdate[0][DATA_W*5-1:DATA_W*4],OutDestVid[0][DATA_W*5-1:DATA_W*4],
              OutUpdate[0][DATA_W*4-1:DATA_W*3],OutDestVid[0][DATA_W*4-1:DATA_W*3],OutUpdate[0][DATA_W*3-1:DATA_W*2],OutDestVid[0][DATA_W*3-1:DATA_W*2],
              OutUpdate[0][DATA_W*2-1:DATA_W*1],OutDestVid[0][DATA_W*2-1:DATA_W*1],OutUpdate[0][DATA_W*1-1:DATA_W*0],OutDestVid[0][DATA_W*1-1:DATA_W*0]}),
	.word_in_valid(OutValid[0]),
    //input wire [1:0] control,        
    .word_out(Ubuff_out[0]), 
    .valid_out(OutValid[1])
);

CNx8 #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
CNstage1 (
	.clk(clk),
    .rst(rst),    
    .InputValid(OutValid[1]),
	.InDestVid({Ubuff_out[0][DATA_W*15-1:DATA_W*14],Ubuff_out[0][DATA_W*13-1:DATA_W*12],Ubuff_out[0][DATA_W*11-1:DATA_W*10],Ubuff_out[0][DATA_W*9-1:DATA_W*8],Ubuff_out[0][DATA_W*7-1:DATA_W*6],Ubuff_out[0][DATA_W*5-1:DATA_W*4],Ubuff_out[0][DATA_W*3-1:DATA_W*2],Ubuff_out[0][DATA_W*1-1:DATA_W*0]}),    
    .InUpdate({Ubuff_out[0][DATA_W*16-1:DATA_W*15],Ubuff_out[0][DATA_W*14-1:DATA_W*13],Ubuff_out[0][DATA_W*12-1:DATA_W*11],Ubuff_out[0][DATA_W*10-1:DATA_W*9],Ubuff_out[0][DATA_W*8-1:DATA_W*7],Ubuff_out[0][DATA_W*6-1:DATA_W*5],Ubuff_out[0][DATA_W*4-1:DATA_W*3],Ubuff_out[0][DATA_W*2-1:DATA_W*1]}),       
    .OutUpdate(OutUpdate[1]),
    .OutDestVid(OutDestVid[1]),
	.OutValid(OutValid[2])
);

Ubuffx8
Ubuff1 (
    .clk(clk),
    .rst(rst),    
    .last_input_in(1'b0),
    .word_in({OutUpdate[1][DATA_W*8-1:DATA_W*7],OutDestVid[1][DATA_W*8-1:DATA_W*7],OutUpdate[1][DATA_W*7-1:DATA_W*6],OutDestVid[1][DATA_W*7-1:DATA_W*6],
              OutUpdate[1][DATA_W*6-1:DATA_W*5],OutDestVid[1][DATA_W*6-1:DATA_W*5],OutUpdate[1][DATA_W*5-1:DATA_W*4],OutDestVid[1][DATA_W*5-1:DATA_W*4],
              OutUpdate[1][DATA_W*4-1:DATA_W*3],OutDestVid[1][DATA_W*4-1:DATA_W*3],OutUpdate[1][DATA_W*3-1:DATA_W*2],OutDestVid[1][DATA_W*3-1:DATA_W*2],
              OutUpdate[1][DATA_W*2-1:DATA_W*1],OutDestVid[1][DATA_W*2-1:DATA_W*1],OutUpdate[1][DATA_W*1-1:DATA_W*0],OutDestVid[1][DATA_W*1-1:DATA_W*0]}),
	.word_in_valid(OutValid[2]),
    //input wire [1:0] control,        
    .word_out(Ubuff_out[1]), 
    .valid_out(OutValid[3])
);


CNx8 #(.DATA_W(DATA_W), .PIPE_DEPTH(PIPE_DEPTH))
CNstage2 (
	.clk(clk),
    .rst(rst),    
    .InputValid(OutValid[3]),
	.InDestVid({Ubuff_out[1][DATA_W*15-1:DATA_W*14],Ubuff_out[1][DATA_W*13-1:DATA_W*12],Ubuff_out[1][DATA_W*11-1:DATA_W*10],Ubuff_out[1][DATA_W*9-1:DATA_W*8],Ubuff_out[1][DATA_W*7-1:DATA_W*6],Ubuff_out[1][DATA_W*5-1:DATA_W*4],Ubuff_out[1][DATA_W*3-1:DATA_W*2],Ubuff_out[1][DATA_W*1-1:DATA_W*0]}),    
    .InUpdate({Ubuff_out[1][DATA_W*16-1:DATA_W*15],Ubuff_out[1][DATA_W*14-1:DATA_W*13],Ubuff_out[1][DATA_W*12-1:DATA_W*11],Ubuff_out[1][DATA_W*10-1:DATA_W*9],Ubuff_out[1][DATA_W*8-1:DATA_W*7],Ubuff_out[1][DATA_W*6-1:DATA_W*5],Ubuff_out[1][DATA_W*4-1:DATA_W*3],Ubuff_out[1][DATA_W*2-1:DATA_W*1]}),       
    .OutUpdate(OutUpdate[2]),
    .OutDestVid(OutDestVid[2]),
	.OutValid(OutValid[4])
);

seout output_update(
	.clk(clk),
	.rst(rst),
	.input_update0({OutUpdate[2][DATA_W*8-1:DATA_W*7], OutDestVid[2][DATA_W*8-1:DATA_W*7]}),
	.input_update1({OutUpdate[2][DATA_W*7-1:DATA_W*6], OutDestVid[2][DATA_W*7-1:DATA_W*6]}),
	.input_update2({OutUpdate[2][DATA_W*6-1:DATA_W*5], OutDestVid[2][DATA_W*6-1:DATA_W*5]}),
	.input_update3({OutUpdate[2][DATA_W*5-1:DATA_W*4], OutDestVid[2][DATA_W*5-1:DATA_W*4]}),
	.input_update4({OutUpdate[2][DATA_W*4-1:DATA_W*3], OutDestVid[2][DATA_W*4-1:DATA_W*3]}),
	.input_update5({OutUpdate[2][DATA_W*3-1:DATA_W*2], OutDestVid[2][DATA_W*3-1:DATA_W*2]}),
	.input_update6({OutUpdate[2][DATA_W*2-1:DATA_W*1], OutDestVid[2][DATA_W*2-1:DATA_W*1]}),
	.input_update7({OutUpdate[2][DATA_W*1-1:DATA_W*0], OutDestVid[2][DATA_W*1-1:DATA_W*0]}),
	.input_valid0(OutValid[4][7:7]),
	.input_valid1(OutValid[4][6:6]),
	.input_valid2(OutValid[4][5:5]),
	.input_valid3(OutValid[4][4:4]),
	.input_valid4(OutValid[4][3:3]),
	.input_valid5(OutValid[4][2:2]),
	.input_valid6(OutValid[4][1:1]),
	.input_valid7(OutValid[4][0:0]),	
	.output_word(se_output_word),
	.output_valid(se_output_valid),
	.se_stall_request(stall_request)
);

reg [511:0]  	Ubuff         			[PAR_NUM-1:0];
reg [2:0]   	Ubuff_size            	[PAR_NUM-1:0];

integer i;
wire [PAR_NUM_W-1:0] input_update_bin_id;
//reg [31:0]  par_bin_addr            [PAR_NUM-1:0];


assign input_update_bin_id = se_output_word[PAR_SIZE_W+PAR_NUM_W-1:PAR_SIZE_W];

always @(posedge clk) begin
    if(rst) begin        
        for(i=0; i<PAR_NUM; i=i+1) begin
            Ubuff[i] 		 <= 0;
            Ubuff_size [i] 	 <= 0;
        end
        DRAM_W <= 0;
        DRAM_W_valid <= 0;	
    end else begin 	
        DRAM_W_valid <= 0;
        DRAM_W <= 0;
        if(se_output_valid) begin
            if(Ubuff_size[input_update_bin_id] == 7) begin
                DRAM_W <= {Ubuff[input_update_bin_id][447:0], se_output_word};
                DRAM_W_valid <= 1'b1;
                Ubuff[input_update_bin_id] <= 0;
                Ubuff_size[input_update_bin_id] <= 0;
            end else begin
                Ubuff[input_update_bin_id] <= (Ubuff[input_update_bin_id]<<64)+se_output_word;
                Ubuff_size[input_update_bin_id] <= Ubuff_size[input_update_bin_id]+1;				
            end
        end							
    end
end

endmodule

module seout (
	input wire clk,
	input wire rst,
	input wire [63:0]	input_update0,
	input wire [63:0]	input_update1,
	input wire [63:0]	input_update2,
	input wire [63:0]	input_update3,
	input wire [63:0]	input_update4,
	input wire [63:0]	input_update5,
	input wire [63:0]	input_update6,
	input wire [63:0]	input_update7,	
	input wire input_valid0,
	input wire input_valid1,
	input wire input_valid2,
	input wire input_valid3,
	input wire input_valid4,
	input wire input_valid5,
	input wire input_valid6,
	input wire input_valid7,
	output reg	[63:0]	output_word,
	output reg	output_valid,
	output reg 	se_stall_request
);

	reg [63:0] 	update_buff 		[7:0];
	reg [0:0] 	update_valid_buff 	[7:0];
	
	always @(posedge clk) begin
        if (rst) begin
			update_buff[0] <= 0;
			update_buff[1] <= 0;
			update_buff[2] <= 0;
			update_buff[3] <= 0;
			update_buff[4] <= 0;
			update_buff[5] <= 0;
			update_buff[6] <= 0;
			update_buff[7] <= 0;
			update_valid_buff[0] <= 0;
			update_valid_buff[1] <= 0;
			update_valid_buff[2] <= 0;
			update_valid_buff[3] <= 0;
			update_valid_buff[4] <= 0;
			update_valid_buff[5] <= 0;
			update_valid_buff[6] <= 0;
			update_valid_buff[7] <= 0;
        end	else begin			
			update_buff[0] <= input_update0;
			update_buff[1] <= input_update1;
			update_buff[2] <= input_update2;
			update_buff[3] <= input_update3;
			update_buff[4] <= input_update4;
			update_buff[5] <= input_update5;
			update_buff[6] <= input_update6;
			update_buff[7] <= input_update7;
			update_valid_buff[0] <= input_valid0;
			update_valid_buff[1] <= input_valid1;
			update_valid_buff[2] <= input_valid2;
			update_valid_buff[3] <= input_valid3;
			update_valid_buff[4] <= input_valid4;
			update_valid_buff[5] <= input_valid5;
			update_valid_buff[6] <= input_valid6;
			update_valid_buff[7] <= input_valid7;			
			output_word <= update_buff[0];
            case({update_valid_buff[0], update_valid_buff[1], update_valid_buff[2], update_valid_buff[3], update_valid_buff[4], update_valid_buff[5], update_valid_buff[6], update_valid_buff[7]}) 
				8'b00000000: begin					
					output_valid <= 0;					
					se_stall_request <= 0;
				end
				8'b10000000: begin					
					output_valid <= 1;
					se_stall_request <= 0;
				end
				default:begin					
					output_valid <= 1;
					update_buff[0] <= update_buff[1];
					update_valid_buff[0] <= update_valid_buff[1];
					update_buff[1] <= update_buff[2];
					update_valid_buff[1] <= update_valid_buff[2];
					update_buff[2] <= update_buff[3];
					update_valid_buff[2] <= update_valid_buff[3];
					update_buff[3] <= update_buff[4];
					update_valid_buff[3] <= update_valid_buff[4];
					update_buff[4] <= update_buff[5];
					update_valid_buff[4] <= update_valid_buff[5];
					update_buff[5] <= update_buff[6];
					update_valid_buff[5] <= update_valid_buff[6];
					update_buff[6] <= update_buff[7];
					update_valid_buff[6] <= update_valid_buff[7];
					update_valid_buff[7] <= 0;
					se_stall_request <= 1;
				end
			endcase
        end
    end	
endmodule

module CNx8 # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 8
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

module CNx4 # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 8
)(
	input wire          			clk,
    input wire          			rst,    
    input wire  [3:0]         		InputValid,
	input wire  [DATA_W*4-1:0]   	InDestVid,    
    input wire  [DATA_W*4-1:0]   	InUpdate,    
    output wire [DATA_W*4-1:0]   	OutUpdate,
    output wire [DATA_W*4-1:0]  	OutDestVid,
	output wire [3:0]  				OutValid
);

wire [7:0]  			Valid_wire  	[1:0];
wire [DATA_W*8-1:0] 	Update_wire 	[1:0];
wire [DATA_W*8-1:0] 	DestVid_wire 	[1:0];
    
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
	.OutUpdate_A(OutUpdate[DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(OutUpdate[DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_A(OutDestVid[DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(OutDestVid[DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutValid_A(OutValid[0:0]),
	.OutValid_B(OutValid[1:1])
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
	.OutUpdate_A(OutUpdate[DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutUpdate_B(OutUpdate[DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutDestVid_A(OutDestVid[DATA_W*2+DATA_W-1:DATA_W*2]),
	.OutDestVid_B(OutDestVid[DATA_W*3+DATA_W-1:DATA_W*3]),
	.OutValid_A(OutValid[2:2]),
	.OutValid_B(OutValid[3:3])
);

endmodule

module CNx2 # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 8
)(
	input wire          			clk,
    input wire          			rst,    
    input wire  [1:0]         		InputValid,
	input wire  [DATA_W*2-1:0]   	InDestVid,    
    input wire  [DATA_W*2-1:0]   	InUpdate,    
    output wire [DATA_W*2-1:0]   	OutUpdate,
    output wire [DATA_W*2-1:0]  	OutDestVid,
	output wire [1:0]  				OutValid
);

 
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
	.OutUpdate_A(OutUpdate[DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutUpdate_B(OutUpdate[DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutDestVid_A(OutDestVid[DATA_W*0+DATA_W-1:DATA_W*0]),
	.OutDestVid_B(OutDestVid[DATA_W*1+DATA_W-1:DATA_W*1]),
	.OutValid_A(OutValid[0:0]),
	.OutValid_B(OutValid[1:1])
);

endmodule


module CaC # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 8
)(
	input wire          		clk,
    input wire          		rst,    
    input wire  [0:0]         	InputValid_A,
    input wire  [0:0]         	InputValid_B,
	input wire  [DATA_W-1:0]   	InDestVid_A,
    input wire  [DATA_W-1:0]   	InDestVid_B,
    input wire  [DATA_W-1:0]   	InUpdate_A,
    input wire  [DATA_W-1:0]   	InUpdate_B,
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
    .combined_update (result)
);  

assign OutDestVid_A = 	DestVid_reg_A[PIPE_DEPTH-1];
assign OutDestVid_B = 	DestVid_reg_A[PIPE_DEPTH-1];
assign OutValid_A	= 	Valid_reg_A[PIPE_DEPTH-1];
assign OutValid_B 	= 	(Valid_reg_A[PIPE_DEPTH-1] & Valid_reg_B[PIPE_DEPTH-1] & (DestVid_reg_A[PIPE_DEPTH-1]==DestVid_reg_B[PIPE_DEPTH-1])) ? 1'b0 : Valid_reg_B[PIPE_DEPTH-1];
assign OutUpdate_A 	= 	(Valid_reg_A[PIPE_DEPTH-1] & Valid_reg_B[PIPE_DEPTH-1] & (DestVid_reg_A[PIPE_DEPTH-1]==DestVid_reg_B[PIPE_DEPTH-1])) ? result : Update_reg_A [PIPE_DEPTH-1];
assign OutUpdate_B 	= 	(Valid_reg_A[PIPE_DEPTH-1] & Valid_reg_B[PIPE_DEPTH-1] & (DestVid_reg_A[PIPE_DEPTH-1]==DestVid_reg_B[PIPE_DEPTH-1])) ? 0 : Update_reg_B [PIPE_DEPTH-1];
	
endmodule

module scheduler # (
    parameter PAR_NUM   = 32,
    parameter PAR_NUM_W = 5
)(
	input wire                      clk,
	input wire                      rst,
	input wire [1:0]                control,
	input wire                      par_complete_sig,
	input wire						par_active,    
	output reg [31:0]               Raddr,
	output reg [31:0]               work_size,
	output reg                      new_par_start,
	output reg						new_par_active,
	output reg                      PE_DONE  
);

reg [31:0]	par_shard_addr		[PAR_NUM-1:0];
reg [31:0]	par_bin_addr			[PAR_NUM-1:0];
reg [31:0]	par_shard_size		[PAR_NUM-1:0];
reg [31:0]	par_bin_size			[PAR_NUM-1:0];
reg [0:0]		par_active_state	[PAR_NUM-1:0];

reg [PAR_NUM_W-1:0] next_par_id;
reg [0:0] state_switch;
integer i;

localparam  IDLE=0, SCATTER=1, GATHER=2;
reg [1:0]   CURRENT_STATE;
                             
always @(posedge clk) begin
	if(rst) begin        
        CURRENT_STATE <= IDLE;
        next_par_id <= 1'b0;
        PE_DONE <= 1'b0;
        state_switch <= 1'b0;
				new_par_start <= 1'b0;
        for(i=0; i<PAR_NUM; i=i+1) begin                         
            par_shard_size [i] 	<= 32*1024*1024;
            par_shard_addr [i] 	<= PAR_NUM*4*1024*8 + i*32*1024*1024;              
            par_bin_addr   [i] 	<= PAR_NUM*4*1024*8 + (PAR_NUM+i)*32*1024*1024;
            par_bin_size   [i] 	<= 32*1024*1024; 
						par_active_state[i] <= 1'b1;	
        end  		 		
	end else begin 	
		new_par_start <= 1'b0;
		new_par_active <= 1'b0;	
		case (CURRENT_STATE) 
			IDLE: begin
			 if(control != 2'b00) begin
				CURRENT_STATE <= control;
				next_par_id <= 1'b0;
				state_switch <= 1'b1;
				PE_DONE <=  PE_DONE;
			 end   
			end
			SCATTER: begin
				if(par_complete_sig || state_switch) begin
					if(next_par_id == PAR_NUM-1) begin
					   CURRENT_STATE <= IDLE;
					   PE_DONE <= 1'b1;
					   next_par_id <= 1'b0;
					   state_switch <= 1'b1; 
					end else begin 
					   next_par_id <= next_par_id+1;                       
					   Raddr <= par_shard_addr[next_par_id];
					   work_size <= par_shard_size[next_par_id];
					   state_switch <= 1'b0;
					   PE_DONE <= 1'b0;
					   new_par_start <= 1'b1;
					   par_active_state[next_par_id] <= 1'b0;
					   new_par_active <= par_active_state[next_par_id+1];
					end
				end 
			end
			GATHER: begin
				if(par_complete_sig || state_switch) begin
					if(next_par_id == PAR_NUM-1) begin
						CURRENT_STATE <= IDLE;
						PE_DONE <= 1'b1;
						state_switch <= 1'b1; 
					end else begin 
						next_par_id <= next_par_id+1;                       
						Raddr <= par_bin_addr[next_par_id];
						work_size <= par_bin_size[next_par_id];
						state_switch <= 1'b0;
						PE_DONE <= 1'b0;
						new_par_start <= 1'b1;
					end
					par_active_state[next_par_id] <= par_active;
				end 
			end
			default: begin				
				CURRENT_STATE <= CURRENT_STATE;
				PE_DONE <= 1'b0;
				state_switch <= 1'b0;				
			end
		endcase
	end
end

endmodule

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

module fifo #(
    parameter FIFO_WIDTH = 96,
    parameter FIFO_DEPTH_BITS = 8,
    parameter FIFO_ALMOSTFULL_THRESHOLD = 2**FIFO_DEPTH_BITS - 4,
    parameter FIFO_ALMOSTEMPTY_THRESHOLD = 2
) (
    input  wire                         clk,
    input  wire                         rst,    
    input  wire                         we,              // input   write enable
    input  wire [FIFO_WIDTH - 1:0]      din,            // input   write data with configurable width
    input  wire                         re,              // input   read enable    
    output reg  [FIFO_WIDTH - 1:0]      dout,            // output  read data with configurable width    
    output reg  [FIFO_DEPTH_BITS - 1:0] count,              // output  FIFOcount
    output reg                          empty,              // output  FIFO empty
    output reg                          almostempty,              // output  FIFO almost empty
    output reg                          full,               // output  FIFO full                
    output reg                          almostfull         // output  configurable programmable full/ almost full    
);
    reg                                 valid;
    reg                                 overflow;
    reg                                 underflow;        
    reg  [FIFO_DEPTH_BITS - 1:0]        rp;
    reg  [FIFO_DEPTH_BITS - 1:0]        wp;

`ifdef VENDOR_XILINX    
    (* ramstyle = "M20K" *)
    reg  [FIFO_WIDTH - 1:0]         mem[2**FIFO_DEPTH_BITS-1:0];
`else
    reg  [FIFO_WIDTH - 1:0]         mem[2**FIFO_DEPTH_BITS-1:0];
`endif
        
        
    always @(posedge clk) begin
        if (rst) begin
            empty <= 1'b1;
            almostempty <= 1'b1;
            full <= 1'b0;
            almostfull <= 1'b0;
            count <= 0;            
            rp <= 0;
            wp <= 0;
            valid <= 1'b0;
            overflow <= 1'b0;
            underflow <= 1'b0;            
        end else begin
            valid <= 0;          
            case ({we, re})
                2'b11 : begin
                    wp <= wp + 1'b1;                    
                    rp <= rp + 1'b1;
                    valid <= 1;
                end
                                
                2'b10 : begin
                    if (full) begin                                                                        
                        overflow <= 1;                                                
                    end else begin
                        wp <= wp + 1'b1;
                        count <= count + 1'b1;
                        empty <= 1'b0;
                        if (count == (FIFO_ALMOSTEMPTY_THRESHOLD-1))
                            almostempty <= 1'b0;
                            
                        if (count == (2**FIFO_DEPTH_BITS-1))
                            full <= 1'b1;

                        if (count == (FIFO_ALMOSTFULL_THRESHOLD-1))
                            almostfull <= 1'b1;
                    end
                end
                
                2'b01 : begin
                    if (empty) begin                                               
                        underflow <= 1;
                    end else begin
                        rp <= rp + 1'b1;
                        count <= count - 1'b1;                    
                        full <= 0;                    
                        if (count == FIFO_ALMOSTFULL_THRESHOLD)
                            almostfull <= 1'b0;                                            
                        if (count == 1)
                            empty <= 1'b1;                            
                        if (count == FIFO_ALMOSTEMPTY_THRESHOLD)
                            almostempty <= 1'b1;
							
                        valid <= 1;                          
                    end 
                end               
                default : begin
                end
            endcase
        end
    end


    always @(posedge clk) begin
        if (we == 1'b1)
            mem[wp] <= din;
            
        dout <= mem[rp];            
    end
    
endmodule


module hdu_unit # (
    parameter ADDR_W = 16
)(
	input   wire clk,
	input   wire rst,
	input   wire [ADDR_W-1:0] Raddr,
	input   wire [ADDR_W-1:0] Waddr,
	input   wire Raddr_valid,
	input   wire Waddr_valid,
	output  reg  flag_valid,
	output  reg  flag
);
    
    wire bram_flag_outA;
    wire bram_flag_outB;
    
    always @(posedge clk) begin
        if(rst) begin
            flag_valid <=1'b0;
            flag <=1'b0;
        end else begin
            flag_valid <= Raddr_valid;
            flag <= bram_flag_outA;            
        end    
    end 
	 /*
    bram # (.DATA(1),  .ADDR(ADDR_W))
    hdu_ram(
        .clk(clk),
        .a_wr(Raddr_valid),
        .a_addr(Raddr),
        .a_din(1'b1),
        .a_dout(bram_flag_outA),
        .b_wr(Waddr_valid),
        .b_addr(Waddr),
        .b_din(1'b0),
        .b_dout(bram_flag_outB)
    );  */
	  true_dual_port_ram_single_clock #(
		  .DATA_WIDTH(1),
		  .ADDR_WIDTH(ADDR_W)
	  )bram(
		.clk(clk),
        .we_a(Raddr_valid),
        .addr_a(Raddr),
        .data_a(1'b1),
        .q_a(bram_flag_outA),
        .we_b(Waddr_valid),
        .addr_b(Waddr),
        .data_b(1'b0),
        .q_b(bram_flag_outB)		
	  );	
endmodule

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
	/*
		URAM #(.DATA_W(DATA_W), .ADDR_W(ADDR_W-Bank_Num_W))
		bank (
			.Data_in(bank_wdata[numbank]),
			.R_Addr(bank_raddr[numbank]),
			.W_Addr(bank_waddr[numbank]),
			.W_En(bank_w_en[numbank]),
			.En(1'b1),
			.clk(clk),
			.Data_out(bank_rdata[numbank])
		);*/
	simple_dual_port_ram_single_clock #(
		.DATA_WIDTH(DATA_W),
		.ADDR_WIDTH(ADDR_W-Bank_Num_W)
	)buffer(
		.data(bank_wdata[numbank]),
		.read_addr(bank_raddr[numbank]),
		.write_addr(bank_waddr[numbank]),
		.we(bank_w_en[numbank]),
		.clk(clk),
		.q(bank_rdata[numbank])
	);	
	end
endgenerate	



	
genvar i;
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: read_addr assign bank_raddr[i] = (R_valid0 && R_Addr0[Bank_Num_W-1:0] ==i) ? R_Addr0[ADDR_W-1:Bank_Num_W] :
										   (R_valid1 && R_Addr1[Bank_Num_W-1:0] ==i) ? R_Addr1[ADDR_W-1:Bank_Num_W] : 
										   (R_valid2 && R_Addr2[Bank_Num_W-1:0] ==i) ? R_Addr2[ADDR_W-1:Bank_Num_W] : 
										   (R_valid3 && R_Addr3[Bank_Num_W-1:0] ==i) ? R_Addr3[ADDR_W-1:Bank_Num_W] : 	  
										   (R_valid4 && R_Addr4[Bank_Num_W-1:0] ==i) ? R_Addr4[ADDR_W-1:Bank_Num_W] :
										   (R_valid5 && R_Addr5[Bank_Num_W-1:0] ==i) ? R_Addr5[ADDR_W-1:Bank_Num_W] : 
										   (R_valid6 && R_Addr6[Bank_Num_W-1:0] ==i) ? R_Addr6[ADDR_W-1:Bank_Num_W] : 
										   (R_valid7 && R_Addr7[Bank_Num_W-1:0] ==i) ? R_Addr7[ADDR_W-1:Bank_Num_W] : 1'b0;	  
   end 
endgenerate

generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_addr assign bank_waddr[i] = (W_valid0 && W_Addr0[Bank_Num_W-1:0] ==i) ? W_Addr0[ADDR_W-1:Bank_Num_W] :
										    (W_valid1 && W_Addr1[Bank_Num_W-1:0] ==i) ? W_Addr1[ADDR_W-1:Bank_Num_W] : 
											(W_valid2 && W_Addr2[Bank_Num_W-1:0] ==i) ? W_Addr2[ADDR_W-1:Bank_Num_W] : 
											(W_valid3 && W_Addr3[Bank_Num_W-1:0] ==i) ? W_Addr3[ADDR_W-1:Bank_Num_W] : 
											(W_valid4 && W_Addr4[Bank_Num_W-1:0] ==i) ? W_Addr4[ADDR_W-1:Bank_Num_W] :
										    (W_valid5 && W_Addr5[Bank_Num_W-1:0] ==i) ? W_Addr5[ADDR_W-1:Bank_Num_W] : 
											(W_valid6 && W_Addr6[Bank_Num_W-1:0] ==i) ? W_Addr6[ADDR_W-1:Bank_Num_W] : 
											(W_valid7 && W_Addr7[Bank_Num_W-1:0] ==i) ? W_Addr7[ADDR_W-1:Bank_Num_W] : 1'b0;
   end 
endgenerate

generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_data assign bank_wdata[i] = (W_valid0 && W_Addr0[Bank_Num_W-1:0] ==i) ? W_Data0 :
										    (W_valid1 && W_Addr1[Bank_Num_W-1:0] ==i) ? W_Data1 : 
											(W_valid2 && W_Addr2[Bank_Num_W-1:0] ==i) ? W_Data2 :  
											(W_valid3 && W_Addr3[Bank_Num_W-1:0] ==i) ? W_Data3 : 
											(W_valid4 && W_Addr4[Bank_Num_W-1:0] ==i) ? W_Data4 :		
										    (W_valid5 && W_Addr5[Bank_Num_W-1:0] ==i) ? W_Data5 : 
											(W_valid6 && W_Addr6[Bank_Num_W-1:0] ==i) ? W_Data6 :  
											(W_valid7 && W_Addr7[Bank_Num_W-1:0] ==i) ? W_Data7 : 1'b0;											
   end 
endgenerate

generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_enable assign bank_w_en[i] = (W_valid0 && W_Addr0[Bank_Num_W-1:0] ==i) ? 1'b1 :
										     (W_valid1 && W_Addr1[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid2 && W_Addr2[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid3 && W_Addr3[Bank_Num_W-1:0] ==i) ? 1'b1 :
											 (W_valid4 && W_Addr4[Bank_Num_W-1:0] ==i) ? 1'b1 :
										     (W_valid5 && W_Addr5[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid6 && W_Addr6[Bank_Num_W-1:0] ==i) ? 1'b1 : 
											 (W_valid7 && W_Addr7[Bank_Num_W-1:0] ==i) ? 1'b1 : 1'b0;											 
   end 
endgenerate

assign R_Data0 = bank_rdata[sel[0]];
assign R_Data1 = bank_rdata[sel[1]];
assign R_Data2 = bank_rdata[sel[2]];
assign R_Data3 = bank_rdata[sel[3]];
assign R_Data4 = bank_rdata[sel[4]];
assign R_Data5 = bank_rdata[sel[5]];
assign R_Data6 = bank_rdata[sel[6]];
assign R_Data7 = bank_rdata[sel[7]];

integer j;												
always @(posedge clk) begin
	if(rst) begin
		R_out_valid0 <= 0;
		R_out_valid1 <= 0;
		R_out_valid2 <= 0;
		R_out_valid3 <= 0;
		R_out_valid4 <= 0;
		R_out_valid5 <= 0;
		R_out_valid6 <= 0;
		R_out_valid7 <= 0;
		for(j=0; j<8; j=j+1) sel[j] <=j;            
	end else begin
		R_out_valid0 <= R_valid0;
		R_out_valid1 <= R_valid1;
		R_out_valid2 <= R_valid2;
		R_out_valid3 <= R_valid3;
		R_out_valid4 <= R_valid4;
		R_out_valid5 <= R_valid5;
		R_out_valid6 <= R_valid6;
		R_out_valid7 <= R_valid7;		
		sel[0] <= R_Addr0[Bank_Num_W-1:0];			
		sel[1] <= R_Addr1[Bank_Num_W-1:0];			  
		sel[2] <= R_Addr2[Bank_Num_W-1:0];			
		sel[3] <= R_Addr3[Bank_Num_W-1:0];			  
		sel[4] <= R_Addr4[Bank_Num_W-1:0];			
		sel[5] <= R_Addr5[Bank_Num_W-1:0];			  
		sel[6] <= R_Addr6[Bank_Num_W-1:0];			
		sel[7] <= R_Addr7[Bank_Num_W-1:0];			  	
	end
end
endmodule


module Ubuffx8(
    input wire clk,
    input wire rst,    
    input wire last_input_in,
    input wire [64*8-1:0] word_in,
	input wire [7:0] word_in_valid,
    //input wire [1:0] control,        
    output reg [64*8-1:0] word_out, 
    output reg [7:0] valid_out
);

reg [2:0]	counter;
reg	[63:0]	update_buff [6:0];

integer i;
	
always @ (posedge clk) begin
	if (rst) begin
		counter <=0;
		word_out <=0;
		valid_out <=8'b00000000;
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <=0;            
		end
	end else begin		
		counter <= counter;				
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <= update_buff [i] ;            
		end
		word_out  <= 0;
		valid_out <= 8'b00000000;
		if(last_input_in) begin			
			valid_out	<= (counter == 0) ? 8'b00000000 :
			               (counter == 1) ? 8'b10000000 :
						   (counter == 2) ? 8'b11000000 :
						   (counter == 3) ? 8'b11100000 :
						   (counter == 4) ? 8'b11110000 :
						   (counter == 5) ? 8'b11111000 :
						   (counter == 6) ? 8'b11111100 : 8'b11111110;						   
			word_out	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], 64'h000000000000000};	
			counter		<= 0;
		end else begin								
			case(word_in_valid)					
				8'b10000000: begin                    
					if(counter<7) begin
					   counter <= counter +1;
					   update_buff[counter] <= word_in[511:448]; 
					   valid_out <= 8'b00000000;
					end else begin
					   counter <= 0;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511:448]}; 
					end                        
				end
				8'b11000000: begin                    
				   if(counter<6) begin
					  counter <= counter +2;
					  valid_out <= 8'b00000000;
					  update_buff[counter]   <= word_in[511:448]; 
					  update_buff[counter+1] <= word_in[447:384]; 
				   end else if (counter==6) begin
					  counter <= 0;
					  valid_out <=8'b11111111;
					  word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511:384]};
				  end else begin
					  counter <= 1;
					  valid_out <= 8'b11111111;
					  word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511:448]}; 
					  update_buff[0] <= word_in[447:384];       
				   end                       
			   end
			   8'b11100000: begin                    
				  if(counter<5) begin
					 counter <= counter +3;
					 valid_out <= 8'b00000000;
					 update_buff[counter]   <= word_in[511:448]; 
					 update_buff[counter+1] <= word_in[447:384]; 
					 update_buff[counter+2] <= word_in[383:320]; 
				  end else if (counter==5) begin
					 counter  	<= 0;
					 valid_out 	<= 8'b11111111;
					 word_out  	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4], word_in[511:320]};
				 end else if (counter==6) begin
					 counter <= 1;
					 valid_out <= 8'b11111111;
					 word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511:384]};
					 update_buff[0] <= word_in[383:320];                             
				  end else begin
					 counter 	<= 2;
					 valid_out 	<=8'b11111111;
					 word_out 	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511:448]};
					 update_buff[0] <= word_in[447:384]; 
					 update_buff[1] <= word_in[383:320]; 
				  end                                        
			   end
			   8'b11110000: begin                    
					 if(counter<4) begin
						counter <= counter +4;
						valid_out <= 8'b00000000;
						update_buff[counter]   <= word_in[511:448]; 
						update_buff[counter+1] <= word_in[447:384]; 
						update_buff[counter+2] <= word_in[383:320]; 
						update_buff[counter+3] <= word_in[319:256];
					 end else if (counter==4) begin
						counter <= 0;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3], word_in[511:256]};
					end else if (counter==5) begin
						counter <= 1;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],word_in[511:320]}; 
						update_buff[0] <= word_in[319:256];                                
					 end else if (counter==6) begin
						 counter <= 2;
						 valid_out <=8'b11111111;
						 word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],word_in[511:384]};
						 update_buff[0] <= word_in[383:320]; 
						 update_buff[1] <= word_in[319:256];                   
					 end else begin
						counter <= 3;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6],word_in[511:448]};
						update_buff[0] <= word_in[447:384]; 
						update_buff[1] <= word_in[383:320];  
						update_buff[2] <= word_in[319:256];
					 end                                        
			   end
			   8'b11111000: begin                    
					if(counter<3) begin
					   counter <= counter+5;
					   valid_out <= 8'b00000000;
					   update_buff[counter]   <= word_in[511:448]; 
					   update_buff[counter+1] <= word_in[447:384];
					   update_buff[counter+2] <= word_in[383:320];
					   update_buff[counter+3] <= word_in[319:256];
					   update_buff[counter+4] <= word_in[255:192];
					end else if (counter==3) begin
					   counter <= 0;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],word_in[511:192]};
				    end else if (counter==4) begin
					   counter <= 1;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3], word_in[511:256]}; 
					   update_buff[0] <= word_in[255:192];                                
					end else if (counter==5) begin
						counter <= 2;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4], word_in[511:320]};
						update_buff[0] <= word_in[319:256];
						update_buff[1] <= word_in[255:192];           
					end else if (counter==6) begin
						counter   <= 3;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511:384]};
						update_buff[0] <= word_in[383:320];
						update_buff[1] <= word_in[319:256];
						update_buff[2] <= word_in[255:192];
					end else begin
					   counter <= 4;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6],word_in[511:448]};
					   update_buff[0] <= word_in[447:384];
					   update_buff[1] <= word_in[383:320];
					   update_buff[2] <= word_in[319:256];
					   update_buff[3] <= word_in[255:192];
					end                                        
				end
				8'b11111100: begin                    
					if(counter<2) begin
					   counter <= counter+6;
					   valid_out <= 8'b00000000;
					   update_buff[counter]   <= word_in[511:448]; 
					   update_buff[counter+1] <= word_in[447:384];
					   update_buff[counter+2] <= word_in[383:320];
					   update_buff[counter+3] <= word_in[319:256];
					   update_buff[counter+4] <= word_in[255:192];
					   update_buff[counter+5] <= word_in[191:128];
					end else if (counter==2) begin
					   counter <= 0;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1], word_in[511:128]};                                                                       
					end else if (counter==3) begin
					   counter <= 1;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2], word_in[511:192]}; 
					   update_buff[0] <= word_in[191:128];                                
					end else if (counter==4) begin
						counter <= 2;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3], word_in[511:256]};
						update_buff[0] <= word_in[255:192];
						update_buff[1] <= word_in[191:128];                                             
					end else if (counter==5) begin
						counter   <= 3;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4], word_in[511:320]};
						update_buff[0] <= word_in[319:256];
						update_buff[1] <= word_in[255:192];
						update_buff[2] <= word_in[191:128];
					end else if (counter==6) begin
					   counter 		<= 4;
					   valid_out 	<=8'b11111111;
					   word_out 	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511:384]};
					   update_buff[0] <= word_in[383:320];
					   update_buff[1] <= word_in[319:256];
					   update_buff[2] <= word_in[255:192];   
					   update_buff[3] <= word_in[191:128];
					end else begin
					   counter 		<= 5;
					   valid_out 	<=8'b11111111;
					   word_out 	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6],word_in[511:448]};
					   update_buff[0] <= word_in[447:384];
					   update_buff[1] <= word_in[383:320];
					   update_buff[2] <= word_in[319:256];
					   update_buff[3] <= word_in[255:192];  
					   update_buff[4] <= word_in[191:128];
					end                                        
				end
				8'b11111110: begin                    
					if(counter==0) begin
					   counter <= counter+7;
					   valid_out <= 8'b00000000;
					   update_buff[counter]   <= word_in[511:448]; 
					   update_buff[counter+1] <= word_in[447:384];
					   update_buff[counter+2] <= word_in[383:320];
					   update_buff[counter+3] <= word_in[319:256];
					   update_buff[counter+4] <= word_in[255:192];
					   update_buff[counter+5] <= word_in[191:128];
					   update_buff[counter+6] <= word_in[127:64];
					end else if (counter==1) begin
					   counter <= 0;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0], word_in[511:64]};                                                                       
					end else if (counter==2) begin
					   counter <= 1;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1], word_in[511:128]}; 
					   update_buff[0] <= word_in[127:64];                        
					end else if (counter==3) begin
						counter <= 2;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],word_in[511:192]};
						update_buff[0] <= word_in[191:128];
						update_buff[1] <= word_in[127:64];                                          
					end else if (counter==4) begin
						counter   <= 3;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3], word_in[511:256]};
						update_buff[0] <= word_in[255:192];
						update_buff[1] <= word_in[191:128];
						update_buff[2] <= word_in[127:64];                       
					end else if (counter==5) begin
					   counter <= 4;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4], word_in[511:320]};                           
					   update_buff[0] <= word_in[319:256];
					   update_buff[1] <= word_in[255:192];
					   update_buff[2] <= word_in[191:128];
					   update_buff[3] <= word_in[127:64];       
					end else if (counter==6) begin
						  counter <= 5;
						  valid_out <=8'b11111111;
						  word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511:384]};
						  update_buff[0] <= word_in[383:320];
						  update_buff[1] <= word_in[319:256];
						  update_buff[2] <= word_in[255:192];
						  update_buff[3] <= word_in[191:128];
						  update_buff[4] <= word_in[127:64];          
					end else begin
					   counter <= 6;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6],word_in[511:448]};
					   update_buff[0] <= word_in[447:384];
					   update_buff[1] <= word_in[383:320];
					   update_buff[2] <= word_in[319:256];
					   update_buff[3] <= word_in[255:192];
					   update_buff[4] <= word_in[191:128];
					   update_buff[5] <= word_in[127:64];     
				   end                                        
				end
				default: begin                    											   
					valid_out <=8'b11111111;
					word_out <= word_in;					                                          
				end						
			endcase	
		end  
	end         
end
  
endmodule

module Ubuffx4(
    input wire clk,
    input wire rst,    
    input wire last_input_in,
    input wire [64*4-1:0] word_in,
	input wire [3:0] word_in_valid,
    //input wire [1:0] control,        
    output reg [64*8-1:0] word_out, 
    output reg [7:0] valid_out
);

reg [2:0]	counter;
reg	[63:0]	update_buff [6:0];

integer i;
	
always @ (posedge clk) begin
	if (rst) begin
		counter <=0;
		word_out <=0;
		valid_out <=8'b00000000;
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <=0;            
		end
	end else begin		
		counter <= counter;				
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <= update_buff [i] ;            
		end
		word_out  <= 0;
		valid_out <= 8'b00000000;
		if(last_input_in) begin			
			valid_out	<= (counter == 0) ? 8'b00000000 :
			               (counter == 1) ? 8'b10000000 :
						   (counter == 2) ? 8'b11000000 :
						   (counter == 3) ? 8'b11100000 :
						   (counter == 4) ? 8'b11110000 :
						   (counter == 5) ? 8'b11111000 :
						   (counter == 6) ? 8'b11111100 : 8'b11111110;						   
			word_out	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], 64'h000000000000000};	
			counter		<= 0;
		end else begin								
			case(word_in_valid)					
				4'b1000: begin                    
					if(counter<7) begin
					   counter <= counter +1;
					   update_buff[counter] <= word_in[511-256:448-256]; 
					   valid_out <= 8'b00000000;
					end else begin
					   counter <= 0;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511-256:448-256]}; 
					end                        
				end
				4'b1100: begin                    
				   if(counter<6) begin
					  counter <= counter +2;
					  valid_out <= 8'b00000000;
					  update_buff[counter]   <= word_in[511-256:448-256]; 
					  update_buff[counter+1] <= word_in[447-256:384-256]; 
				   end else if (counter==6) begin
					  counter <= 0;
					  valid_out <=8'b11111111;
					  word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511-256:384-256]};
				  end else begin
					  counter <= 1;
					  valid_out <= 8'b11111111;
					  word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511-256:448-256]}; 
					  update_buff[0] <= word_in[447-256:384-256];       
				   end                       
			   end
			   4'b1110: begin                    
				  if(counter<5) begin
					 counter <= counter +3;
					 valid_out <= 8'b00000000;
					 update_buff[counter]   <= word_in[511-256:448-256]; 
					 update_buff[counter+1] <= word_in[447-256:384-256]; 
					 update_buff[counter+2] <= word_in[383-256:320-256]; 
				  end else if (counter==5) begin
					 counter  	<= 0;
					 valid_out 	<= 8'b11111111;
					 word_out  	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4], word_in[511-256:320-256]};
				 end else if (counter==6) begin
					 counter <= 1;
					 valid_out <= 8'b11111111;
					 word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511-256:384-256]};
					 update_buff[0] <= word_in[383-256:320-256];                             
				  end else begin
					 counter 	<= 2;
					 valid_out 	<=8'b11111111;
					 word_out 	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511-256:448-256]};
					 update_buff[0] <= word_in[447-256:384-256]; 
					 update_buff[1] <= word_in[383-256:320-256]; 
				  end                                        
			   end
			   4'b1111: begin                    
					 if(counter<4) begin
						counter <= counter +4;
						valid_out <= 8'b00000000;
						update_buff[counter]   <= word_in[511-256:448-256]; 
						update_buff[counter+1] <= word_in[447-256:384-256]; 
						update_buff[counter+2] <= word_in[383-256:320-256]; 
						update_buff[counter+3] <= word_in[319-256:256-256];
					 end else if (counter==4) begin
						counter <= 0;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3], word_in[511-256:256-256]};
					end else if (counter==5) begin
						counter <= 1;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],word_in[511-256:320-256]}; 
						update_buff[0] <= word_in[319-256:256-256];                                
					 end else if (counter==6) begin
						 counter <= 2;
						 valid_out <=8'b11111111;
						 word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],word_in[511-256:384-256]};
						 update_buff[0] <= word_in[383-256:320-256]; 
						 update_buff[1] <= word_in[319-256:256-256];                   
					 end else begin
						counter <= 3;
						valid_out <=8'b11111111;
						word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6],word_in[511-256:448-256]};
						update_buff[0] <= word_in[447-256:384-256]; 
						update_buff[1] <= word_in[383-256:320-256];  
						update_buff[2] <= word_in[319-256:256-256];
					 end                                        
				end			   
				default: begin                    											   
					valid_out <=8'b00000000;
					word_out <= {word_in,word_in};					                                          
				end						
			endcase	
		end  
	end         
end
  
endmodule

module Ubuffx2(
    input wire clk,
    input wire rst,    
    input wire last_input_in,
    input wire [64*2-1:0] word_in,
	input wire [1:0] word_in_valid,
    //input wire [1:0] control,        
    output reg [64*8-1:0] word_out, 
    output reg [7:0] valid_out
);

reg [2:0]	counter;
reg	[63:0]	update_buff [6:0];

integer i;
	
always @ (posedge clk) begin
	if (rst) begin
		counter <=0;
		word_out <=0;
		valid_out <=8'b00000000;
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <=0;            
		end
	end else begin		
		counter <= counter;				
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <= update_buff [i] ;            
		end
		word_out  <= 0;
		valid_out <= 8'b00000000;
		if(last_input_in) begin			
			valid_out	<= (counter == 0) ? 8'b00000000 :
			               (counter == 1) ? 8'b10000000 :
						   (counter == 2) ? 8'b11000000 :
						   (counter == 3) ? 8'b11100000 :
						   (counter == 4) ? 8'b11110000 :
						   (counter == 5) ? 8'b11111000 :
						   (counter == 6) ? 8'b11111100 : 8'b11111110;						   
			word_out	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], 64'h000000000000000};	
			counter		<= 0;
		end else begin								
			case(word_in_valid)					
				2'b10: begin                    
					if(counter<7) begin
					   counter <= counter +1;
					   update_buff[counter] <= word_in[511-256-128:448-256-128]; 
					   valid_out <= 8'b00000000;
					end else begin
					   counter <= 0;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511-256-128:448-256-128]}; 
					end                        
				end
				2'b11: begin                    
					if(counter<6) begin
					  counter <= counter +2;
					  valid_out <= 8'b00000000;
					  update_buff[counter]   <= word_in[511-256-128:448-256-128]; 
					  update_buff[counter+1] <= word_in[447-256-128:384-256-128]; 
					end else if (counter==6) begin
					  counter <= 0;
					  valid_out <=8'b11111111;
					  word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5], word_in[511-256-128:384-256-128]};
					end else begin
					  counter <= 1;
					  valid_out <= 8'b11111111;
					  word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in[511-256-128:448-256-128]}; 
					  update_buff[0] <= word_in[447-256-128:384-256-128];       
					end                       
				end				   
				default: begin                    											   
					valid_out <=8'b00000000;
					word_out <= {word_in,word_in};					                                          
				end						
			endcase	
		end  
	end         
end
  
endmodule

module Ubuffx1(
    input wire clk,
    input wire rst,    
    input wire last_input_in,
    input wire [64-1:0] word_in,
	input wire word_in_valid,
    //input wire [1:0] control,        
    output reg [64*8-1:0] word_out, 
    output reg [7:0] valid_out
);

reg [2:0]	counter;
reg	[63:0]	update_buff [6:0];

integer i;
	
always @ (posedge clk) begin
	if (rst) begin
		counter <=0;
		word_out <=0;
		valid_out <=8'b00000000;
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <=0;            
		end
	end else begin		
		counter <= counter;				
		for(i=0; i<7; i=i+1) begin 
			update_buff [i] <= update_buff [i] ;            
		end
		word_out  <= 0;
		valid_out <= 8'b00000000;
		if(last_input_in) begin			
			valid_out	<= (counter == 0) ? 8'b00000000 :
			               (counter == 1) ? 8'b10000000 :
						   (counter == 2) ? 8'b11000000 :
						   (counter == 3) ? 8'b11100000 :
						   (counter == 4) ? 8'b11110000 :
						   (counter == 5) ? 8'b11111000 :
						   (counter == 6) ? 8'b11111100 : 8'b11111110;						   
			word_out	<= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], 64'h000000000000000};	
			counter		<= 0;
		end else begin								
			case(word_in_valid)					
				1'b1: begin                    
					if(counter<7) begin
					   counter <= counter +1;
					   update_buff[counter] <= word_in; 
					   valid_out <= 8'b00000000;
					end else begin
					   counter <= 0;
					   valid_out <=8'b11111111;
					   word_out <= {update_buff[0],update_buff[1],update_buff[2],update_buff[3],update_buff[4],update_buff[5],update_buff[6], word_in}; 
					end                        
				end				   
				default: begin                    											   
					valid_out <=8'b00000000;
					word_out <= {word_in,word_in};					                                          
				end						
			endcase	
		end  
	end         
end
  
endmodule

module pr_PP # (
    parameter PIPE_DEPTH = 8,
    parameter URAM_DATA_W = 64,
    parameter PAR_SIZE_W = 10,
    parameter EDGE_W = 64
)(
    input wire                      clk,
    input wire                      rst,     
    input wire [1:0]                control,
    input wire [URAM_DATA_W-1:0]    buffer_Din,
    input wire                      buffer_Din_valid,   
    input wire [EDGE_W-1:0]         input_word,
    input wire [0:0]                input_valid,
    output wire [URAM_DATA_W-1:0]   buffer_Dout,
    output wire [PAR_SIZE_W-1:0]    buffer_Dout_Addr,
    output wire                     buffer_Dout_valid,    
    output wire [63:0]              output_word,    
    output wire [0:0]               output_valid,
    output wire [0:0]               par_active  
);
    
    reg [EDGE_W-1:0] input_word_reg;
    reg [0:0]  input_valid_reg; 
    
     always @(posedge clk) begin
        if (rst) begin
            input_word_reg <= 0;
            input_valid_reg <= 0;
        end  else begin
            input_word_reg <= input_word;
            input_valid_reg <= input_valid;
        end
      end
       
    pr_scatter_pipe # (.PIPE_DEPTH (PIPE_DEPTH), .URAM_DATA_W(URAM_DATA_W))
    a_unit (
        .clk(clk),
        .rst(rst),
        .edge_weight(),
        .src_attr(buffer_Dout),
        .edge_dest(input_word_reg[63:32]),
        .input_valid(input_valid_reg && buffer_Din_valid && control==1),    
        .update_value(output_word[63:32]),
        .update_dest(output_word[31:0]),    
        .output_valid(output_valid)
    );

    pr_gather_pipe # (.PIPE_DEPTH (PIPE_DEPTH), .PAR_SIZE_W(PAR_SIZE_W), .URAM_DATA_W(URAM_DATA_W))
    gather_unit (
        .clk(clk),
        .rst(rst),
        .update_value(input_word_reg[63:32]),
        .update_dest(input_word_reg[31:0]),
        .dest_attr(buffer_Din),
        .input_valid(input_valid_reg && buffer_Din_valid && control==2),    
        .WData(buffer_Dout),
        .WAddr(buffer_Dout_Addr),    
        .Wvalid(buffer_Dout_valid),
        .par_active(par_active)
    );
    
endmodule

module pr_gather_pipe # (
    parameter PIPE_DEPTH = 8,
    parameter PAR_SIZE_W = 18,
    parameter URAM_DATA_W = 64
)(
    input wire                      clk,
    input wire                      rst,  
    input wire [31:0]               update_value,
    input wire [31:0]               update_dest,
    input wire [URAM_DATA_W-1:0]    dest_attr,
    input wire [0:0]                input_valid,    
    output wire [URAM_DATA_W-1:0]   WData,
    output wire [PAR_SIZE_W-1:0]    WAddr,    
    output wire [0:0]               Wvalid,
    output wire [0:0]               par_active  
);

    reg [0:0] valid_reg [PIPE_DEPTH-1:0];
    reg [31:0] dest_reg [PIPE_DEPTH-1:0];    
    assign WAddr = dest_reg[PIPE_DEPTH-1][PAR_SIZE_W-1:0];
    assign par_active = 1'b1;
        
    reg	[31:0] dest_attr_reg [PIPE_DEPTH-1:0];    	
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for(i=0; i<PIPE_DEPTH; i=i+1) begin
                dest_reg[i] <= 0;
				dest_attr_reg [i] <= 0;
            end
        end	else begin
            for(i=1; i<PIPE_DEPTH; i=i+1) begin
               dest_reg[i] <= dest_reg[i-1];
			   dest_attr_reg [i] <= dest_attr_reg [i-1]; 
            end
            dest_reg [0] <=  update_dest;            
			dest_attr_reg [0] <= dest_attr [63:32];
        end
    end    
    /* 
    fp_add adder(              
        .aclk(clk),
        .s_axis_a_tvalid(input_valid),        
        .s_axis_a_tdata(update_value),
        .s_axis_b_tvalid(input_valid),
        .s_axis_b_tdata(dest_attr[31:0]),
        .m_axis_result_tvalid (Wvalid),     
        .m_axis_result_tdata(WData[31:0])              
    );*/	
	 add add(
	.clk(clk),
	.a(update_value),
	.b(dest_attr[31:0]),
	.q(WData[31:0]),
	.areset(rst),
	.en(input_valid)
	

);
	
    assign WData[63:32] = dest_attr_reg [PIPE_DEPTH-1];
	
endmodule


module pr_scatter_pipe # (
    parameter PIPE_DEPTH = 8,
    parameter URAM_DATA_W = 64
)(
    input wire                      clk,
    input wire                      rst,    
    input wire [31:0]               edge_weight,
    input wire [URAM_DATA_W-1:0]    src_attr,
    input wire [31:0]               edge_dest,
    input wire [0:0]                input_valid,    
    output wire [31:0]              update_value,
    output wire [31:0]              update_dest,    
    output wire [0:0]               output_valid  
);
    reg [31:0] dest_reg [PIPE_DEPTH-1:0];    
    assign update_dest = dest_reg[PIPE_DEPTH-1];
    
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for(i=0; i<PIPE_DEPTH; i=i+1) begin
                dest_reg[i] <= 0;
            end
        end	else begin
            for(i=1; i<PIPE_DEPTH; i=i+1) begin
               dest_reg[i] <= dest_reg[i-1];
            end
            dest_reg [0] <=  edge_dest;            
        end
    end
    /*
    fp_mul multiplier(              
        .aclk(clk),
        .s_axis_a_tvalid(input_valid),        
        .s_axis_a_tdata(src_attr[31:0]),
        .s_axis_b_tvalid(input_valid),
        .s_axis_b_tdata(src_attr[63:32]),
        .m_axis_result_tvalid (output_valid),      
        .m_axis_result_tdata(update_value)              
    );*/
	 mult mult(
	.clk(clk),
	.a(src_attr[31:0]),
	.b(src_attr[63:32]),
	.q(update_value),
	.areset(rst),
	.en(input_valid)
);
    
endmodule

module combine_unit (
 	 input wire clk,
	 input wire rst,
 	 input wire [31:0] update_A, 
 	 input wire [31:0] update_B, 
	 output wire [31:0] combined_update
);
	/*
	fp_add adder(
		.aclk(clk), 
		.s_axis_a_tvalid(1'b1),
		.s_axis_a_tdata(update_A),
		.s_axis_b_tvalid(1'b1),
		.s_axis_b_tdata(update_B),
		.m_axis_result_tdata(combined_update)
	);*/
	add add(
	.clk(clk),
	.a(update_A),
	.b(update_B),
	.q(combined_update),
	.areset(rst),
	.en(1'b1)
);
	
endmodule

module simple_dual_port_ram_single_clock
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] read_addr, write_addr,
	input we, clk,
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
	(* ramstyle = "M20K" *)
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[write_addr] <= data;

		// Read (if read_addr == write_addr) returns OLD data.	To return
		// NEW data, use = (blocking write) rather than <= (non-blocking write)
		// in the write assignment.	 NOTE: NEW data may require extra bypass
		// logic around the RAM.
		q <= ram[read_addr];
	end

endmodule
/*
module URAM(
	Data_in,	// W
	R_Addr,	// R
	W_Addr,	// W
	W_En,	// W
	En,
	clk,
	Data_out	// R
	);
parameter DATA_W = 256;
parameter ADDR_W = 18;
localparam DEPTH = (2 ** ADDR_W);

input [DATA_W-1:0] Data_in;
input [ADDR_W-1:0] R_Addr, W_Addr;
input W_En;
input En;
input clk;
output reg [DATA_W-1:0] Data_out;

//(* ram_style="ultra" *) reg [DATA_W-1:0] ram [DEPTH-1:0];
(* ram_style="block" *) reg [DATA_W-1:0] ram [DEPTH-1:0];
integer i;
//initial for (i=0; i<DEPTH; i=i+1) begin
initial for (i=0; i<DEPTH; i=i+1) begin
	ram[i] = 0;  	
end
always @(posedge clk) begin
	if (En) begin
		Data_out <= ram[R_Addr];
		if (W_En) begin
			ram[W_Addr] <= Data_in;
		end
	end	
end    
					
endmodule	

module bram #(
    parameter DATA = 1,
    parameter ADDR = 16
) (
    // Port A
    input   wire                clk,
    input   wire                a_wr,
    input   wire    [ADDR-1:0]  a_addr,
    input   wire    [DATA-1:0]  a_din,
    output  reg     [DATA-1:0]  a_dout,
     
    // Port B
    //input   wire                b_clk,
    input   wire                b_wr,
    input   wire    [ADDR-1:0]  b_addr,
    input   wire    [DATA-1:0]  b_din,
    output  reg     [DATA-1:0]  b_dout
);
 
(* ram_style="block" *) reg [DATA-1:0] mem [(2**ADDR)-1:0];
 
// Port A
always @(posedge clk) begin
    a_dout      <= mem[a_addr];
    if(a_wr) begin
        a_dout      <= a_din;
        mem[a_addr] <= a_din;
    end
end

// Port B
always @(posedge clk) begin
    b_dout      <= mem[b_addr];
    if(b_wr && (~a_wr || b_addr != a_addr)) begin
        b_dout      <= b_din;
        mem[b_addr] <= b_din;
    end
end

endmodule*/
module true_dual_port_ram_single_clock
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, we_b, clk,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the RAM variable
	(* ramstyle = "M20K" *)
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] = data_a;
		end
		q_a <= ram[addr_a];
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			ram[addr_b] = data_b;
		end
		q_b <= ram[addr_b];
	end

endmodule
