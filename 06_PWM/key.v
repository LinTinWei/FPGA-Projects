///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: key.v
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
module key_driver(
	clk, n_reset,				// inputs
    key,
	press													
	);                     
input clk, n_reset;
input  [3:0]key;
output [3:0]press;
//<statements>

reg [19:0] count;
reg [3:0]key_scan;
reg [3:0]press;
always @ ( posedge clk or negedge n_reset )
        begin
             if(!n_reset)
                count<=20'd0;
              else
                   begin
                    if(count==20'd19_999)
                        begin
                         count<=20'd0;
                            key_scan<=key;
                        end
                    else
                        count <= count+20'b1;
                   end
        end

always @ ( posedge clk or negedge n_reset )
        begin
             if(!n_reset)
                press <=1'b0;
              else
                press <=~key_scan;
        end
endmodule

