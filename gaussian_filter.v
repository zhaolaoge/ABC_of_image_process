module gaussian_filter(
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
reg [10:0]	line1_sum,line2_sum,line3_sum;
reg [11:0]	sum;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		in_data_r	<=	24'd0;
		in_data_rr	<=	24'd0;
		line1_sum	<=	11'd0;
		line2_sum	<=	11'd0;
		line3_sum	<=	11'd0;
		sum			<=	12'd0;
	end
	else begin
		in_data_r	<=	in_data;
		in_data_rr	<=	in_data_r;
		line1_sum	<=	(in_data[23:16] + in_data[15:8]) + (in_data[15:8] + in_data[7:0]);
		line2_sum	<=	((in_data_r[23:16]+in_data_r[23:16])+(in_data_r[15:8]+in_data_r[15:8]))+((in_data_r[15:8]+in_data_r[15:8])+(in_data_r[7:0]+in_data_r[7:0]));
		line3_sum	<=	(in_data_rr[23:16] + in_data_rr[15:8]) + (in_data_rr[15:8] + in_data_rr[7:0]);
		sum			<=	line1_sum	+	line2_sum	+	line3_sum;
	end
end
assign out_data	=	sum	>>	4;


reg hsync_r1,hsync_r2,hsync_r3,vsync_r1,vsync_r2,vsync_r3;
reg en_r1,en_r2,en_r3;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		hsync_r1	<=	1'b0;
		hsync_r2	<=	1'b0;
		hsync_r3	<=	1'b0;
		vsync_r1	<=	1'b0;
		vsync_r2	<=	1'b0;
		vsync_r3	<=	1'b0;
		en_r1	<=	1'b0;
		en_r2	<=	1'b0;
		en_r3	<=	1'b0;
	end
	else begin
		hsync_r1	<=	hsync;
		hsync_r2	<=	hsync_r1;
		hsync_r3	<=	hsync_r2;
		vsync_r1	<=	vsync;
		vsync_r2	<=	vsync_r1;
		vsync_r3	<=	vsync_r2;
		en_r1	<=	en;
		en_r2	<=	en_r1;
		en_r3	<=	en_r2;
	end
end
assign	o_hsync	=	hsync_r3;
assign	o_vsync	=	vsync_r3;
assign	o_en	=	en_r3;

endmodule