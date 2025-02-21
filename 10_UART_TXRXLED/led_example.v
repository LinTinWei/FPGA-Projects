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
input [3:0]en;
output [3:0]led;

reg [3:0] led;

//<statements>


always @ ( posedge clk or negedge n_reset )
        begin
             if(!n_reset)
                    led<=4'b1111;
              else 
                begin
                led[0]<=~en[0];
                led[1]<=~en[1];
                led[2]<=~en[2];
                led[3]<=~en[3];
                end
              
        end

endmodule