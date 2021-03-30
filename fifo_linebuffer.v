
`timescale 1ns/1ps
/*
Module name:  fifo_linebuffer.v
Description: 
              
Data:         2018/11/19
Engineer:     lipu
e-mail:       137194782@qq.com 
微信公众号：    FPGA开源工作室
*/
module fifo_linebuffer#(
       parameter IMG_WIDTH_DATA = 24,
	   parameter IMG_WIDTH_LINE = 800
       )(
       input clk,
	   input reset_n,
	   input we,
	   input rd,
	   input  [IMG_WIDTH_DATA-1:0] din,
       output [IMG_WIDTH_DATA-1:0] dout	 
	   );

reg  [10:0]               waddr;
reg  [10:0]               raddr;

always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    waddr <= 11'b0;
	raddr <= 11'b0;
  end
  else begin
    if(we == 1'b1)
	  if(waddr == IMG_WIDTH_LINE -1)
	    waddr <= 11'b0;
      else
        waddr <= waddr + 11'b1;
    
    if(rd == 1'b1)
	  if(raddr == IMG_WIDTH_LINE -1)
	    raddr <= 11'b0;
      else
        raddr <= raddr + 11'b1;	
  end
end


//image line buffer ram
IMG_RAM#(
       .IMG_WIDTH_DATA(IMG_WIDTH_DATA),
       .IMG_WIDTH_LINE(IMG_WIDTH_LINE)
	   )U_IMG_RAM(
       .clk(clk),
	   .reset_n(reset_n),
	   .we(we),
	   //.rd(rd),
	   .waddr(waddr),
       .raddr(raddr),
       .din(din),
       .dout(dout)	   
	   );
	   
endmodule


