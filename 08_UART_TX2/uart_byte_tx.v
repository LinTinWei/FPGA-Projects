///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: uart_byte_tx.v
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

module uart_byte_tx( 
    clk,
    n_reset,
    Data,
    Send_Go,    
    Baud_set,
    uart_tx,
    Tx_done
 );
    input clk;
    input n_reset;
    input [7:0]Data;
    input Send_Go;
    input [2:0]Baud_set;
    output reg uart_tx;
    output reg Tx_done;


    reg [17:0]bps_DR;
    always@(*)
        begin
                case(Baud_set)
                    0:bps_DR = 16'd5207;  //9600
                    1:bps_DR =  16'd2603; //19200
                    2:bps_DR = 16'd1301;  //38400
                    3:bps_DR =  16'd867;  //57600
                    4:bps_DR =  16'd433;  //115200
                    default:bps_DR =  16'd5207;
                 endcase
           end

    reg Send_en;
    always@(posedge clk or negedge n_reset)
        begin
                if(!n_reset)       
                    Send_en <= 0;
                else if(Send_Go)
                    Send_en <= 1;
                else if(Tx_done)
                    Send_en <= 0;
        end

    reg [7:0]r_Data;

    always@(posedge clk)  
        begin
            if(Send_Go)
                r_Data <= Data;
            else
                r_Data <= r_Data;     
        end
    reg [17:0]div_cnt;
    wire bps_clk;
    assign bps_clk = (div_cnt == 1);
    


    always@(posedge clk or negedge n_reset)
        begin
            if(!n_reset)
                div_cnt <= 0;
            else if(Send_en)begin
                if(div_cnt == bps_DR )
                    div_cnt <= 0;
                else 
                    div_cnt <= div_cnt + 1'b1;
            end
            else
                div_cnt <= 0;
        end

    reg [3:0]bps_cnt;

    always@(posedge clk or negedge n_reset)
        begin
            if(!n_reset)
                bps_cnt <= 0;
            else if(Send_en)begin
                if(bps_clk)begin
                    if(bps_cnt == 11)
                        bps_cnt <= 0;
                    else
                        bps_cnt <= bps_cnt + 1'b1;
                end
            end
            else
                bps_cnt <= 0;
        end

    always@(posedge clk or negedge n_reset)
        begin
            if(!n_reset) begin
                uart_tx <= 1'b1;
            end
            else begin
                case(bps_cnt)
                    1:uart_tx <= 0;
                    2:uart_tx <= r_Data[0];
                    3:uart_tx <= r_Data[1];
                    4:uart_tx <= r_Data[2];
                    5:uart_tx <= r_Data[3];
                    6:uart_tx <= r_Data[4];
                    7:uart_tx <= r_Data[5];
                    8:uart_tx <= r_Data[6];
                    9:uart_tx <= r_Data[7]; 
                    10:uart_tx <= 1;
                    11:begin uart_tx <= 1;end
                    default:uart_tx <= 1;
                endcase
             end
        end
    always@(posedge clk or negedge n_reset)
        begin
            if(!n_reset) 
                Tx_done <= 0;
            else if((bps_clk == 1)  && (bps_cnt == 10))
                Tx_done <= 1;
            else
                Tx_done <= 0;
        end

endmodule

