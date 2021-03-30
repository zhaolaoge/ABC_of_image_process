/**********************************
copyright@FPGA OPEN SOURCE STUDIO
微信公众号：FPGA开源工作室
***********************************/

`timescale 1ns / 1ps
//`define pix_1920_1080
//`define pix_1280_768
`define pix_1280_720
//`define pix_800_600

`ifdef pix_1920_1080
	`define PERIOD 6.734
	`define PICTURE_LENGTH 1920   //Image width
	`define PICTURE_WIDTH  1080  //Image height
`endif

`ifdef pix_1280_768
	`define PERIOD 12.578
  	`define PICTURE_LENGTH 1280   //Image width
	`define PICTURE_WIDTH  768  //Image height
`endif

`ifdef  pix_1280_720
	`define PERIOD 13.468
  	`define PICTURE_LENGTH 1280   //Image width
	`define PICTURE_WIDTH  720  //Image height
`endif

`ifdef  pix_800_600
	`define PERIOD 25
	`define PICTURE_LENGTH 800   //Image width
	`define PICTURE_WIDTH  600  //Image height
`endif
`define INPUT1 "./in/1.bmp"  //input image
`define INPUT2 "./in/2.bmp"  //input image
`define INPUT3 "./in/3.bmp"  //input image

`define OUTPUT_FRAME1 "./out/result1.bmp" //result image frame1
`define OUTPUT_FRAME2 "./out/result2.bmp" //result image frame2
`define OUTPUT_FRAME3 "./out/result3.bmp" //result image frame3

`define PICTURE_MIX	(`PICTURE_LENGTH*`PICTURE_WIDTH*3)
`define PICTURE	(`PICTURE_LENGTH*`PICTURE_WIDTH)
`define PICTURE_R (`PICTURE_MIX + `LEN_HEADER)
`define NULL		0
`define LEN_HEADER	54  // 0x33
`define DATA_WIDTH  8
module tb_img_relifing();

reg clk;
reg reset_n;

integer 				fileI1,fileI2,fileI3;
integer                 fileO1,fileO2,fileO3;
integer i,k,m,n,h1,h2,h3;
reg	[`DATA_WIDTH-1:0]		FILE_HEADER1[0:`LEN_HEADER-1];//Image 1 Header
reg	[`DATA_WIDTH-1:0]		FILE_HEADER2[0:`LEN_HEADER-1];//Image 2 Header
reg	[`DATA_WIDTH-1:0]		FILE_HEADER3[0:`LEN_HEADER-1];//Image 3 Header

reg	[`DATA_WIDTH-1:0]		readsPictureB1[0:`PICTURE-1]; //Image1-- Blue Color Channel
reg	[`DATA_WIDTH-1:0]		readsPictureG1[0:`PICTURE-1]; //Image1-- Green Color Channel
reg	[`DATA_WIDTH-1:0]		readsPictureR1[0:`PICTURE-1]; //Image1-- Red Color Channel

reg	[`DATA_WIDTH-1:0]		readsPictureB2[0:`PICTURE-1]; //Image2-- Blue Color Channel
reg	[`DATA_WIDTH-1:0]		readsPictureG2[0:`PICTURE-1]; //Image2-- Green Color Channel
reg	[`DATA_WIDTH-1:0]		readsPictureR2[0:`PICTURE-1]; //Image2-- Red Color Channel

reg	[`DATA_WIDTH-1:0]		readsPictureB3[0:`PICTURE-1]; //Image3-- Blue Color Channel
reg	[`DATA_WIDTH-1:0]		readsPictureG3[0:`PICTURE-1]; //Image3-- Green Color Channel
reg	[`DATA_WIDTH-1:0]		readsPictureR3[0:`PICTURE-1]; //Image3-- Red Color Channel

reg  [31:0] 				addr;//Source image address
wire [`DATA_WIDTH-1:0]	  	SOURCE_B;
wire [`DATA_WIDTH-1:0]	  	SOURCE_G;
wire [`DATA_WIDTH-1:0]	  	SOURCE_R;
wire [`DATA_WIDTH*3-1:0]  	SOURCE_RGB;

wire                      	vga_clk;
wire [11:0]               	hcount;
wire [11:0]               	vcount;
wire [`DATA_WIDTH-1:0]	  	VGA_R;
wire [`DATA_WIDTH-1:0]	  	VGA_G;
wire [`DATA_WIDTH-1:0]	  	VGA_B;
wire		              	VGA_HS;
wire	                  	VGA_VS;
wire		              	VGA_DE;
wire                      	BLK;

reg 						VGA_VS_r;
wire frame_done_flag;

reg  [11:0] frame_cnt;
reg init_flag;

//Simulation Time Control
initial begin
    // Initialize Inputs
    clk = 0;
    reset_n = 0;
	wait(init_flag == 1'b1);
	$display("> Initial Done");
	reset_n = 1;
	wait(frame_cnt == 12'd4);
	#(`PERIOD*200);
	$display("> Simulate Done");
	$stop;	
end

always #(`PERIOD/2)	clk = ~clk;

//Read picture
always @(posedge clk)begin
	if(reset_n ==1'b0) begin
	    init_flag = 1'b0;
		for (i = 0; i < `PICTURE; i=i+1)begin
			readsPictureB1[i] = 0;
			readsPictureG1[i] = 0;
			readsPictureR1[i] = 0;  //image 1
			
			readsPictureB2[i] = 0;
			readsPictureG2[i] = 0;
			readsPictureR2[i] = 0;  //image 2
			
			readsPictureB3[i] = 0;
			readsPictureG3[i] = 0;
			readsPictureR3[i] = 0;  //image 3
		end
		$display("> Init Successful !");
		fileI1 = $fopen(`INPUT1,"rb");
		fileI2 = $fopen(`INPUT2,"rb");
		fileI3 = $fopen(`INPUT3,"rb");
		if (fileI1 == `NULL || fileI2 == `NULL || fileI3 == `NULL) 
			$display("> FAIL: The file is not exist !!!\n");
		else	           
			$display("> SUCCESS : The file was read successfully.\n");
					
		h1 = $fread(FILE_HEADER1, fileI1, 0, `LEN_HEADER);
		h2 = $fread(FILE_HEADER2, fileI2, 0, `LEN_HEADER);
		h3 = $fread(FILE_HEADER3, fileI3, 0, `LEN_HEADER);
		
	    for(m=0;m <`PICTURE;m=m+1) begin
			for(n=0;n<3;n=n+1)begin
				if(n== 0)readsPictureB1[m] = $fgetc(fileI1);//b
				if(n== 1)readsPictureG1[m] = $fgetc(fileI1);//g
				if(n== 2)readsPictureR1[m] = $fgetc(fileI1);//r 
				
				if(n== 0)readsPictureB2[m] = $fgetc(fileI2);//b
				if(n== 1)readsPictureG2[m] = $fgetc(fileI2);//g
				if(n== 2)readsPictureR2[m] = $fgetc(fileI2);//r 
				
				if(n== 0)readsPictureB3[m] = $fgetc(fileI3);//b
				if(n== 1)readsPictureG3[m] = $fgetc(fileI3);//g
				if(n== 2)readsPictureR3[m] = $fgetc(fileI3);//r 
     		end	
		end
		$display("> Read b,g,r Successful !");
		init_flag = 1'b1;
		$fclose(fileI1);
		$fclose(fileI2);
		$fclose(fileI3);
	end	
end

//Source Image Data
assign SOURCE_B = (frame_cnt == 12'd1)?readsPictureB1[addr]:
                  (frame_cnt == 12'd2)?readsPictureB2[addr]:  
				  (frame_cnt == 12'd3)?readsPictureB3[addr]:8'b0;
assign SOURCE_G = (frame_cnt == 12'd1)?readsPictureG1[addr]:
                  (frame_cnt == 12'd2)?readsPictureG2[addr]: 
				  (frame_cnt == 12'd3)?readsPictureG3[addr]:8'b0;
assign SOURCE_R = (frame_cnt == 12'd1)?readsPictureR1[addr]:
                  (frame_cnt == 12'd2)?readsPictureR2[addr]:   
				  (frame_cnt == 12'd3)?readsPictureR3[addr]:8'b0;
assign SOURCE_RGB = {SOURCE_R,SOURCE_G,SOURCE_B};

assign frame_done_flag = (!VGA_VS & (VGA_VS_r))?1'b1:1'b0;

always @(posedge clk)begin
	if(reset_n == 1'b0)
	  addr <= 0;
	else if(addr == `PICTURE-1)
	  addr <= 0;
	else if(VGA_DE == 1'b1)
	  addr <= addr+1;
end

always @(posedge clk ) begin
  VGA_VS_r <= VGA_VS;
end

//Frame counter
always @(posedge clk or negedge reset_n) begin
  if(reset_n == 1'b0)
    frame_cnt <= 12'd0;
  else if(frame_done_flag ==1'b1)
    frame_cnt <= frame_cnt + 12'd1;
end
//--------------------------------------------------------
//DUT Start
//--------------------------------------------------------
//Vga 

vga_ctl U_VGA(
	.pix_clk(clk),
	.reset_n(reset_n),
	.VGA_RGB(SOURCE_RGB),//i
	.VGA_CLK(vga_clk),
	.hcount(hcount),
	.vcount(vcount),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_DE(VGA_DE),
	.BLK(BLK)
	);

////////////////////////////
wire[7:0] y,cb,cr;
wire ycbcr_hs,ycbcr_vs,ycbcr_en;
rgb2ycbcr u4(
	.r(VGA_R),
	.g(VGA_G),
	.b(VGA_B),
	.y(y),
	.cb(cb),
	.cr(cr),	
	.clk(clk),
	.nrst(reset_n),
	.in_hsync(VGA_HS),
	.in_vsync(VGA_VS),
	.in_en(VGA_DE),
	.out_hsync(ycbcr_hs),
	.out_vsync(ycbcr_vs),
	.out_en(ycbcr_en)
);

wire [7:0] relifed_data;
wire relifed_hsync,relifed_vsync,relifed_de;
image_relifing  u5(
    .clk(clk),
    .nrst(reset_n),
    .in_data(y),				//gray in
    .hsync(ycbcr_hs),
    .vsync(ycbcr_vs),
    .de(ycbcr_en),
    .out_data(relifed_data),		//relifed out
    .o_hsync(relifed_hsync),
    .o_vsync(relifed_vsync),
    .o_de(relifed_de)
);
//////////////////////////////////
//--------------------------------------------------------
//DUT End
//--------------------------------------------------------

//Write Picture
/*
always@(posedge clk)begin
	if(reset_n ==1'b0) begin
		fileO1 = $fopen(`OUTPUT_FRAME1,"wb");
		fileO2 = $fopen(`OUTPUT_FRAME2,"wb");
		fileO3 = $fopen(`OUTPUT_FRAME3,"wb");		
		for(k=0; k<`LEN_HEADER; k=k+1)begin
	   		$fwrite(fileO1, "%c", FILE_HEADER1[k]);//frame 1 header
			$fwrite(fileO2, "%c", FILE_HEADER1[k]);
			$fwrite(fileO3, "%c", FILE_HEADER1[k]);
	   	end	
	end
	else if(VGA_DE == 1'b1)begin
	  if(frame_cnt == 12'd1)$fwrite(fileO1, "%c%c%c", VGA_B[7:0],VGA_G[7:0],VGA_R[7:0]);//frame 1 b,g,r
	  if(frame_cnt == 12'd2)$fwrite(fileO2, "%c%c%c", VGA_B[7:0],VGA_G[7:0],VGA_R[7:0]);
	  if(frame_cnt == 12'd3)$fwrite(fileO3, "%c%c%c", VGA_B[7:0],VGA_G[7:0],VGA_R[7:0]);
	end
end
*/
always@(posedge clk)begin
	if(reset_n ==1'b0) begin
		fileO1 = $fopen(`OUTPUT_FRAME1,"wb");
		fileO2 = $fopen(`OUTPUT_FRAME2,"wb");
		fileO3 = $fopen(`OUTPUT_FRAME3,"wb");		
		for(k=0; k<`LEN_HEADER; k=k+1)begin
	   		$fwrite(fileO1, "%c", FILE_HEADER1[k]);//frame 1 header
			$fwrite(fileO2, "%c", FILE_HEADER1[k]);
			$fwrite(fileO3, "%c", FILE_HEADER1[k]);
	   	end	
	end
	else if(relifed_de == 1'b1)begin
//	  if(frame_cnt == 12'd1)$fwrite(fileO1, "%c%c%c", y[7:0],y[7:0],y[7:0]);//frame 1 b,g,r
//	  if(frame_cnt == 12'd2)$fwrite(fileO2, "%c%c%c", y[7:0],y[7:0],y[7:0]);
//	  if(frame_cnt == 12'd3)$fwrite(fileO3, "%c%c%c", y[7:0],y[7:0],y[7:0]);
//	  if(frame_cnt == 12'd1)$fwrite(fileO1, "%c%c%c",(8'hff-y[7:0]),(8'hff-y[7:0]),(8'hff-y[7:0]));//gray_inversed
//	  if(frame_cnt == 12'd2)$fwrite(fileO2, "%c%c%c",(8'hff-y[7:0]),(8'hff-y[7:0]),(8'hff-y[7:0]));
//	  if(frame_cnt == 12'd3)$fwrite(fileO3, "%c%c%c",(8'hff-y[7:0]),(8'hff-y[7:0]),(8'hff-y[7:0]));
	  if(frame_cnt == 12'd1)$fwrite(fileO1, "%c%c%c",relifed_data,relifed_data,relifed_data);//binary_gary
	  if(frame_cnt == 12'd2)$fwrite(fileO2, "%c%c%c",relifed_data,relifed_data,relifed_data);
	  if(frame_cnt == 12'd3)$fwrite(fileO3, "%c%c%c",relifed_data,relifed_data,relifed_data);
	end
end
endmodule
