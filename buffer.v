`timescale 1ns / 1ps
module buffer(
       input	clk,
       input	nrst,
       input	hsync,
       input	vsync,
       input	de,
       input	[7:0]	in_data,
       output	o_hsync,
       output	o_vsync,
	   output	o_de,
	   output	[23:0]	out_data
);
parameter data_width = 8;
parameter image_width = 1280;
parameter line_number  = 3;

reg hsync_r,vsync_r,de_r;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		hsync_r	<=	1'd0;
		vsync_r	<=	1'd0;
		de_r	<=	1'd0;
	end
	else begin
		hsync_r	<=	hsync;
		vsync_r	<=	vsync;
		de_r	<=	de;
	end
end
assign o_hsync = hsync_r;
assign o_vsync = vsync_r;
assign o_de = de_r;


reg	[7:0] line1_data,line2_data,line3_data;
reg	en_1,en_2,en_3;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		line1_data	<=	8'd0;
		line2_data	<=	8'd0;
		line3_data	<=	8'd0;
		en_1		<=	1'b0;
		en_2		<=	1'b0;
		en_3		<=	1'b0;
	end
	else begin
		line1_data	<=	in_data;
		line2_data	<=	line1_data;
		line3_data	<=	line2_data;
		en_1		<=	de;
		en_2		<=	en_1;
		en_3		<=	en_2;
	end
end

wire  vsync_negedge ;
assign vsync_negedge	=	(vsync_r&& !vsync)	?	1'b1:1'b0;
wire	[7:0]	line1_out,line2_out,line3_out;
line #( 
      .DW(data_width),
      .IW(image_width)
	) line1(
        .clk(clk),
        .reset_n(nrst),
         .vsync_neg_flag(vsync_negedge),
         .i_de(en_1),
         .o_de(),
         .din(line1_data),
         .dout(line1_out)
           );
		
line #( 
      .DW(data_width),
      .IW(image_width)
	) line2(
        .clk(clk),
        .reset_n(nrst),
         .vsync_neg_flag(vsync_negedge),
         .i_de(en_2),
         .o_de(),
         .din(line2_data),
         .dout(line2_out)
           );
		   
line #( 
      .DW(data_width),
      .IW(image_width)
	) line3(
        .clk(clk),
        .reset_n(nrst),
         .vsync_neg_flag(vsync_negedge),
         .i_de(en_3),
         .o_de(),
         .din(line3_data),
         .dout(line3_out)
           );

reg	[23:0]	sum_output;
always@(posedge clk or negedge nrst)begin
	if(!nrst)
		sum_output	<=	24'd0;
	else
		sum_output	<=	{line1_out,line2_out,line3_out};
end
assign out_data = sum_output;
endmodule