module hdux1 # (
	parameter ADDR_W = 16,
	parameter Bank_Num_W = 5
)(
	input   wire clk,
	input   wire rst,
	input   wire [ADDR_W-1:0] Raddr0,	
	input   wire [ADDR_W-1:0] Waddr0,		
	input   wire Raddr_valid0,	
	input   wire Waddr_valid0,	
	output	wire stall_signal	
);
    
localparam Bank_Num = (2**Bank_Num_W);
localparam Port_Num = 1;

wire flag_valid0;
wire flag0;

wire [ADDR_W-Bank_Num_W-1:0] bank_raddr [Bank_Num-1:0];
wire [ADDR_W-Bank_Num_W-1:0] bank_waddr [Bank_Num-1:0];
wire [0:0] bank_rvalid [Bank_Num-1:0];
wire [0:0] bank_wvalid [Bank_Num-1:0];
wire [0:0] bank_fvalid [Bank_Num-1:0];
wire [0:0] bank_flag   [Bank_Num-1:0];

reg	 [Bank_Num_W-1:0] sel [Port_Num-1:0];
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
   begin: read_addr assign bank_raddr[i] = (Raddr_valid0 && Raddr0[Bank_Num_W-1:0] == i) ? Raddr0[ADDR_W-1: Bank_Num_W] : {(ADDR_W-Bank_Num_W){1'b0}};	  
   end 
endgenerate
	
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_addr assign bank_waddr[i] = (Waddr_valid0 && Waddr0[Bank_Num_W-1:0] == i) ? Waddr0[ADDR_W-1: Bank_Num_W] : {(ADDR_W-Bank_Num_W){1'b0}};	
   end 
endgenerate
																			
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: read_valid assign bank_rvalid[i] = (Raddr_valid0 && Raddr0[Bank_Num_W-1:0] == i) ? 1'b1 : 1'b0;
   end 
endgenerate
							
generate for(i=0; i<Bank_Num; i=i+1)  
   begin: write_valid assign bank_wvalid[i] = (Waddr_valid0 && Waddr0[Bank_Num_W-1:0] == i) ? 1'b1 : 1'b0;
   end 
endgenerate
							

wire stall;	
assign stall = (lock[0]<{(ADDR_W+1){1'b1}});
assign stall_signal = stall;
	
always @(posedge clk) begin
	if(rst) begin
		lock[0] <= {(ADDR_W+1){1'b1}};   			
	end else begin
		if(stall_signal) begin
			if((lock[0] == {1'b0, Waddr0} && Waddr_valid0)) begin
				lock[0] <= {(ADDR_W+1){1'b1}};
			end  
			
		end else begin
			if(Raddr_reg [0] && Raddr_valid_reg [0] && flag_valid0 && flag0) begin 
				lock[0] <= {1'b0, Raddr_reg [0]}; 
			end			
		end
	end
end
							

always @(posedge clk) begin
	if(rst) begin
		sel[0] <=0;		
		Raddr_reg [0] <= {(ADDR_W){1'b0}};		
		Raddr_valid_reg [0] <= 1'b0;		
	end else begin
		if(~stall) begin
			sel[0] <= Raddr0[Bank_Num_W-1:0];						
			Raddr_reg [0] <= Raddr0;			
			Raddr_valid_reg [0] <= Raddr_valid0;				
		end else begin
			sel[0] <= sel[0];									 
			Raddr_reg [0] <= Raddr_reg [0];			
			Raddr_valid_reg [0] <= Raddr_valid_reg [0];			
		end
	end
end

assign flag_valid0 = bank_fvalid[sel[0]];
assign flag0 = bank_flag[sel[0]];

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
 
 reg [DATA-1:0] mem [(2**ADDR)-1:0];
 
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
    );    
endmodule