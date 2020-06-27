module combining_networkx8 # (
	parameter DATA_W = 32,
	parameter PIPE_DEPTH = 5,
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