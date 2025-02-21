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

module uart_tx_test(
    clk,
    n_reset,
    uart_tx
);
    input clk;
    input n_reset;
    output uart_tx;

    reg Send_Go;
    reg [7:0]Data;
    
    uart_byte_tx uart_byte_tx(
        .clk(clk),
        .n_reset(n_reset),
        .Data(Data),
        .Send_Go(Send_Go),
        .Baud_set(3'd0),
        .uart_tx(uart_tx),
        .Tx_done(Tx_done)
    );
    
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
            Send_Go <= 0;
        else if(counter == 1)
            Send_Go <= 1;
        else
            Send_Go <= 0;
    end

    always@(posedge clk or negedge n_reset)
    begin
        if(!n_reset)        
            Data <= 0;
        else if(Tx_done)
            Data <= Data + 1'b1;   
    end
endmodule

