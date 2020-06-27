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
