`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/10 20:56:25
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(clk,rst,
            Ready_Cache,			
			data_in,				
            Req_CPU,            
			Wr_CPU,				
			A_CPU,				
			data_out,
			Ins_Type			
          );
          input									clk;
          input                                 rst;
          //input from CPU
          input                                 Ready_Cache;
          input    [31:0]                       data_in;
          output                                Req_CPU;
          output                                Wr_CPU;
          output    [31:0]                      A_CPU;
          output    [31:0]                      data_out;
          output    [1:0]                       Ins_Type;
          
         reg                                Req_CPU;
         reg                                Wr_CPU;
          reg    [31:0]                      A_CPU;
          reg    [31:0]                      data_out;
         reg    [1:0]                       Ins_Type;
          
              
          always@ (posedge clk) begin
            if(rst) begin
                Req_CPU = 1;
                Wr_CPU = 1;
                A_CPU = 1;
                data_out = 64;
                Ins_Type = 0;
           end
         end 
         
         always @(Ready_Cache) begin
           if(Ready_Cache == 1) begin
                A_CPU = A_CPU + 1;
                data_out = data_out + 1;
           end
        end //end always
            
endmodule
