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

//CLK 1MHZ
module led_example(
	clk, n_reset,				// inputs
    en,
	led													// output
	);
input clk,n_reset;
input en;
output [3:0]led;

reg [3:0] led;

//<statements>


always @ ( posedge clk or negedge n_reset )
        begin
             if(!n_reset)
                    led<=4'b1111;
              else if(en)
                    led[0]<=~led[0];
              
        end

endmodule