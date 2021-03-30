module rgb2ycbcr(
	input [7:0]  r,
	input [7:0]  g,
	input [7:0]  b,
	output [7:0] y,
	output [7:0] cb,
	output [7:0] cr,
	
	input clk,
	input nrst,
	
	input in_hsync,
	input in_vsync,
	input in_en,
	output out_hsync,
	output out_vsync,
	output out_en
);
reg[17:0] mult_y_r,mult_y_g,mult_y_b;
reg[17:0] mult_cb_r,mult_cb_g,mult_cb_b;
reg[17:0] mult_cr_r,mult_cr_g,mult_cr_b;

localparam  f_0183 = 10'd47;
localparam  f_0614 = 10'd157;
localparam  f_0062 = 10'd16;
localparam  f_16 = 18'd4096;
localparam  f_0101 = 10'd26;
localparam  f_0338 = 10'd87;
localparam  f_0439 = 10'd112;
localparam  f_128 = 18'd32768;
localparam  f_0399 = 10'd102;
localparam  f_0040 = 10'd10;


always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		mult_y_r <= 18'd0;
		mult_y_g <= 18'd0;
		mult_y_b <= 18'd0;
		mult_cb_r<= 18'd0;
		mult_cb_g<= 18'd0;
		mult_cb_b<= 18'd0;
		mult_cr_r<= 18'd0;
		mult_cr_g<= 18'd0;
		mult_cr_b<= 18'd0;
		end
	else begin
		mult_y_r <= f_0183*r;
		mult_y_g <= f_0614*g;
		mult_y_b <= f_0062*b;
		mult_cb_r<= f_0101*r;
		mult_cb_g<= f_0338*g;
		mult_cb_b<= f_0439*b;
		mult_cr_r<= f_0439*r;
		mult_cr_g<= f_0399*g;
		mult_cr_b<= f_0040*b;
		end
end

reg[17:0] add_y1,add_cb1,add_cr1,add_y2,add_cb2,add_cr2; //必须降低组合逻辑延时

always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		add_y1 <= 18'd0;
		add_cb1 <= 18'd0;
		add_cr1 <= 18'd0;
		add_y2 <= 18'd0;
		add_cb2 <= 18'd0;
		add_cr2 <= 18'd0;
		end
	else begin
		add_y1 <= mult_y_r+mult_y_g;
		add_cb1 <= mult_cb_r+mult_cb_g;
		add_cr1 <= mult_cr_g+mult_cr_b;
		add_y2 <= mult_y_b+f_16;
		add_cb2 <= mult_cb_b+f_128;
		add_cr2 <= mult_cr_r+f_128;
		end
end

assign compare_1 = (add_cb2 >= add_cb1) ? 1'b1 : 1'b0 ;
assign compare_2 = (add_cr2 >= add_cr1) ? 1'b1 : 1'b0 ;

reg	[17:0] y_result,cb_result,cr_result;
 
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		y_result <= 18'd0;
		cb_result <= 18'd0;
		cr_result <= 18'd0;
		end
	else begin
		y_result <= add_y1 + add_y2;
		cb_result <= (compare_1 == 1'b1) ? (add_cb2 - add_cb1) : 18'd0;
		cr_result <= (compare_2 == 1'b1) ? (add_cr2 - add_cr1) : 18'd0;
		end
end

reg [9:0] y_size,cb_size,cr_size;
always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		y_size <= 10'd0;
		cb_size<= 10'd0;
		cr_size<= 10'd0;
		end
	else begin
		y_size <= y_result[17:8] +{9'd0,y_result[7]};
		cb_size <= cb_result[17:8] +{9'd0,cb_result[7]};
		cr_size <= cr_result[17:8] +{9'd0,cr_result[7]};
		end
end

assign y = (y_size[9:8] == 2'b00) ? y_size[7:0] : 8'hff;
assign cb = (cb_size[9:8] == 2'b00) ? cb_size[7:0] : 8'hff;
assign cr = (cr_size[9:8] == 2'b00) ? cr_size[7:0] : 8'hff;
///////////////////////////////////////////////////////////////////
reg in_hsync_r,in_vsync_r,in_en_r,in_hsync_rr,in_vsync_rr,in_en_rr,in_hsync_rrr,in_vsync_rrr,in_en_rrr;
reg in_hsync_rrrr,in_vsync_rrrr,in_en_rrrr;

always@(posedge clk or negedge nrst)begin
	if(!nrst)begin
		in_hsync_r <= 1'b0;
		in_hsync_rr <= 1'b0;
		in_hsync_rrr <= 1'b0;
		in_hsync_rrrr <= 1'b0;
		in_vsync_r <= 1'b0;
		in_vsync_rr <= 1'b0;
		in_vsync_rrr <= 1'b0;
		in_vsync_rrrr <= 1'b0;
		in_en_r <= 1'b0;
		in_en_rr <= 1'b0;
		in_en_rrr <= 1'b0;
		in_en_rrrr <= 1'b0;
		end
	else begin
		in_hsync_r <= in_hsync;
		in_hsync_rr <= in_hsync_r;
		in_hsync_rrr <= in_hsync_rr;
		in_hsync_rrrr <= in_hsync_rrr;
		in_vsync_r <= in_vsync;
		in_vsync_rr <= in_vsync_r;
		in_vsync_rrr <= in_vsync_rr;
		in_vsync_rrrr <= in_vsync_rrr;
		in_en_r <= in_en;
		in_en_rr<= in_en_r;
		in_en_rrr <= in_en_rr;
		in_en_rrrr <= in_en_rrr;
		end
end

assign out_hsync = in_hsync_rrrr;
assign out_vsync = in_vsync_rrrr;
assign out_en    = in_en_rrrr;
	
endmodule		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		




		
	