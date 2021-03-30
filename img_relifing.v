module image_relifing(
    input	clk,
    input	nrst,
    input	[7:0]	in_data,				//gray in
    input	hsync,
    input	vsync,
    input	de,
    output	[7:0]	out_data,		//relifed out
    output	o_hsync,
    output	o_vsync,
    output	o_de
);
localparam   therholds = 8'd50;

reg [7:0]	in_data_r,new_data;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		in_data_r	<=	7'd0;
		new_data	<=	7'd0;
	end
	else begin
		in_data_r	<=	in_data;
		new_data	<=	in_data	-	in_data_r	+	therholds;
	end
end

reg	[7:0]new_data_r;
always@(posedge	clk	or negedge	nrst)begin
	if(!nrst)
		new_data_r	<=	8'd0;
	else if(new_data	>	8'd255)
		new_data_r	<=	8'd255;
	else if(new_data	<	8'd0)
		new_data_r	<=8'd0;
	else
		new_data_r	<=	new_data;
end

reg	hsync_r,vsync_r,de_r,hsync_rr,vsync_rr,de_rr,hsync_rrr,vsync_rrr,de_rrr;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		hsync_r	<=	1'b0;
		vsync_r	<=	1'b0;
		de_r	<=	1'b0;
		hsync_rr	<=	1'b0;
		vsync_rr	<=	1'b0;
		de_rr	<=	1'b0;
		hsync_rrr	<=	1'b0;
		vsync_rrr	<=	1'b0;
		de_rrr	<=	1'b0;
	end
	else begin
		hsync_r	<=	hsync;
		vsync_r	<=	vsync;
		de_r	<=	de;
		hsync_rr	<=	hsync_r;
		vsync_rr	<=	vsync_r;
		de_rr	<=	de_r;
		hsync_rrr	<=	hsync_rr;
		vsync_rrr	<=	vsync_rr;
		de_rrr	<=	de_rr;
	end
end

assign out_data	=	new_data_r;
assign	o_hsync	=	hsync_rrr;
assign	o_vsync	=	vsync_rrr;
assign	o_de	=	de_rrr;
endmodule		
		
		
		
		
		