///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: led_example.v
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


module led_example(
	 clk, n_reset,				// inputs
	led													// output
	);
input clk,n_reset;
output [3:0]led;
reg [31:0] timer; 
reg [3:0] led;
parameter CNT_MAX = 32'd500_000;
//<statements>
always @ ( posedge clk or negedge n_reset )
		begin
                if(!n_reset)
                    timer <=0;
                else if (timer == CNT_MAX-1) 
                    timer <=0;
                else
                    timer <= timer +1'b1;
        end


always @ ( posedge clk or negedge n_reset )
        // right rotate
        begin
          if(!n_reset)
               led<=4'b1110;
          else if (timer==CNT_MAX-1)  led<={led[0],led[3:1]};
        end
endmodule