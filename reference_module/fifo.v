module fifo #(
    parameter FIFO_WIDTH = 96,
    parameter FIFO_DEPTH_BITS = 8,
    parameter FIFO_ALMOSTFULL_THRESHOLD = 2**FIFO_DEPTH_BITS - 4,
    parameter FIFO_ALMOSTEMPTY_THRESHOLD = 2
) (
    input  wire                         clk,
    input  wire                         rst,    
    input  wire                         we,              // input   write enable
    input  wire [FIFO_WIDTH - 1:0]      din,            // input   write data with configurable width
    input  wire                         re,              // input   read enable    
    output reg  [FIFO_WIDTH - 1:0]      dout,            // output  read data with configurable width    
    output reg  [FIFO_DEPTH_BITS - 1:0] count,              // output  FIFOcount
    output reg                          empty,              // output  FIFO empty
    output reg                          almostempty,              // output  FIFO almost empty
    output reg                          full,               // output  FIFO full                
    output reg                          almostfull         // output  configurable programmable full/ almost full    
);
    reg                                 valid;
    reg                                 overflow;
    reg                                 underflow;        
    reg  [FIFO_DEPTH_BITS - 1:0]        rp;
    reg  [FIFO_DEPTH_BITS - 1:0]        wp;

`ifdef VENDOR_XILINX    
    (* ramstyle = "M20K" *)
    reg  [FIFO_WIDTH - 1:0]         mem[2**FIFO_DEPTH_BITS-1:0];
`else
    reg  [FIFO_WIDTH - 1:0]         mem[2**FIFO_DEPTH_BITS-1:0];
`endif
        
        
    always @(posedge clk) begin
        if (rst) begin
            empty <= 1'b1;
            almostempty <= 1'b1;
            full <= 1'b0;
            almostfull <= 1'b0;
            count <= 0;            
            rp <= 0;
            wp <= 0;
            valid <= 1'b0;
            overflow <= 1'b0;
            underflow <= 1'b0;            
        end else begin
            valid <= 0;          
            case ({we, re})
                2'b11 : begin
                    wp <= wp + 1'b1;                    
                    rp <= rp + 1'b1;
                    valid <= 1;
                end
                                
                2'b10 : begin
                    if (full) begin                                                                        
                        overflow <= 1;                                                
                    end else begin
                        wp <= wp + 1'b1;
                        count <= count + 1'b1;
                        empty <= 1'b0;
                        if (count == (FIFO_ALMOSTEMPTY_THRESHOLD-1))
                            almostempty <= 1'b0;
                            
                        if (count == (2**FIFO_DEPTH_BITS-1))
                            full <= 1'b1;

                        if (count == (FIFO_ALMOSTFULL_THRESHOLD-1))
                            almostfull <= 1'b1;
                    end
                end
                
                2'b01 : begin
                    if (empty) begin                                               
                        underflow <= 1;
                    end else begin
                        rp <= rp + 1'b1;
                        count <= count - 1'b1;                    
                        full <= 0;                    
                        if (count == FIFO_ALMOSTFULL_THRESHOLD)
                            almostfull <= 1'b0;                                            
                        if (count == 1)
                            empty <= 1'b1;                            
                        if (count == FIFO_ALMOSTEMPTY_THRESHOLD)
                            almostempty <= 1'b1;
							
                        valid <= 1;                          
                    end 
                end               
                default : begin
                end
            endcase
        end
    end


    always @(posedge clk) begin
        if (we == 1'b1)
            mem[wp] <= din;
            
        dout <= mem[rp];            
    end
    
endmodule
