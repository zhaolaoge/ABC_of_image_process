module average_filtering(
	input	clk,
	input	nrst,
	input	hsync,
	input	vsync,
	input	en,
	input	[23:0]	in_data,
	output	o_hsync,
	output	o_vsync,
	output	o_en,
	output	[7:0]	out_data
);

reg	[23:0]	in_data_r,in_data_rr;
reg [10:0]	results;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		in_data_r	<=	24'd0;
		in_data_rr	<=	24'd0;
		results		<=	24'd0;
	end
	else begin
		in_data_r	<=	in_data;
		in_data_rr	<=	in_data_r;
		results		<=	((in_data[23:16] + in_data[15:8]) + (in_data [7:0] + in_data_r[23:16])) + ((in_data_r [7:0] + in_data_rr[23:16]) + (in_data_rr[15:8] + in_data_rr[7:0]));
	end
end

assign out_data	=	results >> 3 ;

reg hsync_r,vsync_r,en_r,hsync_rr,vsync_rr,en_rr,hsync_rrr,vsync_rrr,en_rrr;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		hsync_r	<=	1'b0;
		vsync_r	<=	1'b0;
		en_r	<=	1'b0;
		hsync_rr	<=	1'b0;
		vsync_rr	<=	1'b0;
		en_rr	<=	1'b0;
		hsync_rrr	<=	1'b0;
		vsync_rrr	<=	1'b0;
		en_rrr	<=	1'b0;
		end
	else begin
		hsync_r	<=	hsync;
		vsync_r	<=	vsync;
		en_r	<=	en;
		hsync_rr	<=	hsync_r;
		vsync_rr	<=	vsync_r;
		en_rr	<=	en_r;
		hsync_rrr	<=	hsync_rr;
		vsync_rrr	<=	vsync_rr;
		en_rrr	<=	en_rr;
	end
end

assign	o_hsync	=	hsync_rrr;
assign	o_vsync	=	vsync_rrr;
assign	o_en	=	en_rrr;

endmodule
