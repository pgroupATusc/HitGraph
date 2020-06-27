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
   /* bram # (.DATA(1),  .ADDR(ADDR_W))
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
    );    */
	 m20k bram(
		  .clock(clk),
        .wren_a(Raddr_valid),
        .address_a(Raddr),
        .data_a(1'b1),
        .q_a(bram_flag_outA),
        .wren_b(Waddr_valid),
        .address_b(Waddr),
        .data_b(1'b0),
        .q_b(bram_flag_outB)		
	  ); 
endmodule





