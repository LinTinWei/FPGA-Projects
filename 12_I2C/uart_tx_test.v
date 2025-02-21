///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: uart_tx_test.v
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
module uart_txrx_test(
    clk,
    n_reset,
    TX_RDY,
    RX_RDY,
    WEN,
    OEN,
    uart_tx,
    uart_rx,
    ctrl,
    sda,
    scl,
    key
);
    input [3:0]key;
    input clk;
    input n_reset;
    input TX_RDY;
    input RX_RDY;
    input  [7:0]uart_rx;
    output [7:0]uart_tx;
    output WEN;
    output OEN;
    output [3:0]ctrl;

    wire [7:0] uart_rx;
    reg [7:0] uart_tx;
    wire TX_RDY;
    wire RX_RDY;
    wire [3:0]key;
    reg WEN;
    reg OEN;

    inout  wire sda;
    output wire scl;

    //wire define
    wire read ; 
    wire write ; 
    wire [7:0] po_data ; 
    wire [7:0] rd_data ; 
    wire wr_en ;
    wire rd_en ;
    wire i2c_end ;
    wire i2c_start ;
    wire [7:0] wr_data ;
    wire [15:0] byte_addr ;
    wire i2c_clk ;

  uart_cmd uart_cmd0(
        .clk(clk),
        .n_reset(n_reset),
        .rx_data(uart_rx),
        .rx_done(RX_RDY),
        .ctrl(ctrl)
    );


    i2c_rw_data i2c_rw_data_inst
    (
        .sys_clk (clk ), 
        .i2c_clk (i2c_clk ),
        .sys_rst_n (n_reset ), 
        .write (key[2] ), 
        .read (key[3] ), 
        .i2c_end (i2c_end ), 
        .rd_data (rd_data ), 
        .wr_en (wr_en ), 
        .rd_en (rd_en ), 
        .i2c_start (i2c_start ), 
        .byte_addr (byte_addr ),
        .wr_data (wr_data ), 
        .Data(po_data ) 
    );
    i2c_ctrl
    #(
    .DEVICE_ADDR (7'b1010_000 ),
    .SYS_CLK_FREQ (26'd50_000_000 ), 
    .SCL_FREQ (18'd250_000 )
    )
    i2c_ctrl_inst
    (
        .sys_clk (clk ), 
        .sys_rst_n (n_reset ), 
        .wr_en (wr_en ), 
        .rd_en (rd_en ), 
        .i2c_start (i2c_start ), 
        .addr_num (1'b1 ), 
        .byte_addr (byte_addr ), 
        .wr_data (wr_data ), 
        .rd_data (rd_data ), 
        .i2c_end (i2c_end ), 
        .i2c_clk (i2c_clk ),
        .i2c_scl (scl ),
        .i2c_sda (sda ) 
    );
always @(posedge clk or negedge n_reset)	begin
		if (!n_reset)
            begin
                uart_tx <=8'b0;
                WEN <= 1'b1;
                OEN <= 1'b1;
            end
		else 
            begin
                if(RX_RDY==1'b1) 
                        begin
                            OEN  <= 1'b0;
                            uart_tx <= po_data;
                             if(TX_RDY==1'b1)
                                begin
                                      WEN<=1'b0;
                                end
                            else
                                begin
                                       WEN <= 1'b1;
                                       OEN <=1'b1;
                                end
                        end
                else  
                            OEN <= 1'b1;
            end
	end


/*
    reg uart_EN;
    reg [7:0]tx_Data;
    wire [7:0]rx_Data;
    wire [3:0]ctrl;
    wire Tx_done;
    wire Rx_done;

    uart_byte_tx uart_byte_tx(
        .clk(clk),
        .n_reset(n_reset),
        .Data(tx_Data),
        .Send_Go(uart_EN),
        .Baud_set(3'd4),
        .uart_tx(uart_tx),
        .Tx_done(Tx_done)
    );

     uart_byte_rx uart_byte_rx0(
        .Clk(clk),
        .Reset_n(n_reset),
        .uart_RXD(uart_rx),
        .uart_Data(rx_Data),
        .Rx_done(Rx_done)   
    );
 
     uart_cmd uart_cmd0(
        .clk(clk),
        .n_reset(n_reset),
        .rx_data(rx_Data),
        .rx_done(Rx_done),
        .ctrl(ctrl)
    );


always @(*)	
begin
		tx_Data <= rx_Data;
end

always @(posedge clk or negedge n_reset)	begin
		if (!n_reset)
            begin
                uart_EN <= 1'b0;
            end
		else if (Rx_done)
           	uart_EN <= 1'b1;
		else if (Tx_done)
            begin
             //tx_Data <= tx_Data + 1'b1;   
			uart_EN <= 1'b0;
             end
		//else
		//	uart_EN <= uart_EN;
	end
*/
/*
    reg [24:0]counter;
    always@(posedge clk or negedge n_reset)
        begin
            if(!n_reset)
                counter <= 0;
            else if(counter == 4999999)     //4999999 
                counter <= 0;
            else
                counter <= counter + 1;
        end

    always@(posedge clk or negedge n_reset)
    begin
        if(!n_reset)       
            uart_EN <= 0;
        else if(counter == 1)
            uart_EN <= 1;
        else
            uart_EN <= 0;
    end

    always@(posedge clk or negedge n_reset)
    begin
        if(!n_reset)        
            tx_Data <= 0;
        else if(Tx_done)
            tx_Data <= tx_Data + 1'b1;   
    end
*/

   /*    
    input clk;
    input n_reset;
    input  uart_rx;
    output uart_tx;

    reg [7:0]tx_Data;
	//wire [7:0]rx_Data;
	reg uart_EN;
//	wire Tx_done;
	//wire Rx_done;

   uart_byte_tx uart_byte_tx(
        .clk(clk),
        .n_reset(n_reset),
        .Data(tx_data),
        .Send_Go(uart_EN),
        .Baud_set(3'd0),
        .uart_tx(uart_tx),
        .Tx_done(Tx_done)
    );
 
    uart_byte_rx uart_byte_rx0(
        .Clk(clk),
        .Reset_n(n_reset),
        .uart_RXD(uart_rx),
        .uart_Data(rx_data),
        .Rx_done(Rx_done)   
    );
  
always @(*)	
begin
		tx_Data <= rx_Data;
end
always @(posedge clk or negedge n_reset)	begin
		if (!n_reset)
			uart_EN <= 1'b0;
		else if (Rx_done)
			uart_EN <= 1'b1;
		else if (Tx_done)
			uart_EN <= 1'b0;
		else
			uart_EN <= uart_EN;
	end


 reg [24:0]counter;
    always@(posedge clk or negedge n_reset)
        begin
            if(!n_reset)
                counter <= 0;
            else if(counter == 4999999)     //4999999 
                counter <= 0;
            else
                counter <= counter + 1;
        end

    always@(posedge clk or negedge n_reset)
    begin
        if(!n_reset)       
            uart_EN <= 0;
        else if(counter == 1)
            uart_EN <= 1;
        else
            uart_EN <= 0;
    end

    always@(posedge clk or negedge n_reset)
    begin
        if(!n_reset)        
            tx_Data <= 0;
        else if(Tx_done)
            tx_Data <= tx_Data + 1'b1;   
    end
*/
endmodule

