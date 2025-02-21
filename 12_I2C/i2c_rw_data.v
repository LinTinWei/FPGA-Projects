///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: i2c_rw_data.v
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

module i2c_rw_data
(
input wire sys_clk , 
input wire i2c_clk , 
input wire sys_rst_n , 
input wire write , 
input wire read , 
input wire i2c_end , 
input wire [7:0] rd_data ,

output reg wr_en , 
output reg rd_en , 
output reg i2c_start , 
output reg [15:0] byte_addr , 
output reg [7:0] wr_data , 
output reg [7:0] Data 
);
////
//\* Parameter and Internal Signal \//
////
// parameter define
parameter DATA_NUM = 8'd1 ,
CNT_START_MAX = 11'd1500 , //1500
CNT_WR_RD_MAX = 8'd200 ,
CNT_WAIT_MAX = 28'd500_000 ;
// wire define
wire [7:0] data_num ; 
// reg define
reg [7:0] cnt_wr ; 
reg write_valid ; 
reg [7:0] cnt_rd ; 
reg read_valid ; 
reg [10:0] cnt_start ; 
reg [7:0] wr_i2c_data_num ; 
reg [7:0] rd_i2c_data_num ; 
reg fifo_rd_valid ; 
reg [27:0] cnt_wait ; 
reg fifo_rd_en ; 
reg [7:0] rd_data_num ; 
////
//\* Main Code \//
////

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wr <= 8'd0;
    else if(write_valid == 1'b0)
        cnt_wr <= 8'd0;
    else if(write_valid == 1'b1)
        cnt_wr <= cnt_wr + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        write_valid <= 1'b0;
    else if(cnt_wr == (CNT_WR_RD_MAX - 1'b1))
        write_valid <= 1'b0;
    else if(write == 1'b1)
        write_valid <= 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd <= 8'd0;
    else if(read_valid == 1'b0)
        cnt_rd <= 8'd0;
    else if(read_valid == 1'b1)
        cnt_rd <= cnt_rd + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        read_valid <= 1'b0;
    else if(cnt_rd == (CNT_WR_RD_MAX - 1'b1))
        read_valid <= 1'b0;
    else if(read == 1'b1)
        read_valid <= 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_start <= 11'd0;
    else if((wr_en == 1'b0) && (rd_en == 1'b0))
        cnt_start <= 11'd0;
    else if(cnt_start == (CNT_START_MAX - 1'b1))
        cnt_start <= 11'd0;
    else if((wr_en == 1'b1) || (rd_en == 1'b1))
        cnt_start <= cnt_start + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_start <= 1'b0;
     else if((cnt_start == (CNT_START_MAX - 1'b1)))
        i2c_start <= 1'b1;
     else
        i2c_start <= 1'b0;


always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        wr_en <= 1'b0;
     else if((wr_i2c_data_num == DATA_NUM - 1)
     && (i2c_end == 1'b1) && (wr_en == 1'b1))
        wr_en <= 1'b0;
     else if(write_valid == 1'b1)
        wr_en <= 1'b1;


always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        wr_i2c_data_num <= 8'd0;
     else if(wr_en == 1'b0)
        wr_i2c_data_num <= 8'd0;
     else if((wr_en == 1'b1) && (i2c_end == 1'b1))
        wr_i2c_data_num <= wr_i2c_data_num + 1'b1;


 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
     else if((rd_i2c_data_num == DATA_NUM - 1)
     && (i2c_end == 1'b1) && (rd_en == 1'b1))
        rd_en <= 1'b0;
     else if(read_valid == 1'b1)
        rd_en <= 1'b1;


 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        rd_i2c_data_num <= 8'd0;
     else if(rd_en == 1'b0)
        rd_i2c_data_num <= 8'd0;
     else if((rd_en == 1'b1) && (i2c_end == 1'b1))
        begin
        rd_i2c_data_num <= rd_i2c_data_num + 1'b1;
        Data <=rd_data;
         end

 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        byte_addr <= 16'h00_5A;
     else if((wr_en == 1'b0) && (rd_en == 1'b0))
        byte_addr <= 16'h00_5A;
     else if(((wr_en == 1'b1) || (rd_en == 1'b1)) && (i2c_end == 1'b1))
        byte_addr <= byte_addr + 1'b1;


 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        wr_data <= 8'hA5;
     else if(wr_en == 1'b0)
        wr_data <= 8'hA5;
     else if((wr_en == 1'b1) && (i2c_end == 1'b1))
        wr_data <= wr_data + 1'b1;


 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        fifo_rd_valid <= 1'b0;
     else if((rd_data_num == DATA_NUM)
     && (cnt_wait == (CNT_WAIT_MAX - 1'b1)))
        fifo_rd_valid <= 1'b0;
     else if(data_num == DATA_NUM)
        fifo_rd_valid <= 1'b1;

 
 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        cnt_wait <= 28'd0;
     else if(fifo_rd_valid == 1'b0)
        cnt_wait <= 28'd0;
     else if(cnt_wait == (CNT_WAIT_MAX - 1'b1))
        cnt_wait <= 28'd0;
     else if(fifo_rd_valid == 1'b1)
        cnt_wait <= cnt_wait + 1'b1;


 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        fifo_rd_en <= 1'b0;
     else if((cnt_wait == (CNT_WAIT_MAX - 1'b1))
     && (rd_data_num < DATA_NUM))
        fifo_rd_en <= 1'b1;
     else
        fifo_rd_en <= 1'b0;


 always@(posedge i2c_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        rd_data_num <= 8'd0;
     else if(fifo_rd_valid == 1'b0)
        rd_data_num <= 8'd0;
     else if(fifo_rd_en == 1'b1)
        rd_data_num <= rd_data_num + 1'b1;

 ////
 //\* Instantiation \//
 ////
 //------------- fifo_read_inst -------------
 /*fifo_data fifo_read_inst
 (
 .clock (i2c_clk ), 
 .data (rd_data ), 
 .rdreq (fifo_rd_en ),
 .wrreq (i2c_end && rd_en ), 

 .q (fifo_rd_data ), 
 .usedw (data_num ) 
 );*/
endmodule

