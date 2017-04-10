`include "data_def.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/07 14:25:59
// Design Name: 
// Module Name: Top
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


module Top(
            clk,rst
//			Req_CPU,            //来自CPU的请求信号 
//			Wr_CPU,				//来自CPU的读写信号，其中为1表示是写操作，为0表示是读操作
//			A_CPU,				//来自CPU的地址信号
//			DI_CPU,
//			Ins_Type,			//表示指令的类型（字、半字、字节）
//			//output
//			Rdy_CPU,			//向CPU传递的完毕信号，当命中时为1，若是缺失就返回0，让CPU等待Cache执行完毕
//			DO_CPU				//从Cache返回给CPU的数据		
    );
    input									clk;
	input									rst;
	//input from CPU
	wire									Req_CPU;
	wire									Wr_CPU;
	wire	[31:0]							A_CPU;
	wire	[31:0]							DI_CPU;
	wire	[1:0] 							Ins_Type;
	
	//output to CPU
	wire									Rdy_CPU;
	
	//output to CPU
	wire	[31:0]							DO_CPU;
	
	wire   [`Memory_Block_Size-1:0]        DI_Low;
	//wire   [`Width_of_A_Low-1:0]           A_Low;
	wire   [31:0]                          A_Low;
	wire   [`Memory_Block_Size-1:0]        DO_Low;

   CPU _CPU(
       .clk(clk),
       .rst(rst),
       .Ready_Cache(Rdy_CPU),			
	   .data_in(DO_CPU),				
       .Req_CPU(Req_CPU),            
	   .Wr_CPU(Wr_CPU),				
	   .A_CPU(A_CPU),				
	   .data_out(DI_CPU),
	   .Ins_Type(Ins_Type)			
      );
	
	cache _CACHE(
		.clk(clk),
		.rst(rst),
		.Req_CPU(Req_CPU),          
		.Wr_CPU(Wr_CPU),			
		.A_CPU(A_CPU),				
		.Rdy_Low(Rdy_Low),			
		.DI_CPU(DI_CPU),
		.DI_Low(DI_Low),
		.Ins_Type(Ins_Type),			
		//output
		.Rdy_CPU(Rdy_CPU),			
		.Req_Low(Req_Low),			
		.Wr_Low(Wr_Low),				
		.A_Low(A_Low),				
		.DO_CPU(DO_CPU),				
		.DO_Low(DO_Low)				
	);
	
	memory _MEMORY(	
		.clk(clk),
		.Req_Low(Req_Low),
		.addr(A_Low[9:0]),
		.din(DO_Low),
		.Wr(Wr_Low),
		//OUTPUT
		.dout(DI_Low),
		.Rdy_Low(Rdy_Low)
		);
	
endmodule
