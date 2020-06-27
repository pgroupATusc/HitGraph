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
