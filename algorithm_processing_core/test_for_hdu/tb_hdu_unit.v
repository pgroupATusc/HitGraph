

module tb_hdu_unit;
    parameter DATA = 1;
    parameter ADDR_W = 16;
    parameter CLK_CYCLE = 10;
    parameter Bank_Num_W = 5;
    
    reg clk;
	reg rst;
	reg [ADDR_W-1:0] Raddr0;
	reg [ADDR_W-1:0] Waddr0;
	reg Raddr_valid0;
	reg Waddr_valid0;
	//wire  flag_valid;
	//wire  flag;
	wire    stall_signal;
    
    always #(0.5 * CLK_CYCLE) clk = ~ clk;
     
    hdux1 #(
        .ADDR_W(ADDR_W),
        .Bank_Num_W(Bank_Num_W)
    )
    DUT(
        .clk(clk),
        .rst(rst),
        .Raddr0(Raddr0),
        .Waddr0(Waddr0),
        .Raddr_valid0(Raddr_valid0),
        .Waddr_valid0(Waddr_valid0),
        //.flag_valid(flag_valid),
        //.flag(flag)
        .stall_signal(stall_signal)
    );
    
    initial
    begin: test
        clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE);
        rst = 0;
        Raddr0 = 16'd10;
        Raddr_valid0 = 1;
        Waddr0 = 16'd5;
        Waddr_valid0 = 1;
        #(CLK_CYCLE);
        Raddr0 = 16'd10;
        Raddr_valid0 = 1;
        Waddr0 = 16'd6;
        Waddr_valid0 = 1;
    end

endmodule
