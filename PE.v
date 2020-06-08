module PE #(
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
	 	 begin: elements spmv_PP #(.PIPE_DEPTH(PIPE_DEPTH), .URAM_DATA_W(URAM_DATA_W), .PAR_SIZE_W(PAR_SIZE_W), .EDGE_W(EDGE_W)) pipeline (
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