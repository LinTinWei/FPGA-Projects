///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: key_led_top.v
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

module key_led_top( clk, n_reset,key,led);
input clk,n_reset,key;
output wire [3:0]led;


wire press;

key_driver m_key(
        .clk(clk),
        .n_reset(n_reset),
        .key(key),
        .press(press)
);
led_example m_led(
        .clk(clk),
        .n_reset(n_reset),
        .en(press),
        .led(led)
);

//<statements>

endmodule

