 `define data_width 8
 `define dimension 16
 `timescale 1ns/1ps

module tb_test_for_CaC;
    parameter DATA_W = 32;
	parameter PIPE_DEPTH = 3;
    parameter CLK_CYCLE = 5; // cycle time
    parameter seed = 1;
    
    reg         		clk;
    reg         		rst;
    reg  [0:0]         	InputValid_A;
    reg  [0:0]         	InputValid_B;
	reg  [DATA_W-1:0]   	InDestVid_A;
    reg  [DATA_W-1:0]   	InDestVid_B;
    reg  [DATA_W-1:0]   	InUpdate_A;
    reg  [DATA_W-1:0]   	InUpdate_B;
    wire [DATA_W-1:0]   	OutUpdate_A;
    wire [DATA_W-1:0]   	OutUpdate_B;
	wire [DATA_W-1:0]  	OutDestVid_A;
    wire [DATA_W-1:0]  	OutDestVid_B;
    wire [0:0]  			OutValid_A;
	wire [0:0]  			OutValid_B;
	
	wire [0:0]   	Valid_reg_A0;
    wire [0:0]   	Valid_reg_A1;
    wire [0:0]   	Valid_reg_A2;
    wire [DATA_W-1:0]   	DestVid_reg_A0;
    wire [DATA_W-1:0]   	DestVid_reg_A1;
    wire [DATA_W-1:0]   	DestVid_reg_A2;
    wire [DATA_W-1:0]   	Update_reg_A0;
    wire [DATA_W-1:0]   	Update_reg_A1;
    wire [DATA_W-1:0]   	Update_reg_A2;
    wire [0:0]   	Valid_reg_B0;
    wire [0:0]   	Valid_reg_B1;
    wire [0:0]   	Valid_reg_B2;
    wire [DATA_W-1:0]   	DestVid_reg_B0;
    wire [DATA_W-1:0]   	DestVid_reg_B1;
    wire [DATA_W-1:0]   	DestVid_reg_B2;
    wire [DATA_W-1:0]   	Update_reg_B0;
    wire [DATA_W-1:0]   	Update_reg_B1;
    wire [DATA_W-1:0]   	Update_reg_B2;
	

    reg [0:0] ValidA;
    reg [0:0] ValidB;
    reg [DATA_W-1:0] DESTVIDA;
    reg [DATA_W-1:0] DESTVIDB;
    reg [DATA_W-1:0] UpdateA;
    reg [DATA_W-1:0] UpdateB;
    
    initial
    begin: init_metrix
        ValidA = 1;
        ValidB = 1;
        DESTVIDA = 120;
        DESTVIDB = 120;
        UpdateA = 7;
        UpdateB = 5;
    end
    always #(0.5 * CLK_CYCLE) clk = ~ clk;

    // Instanation
    test_for_CaC #(
        .DATA_W(DATA_W),
        .PIPE_DEPTH(PIPE_DEPTH)
    )
    CaC_dut(
        .clk(clk),
        .rst(rst),    
        .InputValid_A(InputValid_A),
        .InputValid_B(InputValid_B),
	    .InDestVid_A(InDestVid_A),
        .InDestVid_B(InDestVid_B),
        .InUpdate_A(InUpdate_A),
        .InUpdate_B(InUpdate_B),
        .OutUpdate_A(OutUpdate_A),
        .OutUpdate_B(OutUpdate_B),
	    .OutDestVid_A(OutDestVid_A),
        .OutDestVid_B(OutDestVid_B),
        .OutValid_A(OutValid_A),
	    .OutValid_B(OutValid_B),
	    
	    .Valid_reg_A0(Valid_reg_A0),
	    .Valid_reg_A1(Valid_reg_A1),
	    .Valid_reg_A2(Valid_reg_A2),
	    .DestVid_reg_A0(DestVid_reg_A0),
	    .DestVid_reg_A1(DestVid_reg_A1),
	    .DestVid_reg_A2(DestVid_reg_A2),
	    .Update_reg_A0(Update_reg_A0),
	    .Update_reg_A1(Update_reg_A1),
	    .Update_reg_A2(Update_reg_A2),
	    .Valid_reg_B0(Valid_reg_B0),
	    .Valid_reg_B1(Valid_reg_B1),
	    .Valid_reg_B2(Valid_reg_B2),
	    .DestVid_reg_B0(DestVid_reg_B0),
	    .DestVid_reg_B1(DestVid_reg_B1),
	    .DestVid_reg_B2(DestVid_reg_B2),
	    .Update_reg_B0(Update_reg_B0),
	    .Update_reg_B1(Update_reg_B1),
	    .Update_reg_B2(Update_reg_B2)
    );
        

    

    integer log_file;
    initial 
    begin: test
        log_file = $fopen("CaC.res", "w");
        $fdisplay(log_file, " Input Content:");
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " InputValid_A  ");
        $fwrite(log_file, "%3d", InputValid_A);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " InDestVid_A  ");
        $fwrite(log_file, "%3d", InDestVid_A);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " InUpdate_A  ");
        $fwrite(log_file, "%3d", InUpdate_A);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " InputValid_B  ");
        $fwrite(log_file, "%3d", InputValid_B);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " InDestVid_B  ");
        $fwrite(log_file, "%3d", InDestVid_B);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " InUpdate_B  ");
        $fwrite(log_file, "%3d", InUpdate_B);
        $fwrite(log_file, "\n");
        clk = 1;
        rst = 1;
        #(3.5 * CLK_CYCLE)
        rst = 0;
        InputValid_A = ValidA;
        InDestVid_A = DESTVIDA;
        InUpdate_A = UpdateA;
        InputValid_B = ValidB;
        InDestVid_B = DESTVIDB;
        InUpdate_B = UpdateB;
        #(CLK_CYCLE);
        //InputValid_A = 0;
        //InDestVid_A = 0;
        //InUpdate_A = 0;
        //InputValid_B = 0;
        //InDestVid_B = 0;
        //InUpdate_B = 0;
       #(2 * `dimension * CLK_CYCLE);
       $fdisplay(log_file, "The result metrix is:");
       $fwrite(log_file, "\n");
        $fdisplay(log_file, " OutValid_A  ");
        $fwrite(log_file, "%3d", OutValid_A);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " OutDestVid_A  ");
        $fwrite(log_file, "%3d", OutDestVid_A);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " OutUpdate_A  ");
        $fwrite(log_file, "%3d", OutUpdate_A);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " OutValid_B  ");
        $fwrite(log_file, "%3d", OutValid_B);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " OutDestVid_B  ");
        $fwrite(log_file, "%3d", OutDestVid_B);
        $fwrite(log_file, "\n");
        $fdisplay(log_file, " OutUpdate_B  ");
        $fwrite(log_file, "%3d", OutUpdate_B);
        $fwrite(log_file, "\n");
    end
endmodule
