///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: uart_byte_rx.v
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

module uart_byte_rx(
    input Clk,
	input Reset_n,	
	input uart_RXD,	
	output reg [7:0]uart_Data,	
	output reg Rx_done	
);

 reg [1:0]state_RXD;	
	wire nedge_RXD;	
	reg uart_EN;	
	reg [8:0]cnt_Scan;	
	parameter Bps_DR = 1_000_000_000 / 115200 / 16 / 20 - 1;	
	reg [7:0]cnt_state;	
	localparam MAX = 159;	
	reg [2:0]state_Start;	
	reg [2:0]state_Data[7:0];
	reg [2:0]state_Stop;	
	reg state_done;	
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)	
			state_RXD <= 2'd0;
		else	
			state_RXD <= {state_RXD[0], uart_RXD};
	end
	assign nedge_RXD = (state_RXD == 2'b10);	
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)	
            begin
			uart_EN <= 1'b0;
            end
		else if (nedge_RXD)	
			uart_EN <= 1'b1;
		else if (cnt_state == MAX || state_Start[2])	
			uart_EN <= 0;
		else	
			uart_EN <= uart_EN;
	end
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)	
			cnt_Scan <= 9'd0;
		else if (uart_EN)	begin	
			if (Bps_DR <= cnt_Scan)	
				cnt_Scan <= 9'd0;
			else	
				cnt_Scan <= cnt_Scan + 1'b1;
		end
		else	
			cnt_Scan <= 9'd0;
	end
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)	
			cnt_state <= 8'd0;
		else if (uart_EN)	begin	
			if (state_done)	begin	
				if (MAX <= cnt_state)	
					cnt_state <= 8'd0;
				else	
					cnt_state <= cnt_state + 1'b1;
			end
			else	
				cnt_state <= cnt_state;
		end
		else	
			cnt_state <= 8'd0;
	end
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)	begin	
			state_Start <= 3'd0;
			state_Data[0] <= 3'd0;	
			state_Data[1] <= 3'd0;
			state_Data[2] <= 3'd0;
			state_Data[3] <= 3'd0;
			state_Data[4] <= 3'd0;
			state_Data[5] <= 3'd0;
			state_Data[6] <= 3'd0;
			state_Data[7] <= 3'd0;
			state_Stop <= 3'd0;
		end
		else if (uart_EN)	begin	
			case (cnt_state)	
				5,6,7,8,9,10,11:state_Start <= state_Start + uart_RXD;	
				21,22,23,24,25,26,27:state_Data[0] <= state_Data[0] + uart_RXD;
				37,38,39,40,41,42,43:state_Data[1] <= state_Data[1] + uart_RXD;
				53,54,55,56,57,58,59:state_Data[2] <= state_Data[2] + uart_RXD;
				69,70,71,72,73,74,75:state_Data[3] <= state_Data[3] + uart_RXD;
				85,86,87,88,89,90,81:state_Data[4] <= state_Data[4] + uart_RXD;
				101,102,103,104,105,106,107:state_Data[5] <= state_Data[5] + uart_RXD;
				117,118,119,120,121,122,123:state_Data[6] <= state_Data[6] + uart_RXD;
				133,134,135,136,137,138,139:state_Data[7] <= state_Data[7] + uart_RXD;
				149,150,151,152,153,154,155:state_Stop <= state_Stop + uart_RXD;
			endcase
		end
		else	begin	
			state_Start <= 3'd0;
			state_Data[0] <= 3'd0;
			state_Data[1] <= 3'd0;
			state_Data[2] <= 3'd0;
			state_Data[3] <= 3'd0;
			state_Data[4] <= 3'd0;
			state_Data[5] <= 3'd0;
			state_Data[6] <= 3'd0;
			state_Data[7] <= 3'd0;
			state_Stop <= 3'd0;
		end
	end
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)	
			uart_Data <= 8'd0;
		else if (cnt_state == MAX)	begin	
			uart_Data[0] <= state_Data[0][2];
			uart_Data[1] <= state_Data[1][2];
			uart_Data[2] <= state_Data[2][2];
			uart_Data[3] <= state_Data[3][2];
			uart_Data[4] <= state_Data[4][2];
			uart_Data[5] <= state_Data[5][2];
			uart_Data[6] <= state_Data[6][2];
			uart_Data[7] <= state_Data[7][2];
		end
		else	
			uart_Data <= uart_Data;
	end
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)	
			state_done <= 1'b0;
		else if (cnt_Scan == Bps_DR)	
			state_done <= 1'b1;
		else	
			state_done <= 1'b0;
	end
	
	always @(posedge Clk or negedge Reset_n)	begin	
		if (!Reset_n)
			Rx_done <= 1'b0;
		else if (cnt_state == MAX)	
			Rx_done <= 1'b1;
		else	
			Rx_done <= 1'b0;
	end

        

endmodule

