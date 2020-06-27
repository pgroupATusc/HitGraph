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