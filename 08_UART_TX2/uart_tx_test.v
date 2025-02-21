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
    
    reg [2:0]state;
    reg [39:0]Data40;
    reg Trans_Done;
    reg Trans_Go;
    always@(posedge clk or negedge n_reset)
    if(!n_reset)begin
        state <= 0;
        Data <= 0;
        Send_Go <= 0; 
        Trans_Done <= 0;
        Trans_Go <=1'b1;
        Data40<=40'h11CC33FCBB;
    end
    else begin
        case(state)
            0:
            begin
                Trans_Done <= 0;
                if(Trans_Go)begin
                    Data <= Data40[7:0];
                    Send_Go <= 1; 
                    state <= 1;     
                end
                else begin
                    Data <= Data;
                    Send_Go <= 0; 
                    state <= 0;         
                end
           end
               
           1:
            begin
                if(Tx_done)begin
                    Data <= Data40[15:8];
                    Send_Go <= 1;
                    state <= 2;
                end
                else begin
                    Data <= Data;
                    Send_Go <= 0;
                    state <= 1;
                end
            end
            
            2:
            begin
                if(Tx_done)begin
                    Data <= Data40[23:16];
                    Send_Go <= 1;
                    state <= 3;
                end
                else begin
                    Data <= Data;
                    Send_Go <= 0;
                    state <= 2;
                end
            end 
              
            3:
            begin
                if(Tx_done)begin
                    Data <= Data40[31:24];
                    Send_Go <= 1;
                    state <= 4;
                end
                else begin
                    Data <= Data;
                    Send_Go <= 0;
                    state <= 3;
                end
            end  
                   
            4:
            begin
                if(Tx_done)begin
                    Data <= Data40[39:32];
                    Send_Go <= 1;
                    state <= 5;
                end
                else begin
                    Data <= Data;
                    Send_Go <= 0;
                    state <= 4;
                end
            end  
                       
            5:
            begin
                if(Tx_done)begin
                    Send_Go <= 0;
                    Trans_Done <= 1;
                    state <= 0;
                end
                else begin
                    Data <= Data;
                    Send_Go <= 0;
                    state <= 5;
                end
            end 
            default:   
                begin
                    Data <= Data;
                    Send_Go <= 0;
                    state <= 0;
                end
        endcase
    end

endmodule

