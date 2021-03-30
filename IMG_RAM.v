//local ram 
module IMG_RAM#(
       parameter IMG_WIDTH_DATA = 24,
       parameter IMG_WIDTH_LINE = 800
	   )(
       input                       clk,
	   input                       reset_n,
	   input                       we,
	   //input                       rd,
	   input  [10:0]               waddr,
       input  [10:0]               raddr,
       input  [IMG_WIDTH_DATA-1:0] din,
       output [IMG_WIDTH_DATA-1:0] dout	   
	   );
	   
reg	[IMG_WIDTH_DATA-1:0]   mem[0:IMG_WIDTH_LINE-1];

reg [IMG_WIDTH_DATA-1:0]   rdata;
assign dout = rdata;

integer n;
always @(posedge clk or negedge reset_n) begin
  if(!reset_n) begin
    for(n = 0; n <2048; n = n+1) mem[n] <= 0;//sim only
    rdata <= 0;
  end
  else begin
  	//if(rd) rdata <= mem[raddr]; 
  	rdata <= mem[raddr]; 
    if(we) mem[waddr] <= din;
  end
end

endmodule