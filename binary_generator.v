module binary_generator(
	input clk,
	input nrst,
	input [7:0] threshold,
	input [7:0] in_gary,
	input in_hsync,
	input in_vsync,
	input in_en,
	output [7:0] out_gary,
	output out_hsync,
	output out_vsync,
	output out_en
);

reg [7:0]  gary_temp;

always@(posedge clk or negedge nrst)begin
	if(!nrst)
		gary_temp	<= 8'd0;
	else if (in_gary  <  threshold)
		gary_temp	<= 8'h00;
	else
		gary_temp	<=	8'hff;
end

assign out_gary	=	gary_temp ;

reg hsync_r,vsync_r,en_r;
//reg hsync_rr,vsync_rr,en_rr;

always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		hsync_r	<=	1'b0;
		vsync_r	<=	1'b0;
		en_r	<=	1'b0;
//		hsync_rr	<=	1'b0;
//		vsync_rr	<=	1'b0;
//		en_rr	<=	1'b0;
	end
	else begin
		hsync_r	<=	in_hsync;
		vsync_r	<=	in_vsync;
		en_r	<=	in_en;
//		hsync_rr	<=	hsync_r;
//		vsync_rr	<=	vsync_r;
//		en_rr	<=	en_r;
	end
end
assign out_hsync  = hsync_r;
assign out_vsync  = vsync_r;
assign out_en = en_r;
endmodule		