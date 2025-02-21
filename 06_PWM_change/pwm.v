///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: pwm.v
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
module pwm( 
    clk, n_reset,				// inputs
    en,
	pwm_0													// output );
);
input clk,n_reset;
input en;
output pwm_0;

reg [31:0] CNT;
reg pwm_0;

reg [15:0] period;  //10MHz/10 = 1MHZ
reg [15:0] h_time;  // 10*0.3=3 30% duty

always @ ( posedge clk or negedge n_reset )
        begin
             if(!n_reset)
                begin
                    CNT <=0;
                    period <=16'd10;
                   // h_time <=16'd3;
                end
             else if(CNT >= period - 1 )
                CNT <= 0;
            else
                CNT <= CNT + 1;
            end


always @ ( posedge clk or negedge n_reset )
        begin
              if(!n_reset)
                     pwm_0 <= 0;
              else
                  begin
                      if(en == 0)
                          pwm_0 <= 0;
                      else    //en = 1
                          begin
                              if(CNT <= h_time - 1)
                                  pwm_0 <= 1;
                              else
                                  pwm_0 <= 0;
                          end
                  end
        end
reg [31:0] timer;
always @ ( posedge clk or negedge n_reset )
        begin
            if(!n_reset) 
                begin
                    h_time <=16'd0;
                    timer <=32'd0;
                end
            else
                begin
                 if(timer >= 32'd5000000)//5MHZ => 0.5s   //GL1 10MHZ
                    begin
                        if(h_time==16'd10)h_time <= 0;
                        else 
                            begin
                            h_time <= h_time+ 16'd1;
                             timer <=32'd0;
                        end
                    end
                 else
                    timer <= timer +1;
                end
        end
//<statements>

endmodule

