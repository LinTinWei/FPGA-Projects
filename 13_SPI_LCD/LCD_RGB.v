///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: LCD_RGB.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::256 VF>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>
`timescale 1ns / 1ps
module LCD_RGB #
(
	parameter LCD_W = 8'd240,			//???????
	parameter LCD_H = 8'd240			//???????
)
(
	input				clk_in,			//12MHz????
	input				rst_n_in,		//????????
 
	output	reg			ram_lcd_clk_en,	//RAM????
	output	reg	[7:0]	ram_lcd_addr,	//RAM????
	input		[131:0]	ram_lcd_data,	//RAM????
 
	output	reg			lcd_rst_n_out,	//LCD?????
	output	reg			lcd_bl_out,		//LCD????
	output	reg			lcd_dc_out,		//LCD??????
	output	reg			lcd_clk_out,	//LCD????
	output	reg			lcd_data_out,	//LCD????
    output	reg			lcd_cs_out
);
 
	localparam			INIT_DEPTH = 16'd60; //LCD????????????
 
	localparam			RED		=	16'hf800;	//??
	localparam			GREEN	=	16'h07e0;	//??
	localparam			BLUE	=	16'h001f;	//??
	localparam			BLACK	=	16'h0000;	//??
	localparam			WHITE	=	16'hffff;	//??
	localparam			YELLOW	=	16'hffe0;	//??
 
	localparam			IDLE	=	3'd0;
	localparam			MAIN	=	3'd1;
	localparam			INIT	=	3'd2;
	localparam			SCAN	=	3'd3;
	localparam			WRITE	=	3'd4;
	localparam			DELAY	=	3'd5;
 
	localparam			LOW		=	1'b0;
	localparam			HIGH	=	1'b1;
 
	//assign	lcd_bl_out = HIGH;				// backlight active high level
 
	reg		[15:0]	color_t	=	YELLOW;		//??????
	wire		[15:0]	color_b	=	BLACK;		//??????
 
	reg			[7:0]	x_cnt;
	reg			[7:0]	y_cnt;
	reg			[131:0]	ram_data_r;
 
	reg			[8:0]	data_reg;				//
	reg			[8:0]	reg_setxy	[10:0];
	reg			[8:0]	reg_init	[59:0];
	reg			[2:0]	cnt_main;
	reg			[2:0]	cnt_init;
	reg			[2:0]	cnt_scan;
	reg			[5:0]	cnt_write;
	reg			[15:0]	cnt_delay;
	reg			[15:0]	num_delay;
	reg			[15:0]	cnt;
	reg					high_word;
	reg			[2:0] 	state = IDLE;
	reg			[2:0] 	state_back = IDLE;
	always@(posedge clk_in or negedge rst_n_in) begin
		if(!rst_n_in) begin
			x_cnt <= 8'd0;
			y_cnt <= 8'd0;
            lcd_cs_out<=1'b0;
			ram_lcd_clk_en <= 1'b0;
			ram_lcd_addr <= 8'd0;
			cnt_main <= 3'd0;
			cnt_init <= 3'd0;
			cnt_scan <= 3'd0;
			cnt_write <= 6'd0;
			cnt_delay <= 16'd0;
			num_delay <= 16'd50;
			cnt <= 16'd0;
			high_word <= 1'b1;
            lcd_dc_out  <=1'b0;
			lcd_bl_out <= LOW;
			state <= IDLE;
			state_back <= IDLE;

            reg_setxy[0]	=	{1'b0,8'h2a};
			reg_setxy[1]	=	{1'b1,8'h00};
			reg_setxy[2]	=	{1'b1,8'h00};
			reg_setxy[3]	=	{1'b1,8'h00};
			reg_setxy[4]	=	{1'b1,8'hf0};
			reg_setxy[5]	=	{1'b0,8'h2b};
			reg_setxy[6]	=	{1'b1,8'h00};
			reg_setxy[7]	=	{1'b1,8'h00};
			reg_setxy[8]	=	{1'b1,8'h00};
			reg_setxy[9]	=	{1'b1,8'hf0};
			reg_setxy[10]	=	{1'b0,8'h2c};

            reg_init[0]		=	{1'b0,8'h11}; 
			reg_init[1]		=	{1'b0,8'h36}; 
			reg_init[2]		=	{1'b1,8'h00}; 

			reg_init[3]		=	{1'b0,8'h3A}; 
			reg_init[4]		=	{1'b1,8'h05};
 
            reg_init[5]		=	{1'b0,8'hb2}; 
			reg_init[6]		=	{1'b1,8'h0C}; 
			reg_init[7]		=	{1'b1,8'h0c}; 
			reg_init[8]		=	{1'b1,8'h00}; 
			reg_init[9]	    =	{1'b1,8'h33}; 
			reg_init[10]	=	{1'b1,8'h33}; 

			reg_init[11]	=	{1'b0,8'hb7}; 
			reg_init[12]	=	{1'b1,8'h35}; 

			reg_init[13]	=	{1'b0,8'hbb}; 
			reg_init[14]	=	{1'b1,8'h19};
 
			reg_init[15]	=	{1'b0,8'hc0}; 
			reg_init[16]	=	{1'b1,8'h2c}; 

			reg_init[17]	=	{1'b0,8'hc2}; 
			reg_init[18]	=	{1'b1,8'h01};
 
			reg_init[19]	=	{1'b0,8'hc3}; 
			reg_init[20]	=	{1'b1,8'h12}; 

			reg_init[21]	=	{1'b0,8'hc4}; 
			reg_init[22]	=	{1'b1,8'h20}; 

			reg_init[23]	=	{1'b0,8'hc6}; 
			reg_init[24]	=	{1'b1,8'h0f}; 

			reg_init[25]	=	{1'b0,8'hd0}; 
			reg_init[26]	=	{1'b1,8'ha4}; 
			reg_init[27]	=	{1'b1,8'ha1}; 

			reg_init[28]	=	{1'b0,8'he0}; 
			reg_init[29]	=	{1'b1,8'hd0}; 
			reg_init[30]	=	{1'b1,8'h04}; 
			reg_init[31]	=	{1'b1,8'h0d}; 
			reg_init[32]	=	{1'b1,8'h11}; 
			reg_init[33]	=	{1'b1,8'h13}; 
			reg_init[34]	=	{1'b1,8'h2b}; 
			reg_init[35]	=	{1'b1,8'h3f}; 
			reg_init[36]	=	{1'b1,8'h54}; 
			reg_init[37]	=	{1'b1,8'h4c}; 
			reg_init[38]	=	{1'b1,8'h18}; 
			reg_init[39]	=	{1'b1,8'h0d}; 
			reg_init[40]	=	{1'b1,8'h0b}; 
			reg_init[41]	=	{1'b1,8'h1f}; 
			reg_init[42]	=	{1'b1,8'h23}; 

			reg_init[43]	=	{1'b0,8'he1}; 
			reg_init[44]	=	{1'b1,8'hd0}; 
			reg_init[45]	=	{1'b1,8'h04}; 
			reg_init[46]	=	{1'b1,8'h0c}; 
			reg_init[47]	=	{1'b1,8'h11}; 
			reg_init[48]	=	{1'b1,8'h13}; 
			reg_init[49]	=	{1'b1,8'h2c}; 
			reg_init[50]	=	{1'b1,8'h3f}; 
			reg_init[51]	=	{1'b1,8'h44}; 
			reg_init[52]	=	{1'b1,8'h51}; 
			reg_init[53]	=	{1'b1,8'h2f}; 
			reg_init[54]	=	{1'b1,8'h1f}; 
			reg_init[55]	=	{1'b1,8'h1f}; 
			reg_init[56]	=	{1'b1,8'h20}; 
			reg_init[57]	=	{1'b1,8'h23}; 
		
			reg_init[58]	=	{1'b0,8'h21}; 
			reg_init[59]	=	{1'b0,8'h29}; 
		end else begin
			case(state)
				IDLE:begin
						x_cnt <= 8'd0;
						y_cnt <= 8'd0;
						ram_lcd_clk_en <= 1'b0;
						ram_lcd_addr <= 8'd0;
						cnt_main <= 3'd0;
						cnt_init <= 3'd0;
						cnt_scan <= 3'd0;
						cnt_write <= 6'd0;
						cnt_delay <= 16'd0;
						num_delay <= 16'd50;
						cnt <= 16'd0;
						high_word <= 1'b1;
						state <= MAIN;
						state_back <= MAIN;
					end
				MAIN:begin
						case(cnt_main)	//MAIN??
							3'd0:	begin state <= INIT; cnt_main <= cnt_main + 1'b1; end
							3'd1:	begin state <= SCAN; cnt_main <= cnt_main + 1'b1;color_t<=YELLOW; end
                            3'd2:	begin state <= SCAN; cnt_main <= cnt_main + 1'b1; color_t<=RED;end
							3'd3:	begin cnt_main <= 1'b1; end
							default: state <= IDLE;
						endcase
					end
				INIT:begin	//?????
						case(cnt_init)
							3'd0:	begin lcd_rst_n_out <= 1'b0; cnt_init <= cnt_init + 1'b1; end	//????
							3'd1:	begin num_delay <= 16'd3000; state <= DELAY; state_back <= INIT; cnt_init <= cnt_init + 1'b1; end	//??
							3'd2:	begin lcd_rst_n_out <= 1'b1; cnt_init <= cnt_init + 1'b1; end	//????
							3'd3:	begin num_delay <= 16'd3000; state <= DELAY; state_back <= INIT; cnt_init <= cnt_init + 1'b1; end	//??
							3'd4:	begin 
										if(cnt>=INIT_DEPTH) begin	//?73??????????????
											cnt <= 16'd0;
											cnt_init <= cnt_init + 1'b1;
										end else begin
											data_reg <= reg_init[cnt];	
											if(cnt==16'd0) num_delay <= 16'd50000; //???????????
											else num_delay <= 16'd50;
											cnt <= cnt + 16'd1;
											state <= WRITE;
											state_back <= INIT;
										end
									end
							3'd5:	begin cnt_init <= 1'b0; state <= MAIN; end	//????????MAIN??
							default: state <= IDLE;
						endcase
					end
				SCAN:begin	//??????RAM???????
						case(cnt_scan)
							3'd0:	begin //???????????????
										if(cnt >= 11) begin	//
											cnt <= 16'd0;
											cnt_scan <= cnt_scan + 1'b1;
										end else begin
											data_reg <= reg_setxy[cnt];
											cnt <= cnt + 16'd1;
											num_delay <= 16'd50;
											state <= WRITE;
											state_back <= SCAN;
										end
									end
							3'd1:	begin ram_lcd_clk_en <= HIGH; ram_lcd_addr <= y_cnt; cnt_scan <= cnt_scan + 1'b1; end	//RAM????
							3'd2:	begin cnt_scan <= cnt_scan + 1'b1; end	//??????
							3'd3:	begin ram_lcd_clk_en <= LOW; ram_data_r <= ram_lcd_data; cnt_scan <= cnt_scan + 1'b1; end	//??RAM???????RAM????
							3'd4:	begin //???????16bit????SPI???8bit????????8???8?
										if(x_cnt>=LCD_W) begin	//?????(????)????
											x_cnt <= 8'd0;	
											if(y_cnt>=LCD_H) begin y_cnt <= 8'd0; cnt_scan <= cnt_scan + 1'b1; end	//????????????
											else begin y_cnt <= y_cnt + 1'b1; cnt_scan <= 3'd1; end		//?????RAM?????????
										end else begin
											if(high_word) data_reg <= {1'b1,color_t[15:8]}; //{1'b1,(ram_data_r[x_cnt]? color_t[15:8]:color_b[15:8])};	//????bit??????????????,??high_word???????8???8?
											else begin data_reg <=  {1'b1,color_t[7:0]}; x_cnt <= x_cnt + 1'b1; end	//????bit??????????????,??high_word???????8???8?????????bit
											high_word <= ~high_word;	//high_word?????
											num_delay <= 16'd50;	//??????
											state <= WRITE;	//???WRITE??
											state_back <= SCAN;	//???WRITE?DELAY?????SCAN??
										end
									end
							3'd5:	begin cnt_scan <= 1'b0; lcd_bl_out <= HIGH; state <= MAIN; end
							default: state <= IDLE;
						endcase
					end
				WRITE:begin	//WRITE????????SPI???????
						if(cnt_write >= 6'd17) cnt_write <= 1'b0;
						else cnt_write <= cnt_write + 1'b1;
						case(cnt_write)
							6'd0:	begin lcd_dc_out <= data_reg[8]&1'b1; end	//9??????????????
							6'd1:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[7]; end	//??????
							6'd2:	begin lcd_clk_out <= HIGH; end
							6'd3:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[6]; end
							6'd4:	begin lcd_clk_out <= HIGH; end
							6'd5:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[5]; end
							6'd6:	begin lcd_clk_out <= HIGH; end
							6'd7:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[4]; end
							6'd8:	begin lcd_clk_out <= HIGH; end
							6'd9:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[3]; end
							6'd10:	begin lcd_clk_out <= HIGH; end
							6'd11:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[2]; end
							6'd12:	begin lcd_clk_out <= HIGH; end
							6'd13:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[1]; end
							6'd14:	begin lcd_clk_out <= HIGH; end
							6'd15:	begin lcd_clk_out <= LOW; lcd_data_out <= data_reg[0]; end	//??????
							6'd16:	begin lcd_clk_out <= HIGH; end
							6'd17:	begin lcd_clk_out <= LOW; state <= DELAY; end	//
							default: state <= IDLE;
						endcase
					end
				DELAY:begin	//????
						if(cnt_delay >= num_delay) begin
							cnt_delay <= 16'd0;
							state <= state_back; 
						end else cnt_delay <= cnt_delay + 1'b1;
					end
				default:state <= IDLE;
			endcase
		end
	end
 
	// data for setxy
	initial	//???????????
		begin
			reg_setxy[0]	=	{1'b0,8'h2a};
			reg_setxy[1]	=	{1'b1,8'h00};
			reg_setxy[2]	=	{1'b1,8'h00};
			reg_setxy[3]	=	{1'b1,8'h00};
			reg_setxy[4]	=	{1'b1,LCD_W-1};
			reg_setxy[5]	=	{1'b0,8'h2b};
			reg_setxy[6]	=	{1'b1,8'h00};
			reg_setxy[7]	=	{1'b1,8'h00};
			reg_setxy[8]	=	{1'b1,8'h00};
			reg_setxy[9]	=	{1'b1,LCD_H-1};
			reg_setxy[10]	=	{1'b0,8'h2c};
		end
 
	// data for init
	initial	//LCD?????????
		begin
			    reg_init[0]		=	{1'b0,8'h11}; 
			reg_init[1]		=	{1'b0,8'h36}; 
			reg_init[2]		=	{1'b1,8'h70}; 

			reg_init[3]		=	{1'b0,8'h3A}; 
			reg_init[4]		=	{1'b1,8'h05};
 
            reg_init[5]		=	{1'b0,8'hb2}; 
			reg_init[6]		=	{1'b1,8'h0C}; 
			reg_init[7]		=	{1'b1,8'h0c}; 
			reg_init[8]		=	{1'b1,8'h00}; 
			reg_init[9]	=	{1'b1,8'h33}; 
			reg_init[10]	=	{1'b1,8'h33}; 

			reg_init[11]	=	{1'b0,8'hb7}; 
			reg_init[12]	=	{1'b1,8'h35}; 

			reg_init[13]	=	{1'b0,8'hbb}; 
			reg_init[14]	=	{1'b1,8'h19};
 
			reg_init[15]	=	{1'b0,8'hc0}; 
			reg_init[16]	=	{1'b1,8'h2c}; 

			reg_init[17]	=	{1'b0,8'hc2}; 
			reg_init[18]	=	{1'b1,8'h01};
 
			reg_init[19]	=	{1'b0,8'hc3}; 
			reg_init[20]	=	{1'b1,8'h12}; 

			reg_init[21]	=	{1'b0,8'hc4}; 
			reg_init[22]	=	{1'b1,8'h20}; 

			reg_init[23]	=	{1'b0,8'hc6}; 
			reg_init[24]	=	{1'b1,8'h0f}; 

			reg_init[25]	=	{1'b0,8'hd0}; 
			reg_init[26]	=	{1'b1,8'ha4}; 
			reg_init[27]	=	{1'b1,8'ha1}; 

			reg_init[28]	=	{1'b0,8'he0}; 
			reg_init[29]	=	{1'b1,8'hd0}; 
			reg_init[30]	=	{1'b1,8'h04}; 
			reg_init[31]	=	{1'b1,8'h0d}; 
			reg_init[32]	=	{1'b1,8'h11}; 
			reg_init[33]	=	{1'b1,8'h13}; 
			reg_init[34]	=	{1'b1,8'h2b}; 
			reg_init[35]	=	{1'b1,8'h3f}; 
			reg_init[36]	=	{1'b1,8'h54}; 
			reg_init[37]	=	{1'b1,8'h4c}; 
			reg_init[38]	=	{1'b1,8'h18}; 
			reg_init[39]	=	{1'b1,8'h0d}; 
			reg_init[40]	=	{1'b1,8'h0b}; 
			reg_init[41]	=	{1'b1,8'h1f}; 
			reg_init[42]	=	{1'b1,8'h23}; 

			reg_init[43]	=	{1'b0,8'he1}; 
			reg_init[44]	=	{1'b1,8'hd0}; 
			reg_init[45]	=	{1'b1,8'h04}; 
			reg_init[46]	=	{1'b1,8'h0c}; 
			reg_init[47]	=	{1'b1,8'h11}; 
			reg_init[48]	=	{1'b1,8'h13}; 
			reg_init[49]	=	{1'b1,8'h2c}; 
			reg_init[50]	=	{1'b1,8'h3f}; 
			reg_init[51]	=	{1'b1,8'h44}; 
			reg_init[52]	=	{1'b1,8'h51}; 
			reg_init[53]	=	{1'b0,8'h2f}; 
			reg_init[54]	=	{1'b1,8'h1f}; 
			reg_init[55]	=	{1'b1,8'h1f}; 
			reg_init[56]	=	{1'b1,8'h20}; 
			reg_init[57]	=	{1'b1,8'h23}; 
		
			reg_init[58]	=	{1'b0,8'h21}; 
			reg_init[59]	=	{1'b0,8'h29}; 
 
		end
 
endmodule