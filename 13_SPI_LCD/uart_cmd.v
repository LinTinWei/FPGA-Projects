///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: uart_cmd.v
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
module uart_cmd(
    clk,
    n_reset,
    rx_data,
    rx_done,
    ctrl
);
    input clk;
    input n_reset;
    input [7:0]rx_data;
    input rx_done;
    output reg[3:0]ctrl;

//<statements>
    reg [7:0] data_str [3:0];
    reg [3:0] cnt;
    reg flag;
always@(posedge clk or negedge n_reset)
    begin
        if(!n_reset) 
            begin
                cnt <= 4'b0;  
                flag <=1'b0;
            end
        else begin
            if(rx_done && flag==1'b0)
                begin
                data_str[cnt] <= rx_data;
                cnt <= cnt +1'b1;
                flag<=flag + 1'b1;
                if(cnt==4'd3) cnt<=4'b0;
            end
            if(rx_done==0) flag<=1'b0;

        end
    end

     reg r_rx_done;   
 //delay 1 Clk to make sure get 8 byte data
always@(posedge clk)
        r_rx_done <= rx_done;

always@(posedge clk or negedge n_reset)
begin
    if(!n_reset) begin
        ctrl <= 4'b0000;
    end else if(r_rx_done)begin
        if((data_str[0] == 8'hAA) && (data_str[1] == 8'hA5) && (data_str[3] == 8'hFF))begin
            ctrl <= (data_str[2]&8'h0F);
        end
    end    
end

endmodule

