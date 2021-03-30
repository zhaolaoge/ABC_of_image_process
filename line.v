`timescale 1ns/1ps

module line#(
       parameter DW = 8,
       parameter IW = 1920
       )(
       input         clk,//pixel clock
       input         reset_n,
       input         vsync_neg_flag,
       input         i_de,
       output        o_de,
       input  [DW-1:0]  din,
       output [DW-1:0]  dout
       );
         
reg [10:0] cnt;
wire rd_en;

always @(posedge clk or negedge reset_n) begin
  if(!reset_n)
    cnt <= 11'd0;
  else if(vsync_neg_flag)
    cnt <= 11'd0;
  else if(cnt == IW-1)
    cnt <= IW-1;
  else if(i_de)
    cnt <= cnt + 11'd1;
  else
    cnt <= cnt;
end

assign rd_en = ((cnt == IW-1) && (i_de == 1'b1)) ? 1'b1:1'b0;
assign o_de = rd_en;

/*
fifo_generator_0 U_FIFO(
                 .clk(clk),
                 .srst(~reset_n),
                 .din(din),
                 .wr_en(i_de),
                 .rd_en(rd_en),
                 .dout(dout),
                 .full(),
                 .empty()
  );
*/
fifo_linebuffer#(
       .IMG_WIDTH_DATA(DW),
	   .IMG_WIDTH_LINE(IW)
       )U_fifo_linebuffer(
       .clk(clk),
	   .reset_n(reset_n),
	   .we(i_de),
	   .rd(rd_en),
	   .din(din),
       .dout(dout)	 
	   );
endmodule
