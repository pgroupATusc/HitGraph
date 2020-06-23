
module tb_scatter;
    parameter PIPE_DEPTH = 3;
    parameter URAM_DATA_W = 32;
    parameter CLK_CYCLE = 10;
    reg                      clk;
    reg                      rst;    
    reg [31:0]               edge_weight;
    reg [URAM_DATA_W-1:0]    src_attr;
    reg [31:0]               edge_dest;
    reg [0:0]                input_valid;    
    wire [31:0]              update_value;
    wire [31:0]              update_dest;   
    wire [0:0]               output_valid;
    
    always #(0.5 * CLK_CYCLE) clk = ~ clk;
    spmv_scatter_pipe #(.PIPE_DEPTH(PIPE_DEPTH),.URAM_DATA_W(URAM_DATA_W))
    DUT
    (
       .clk(clk),
       .rst(rst),
       .edge_weight(edge_weight),
       .src_attr(src_attr),
       .edge_dest(edge_dest),
       .input_valid(input_valid),
       .update_value(update_value),
       .update_dest(update_dest),
        .output_valid(output_valid)
    );  
    initial begin: test
        clk = 1;
            rst = 1;
            #(3.5 * CLK_CYCLE)
            rst = 0;
            edge_weight = 32'd10;
            src_attr = 32'd20;
            edge_dest = 32'd8;
            input_valid = 1;
            
    end

endmodule
