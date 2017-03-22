/*
** cache的基本参数：
**    (1)总容量为16KB，每块4个字，共128位，采用写回策略
**    (2)包括1024个cache块，所以32位地址的TIO结构为：
**		 高18位为Tag,[13:4]为Index,[3:0]为offset。
**		 同时，每个Cache行还有一个dirty位和一个valid位。
**    (3)使用容量为128*1024的sram存储cache块数据，用容量
**       为24*256的sram存储tag、dirty和valid位。并且两个
**       sram均采用共享地址的单向双端口存储器。
*/
module cache(
			//input
			clk,rst,
			Req_CPU,			//来自CPU的请求信号
			Wr_CPU,				//来自CPU的读写信号，其中为1表示是写操作，为0表示是读操作
			A_CPU,				//来自CPU的地址信号
			DI_CPU,DI_Low,		//分别表示来自CPU和Memory的数据
			//output
			Rdy_CPU,			//向CPU传递的完毕信号，当命中时为1，若是缺失就返回0，让CPU等待Cache执行完毕
			Req_Low,			//当Cache产生缺失时，向Memory发出请求信号
			Wr_Low,				//Cache向Memory发送的读写信号，
								//(1)当Cache不命中时，首先要采用写回法将Cache中的数据写回到Memory，此时Wr_Low为1；
								//(2)当Cache从Memory中读数时，Wr_Low为0
			A_Low,				//当Cache产生缺失时，向Memory发送地址信号
			DO_CPU,				//从Cache返回给CPU的数据		
			DO_Low				//当Cache不命中时，Cache写回到Memory的数据
			);
	input									clk;
	input									rst;
	//input from CPU
	input									Req_CPU；
	input									Wr_CPU;
	input	[31:0]							A_CPU;
	input	[31:0]							DI_CPU;
	//input from Memory
	input	[`Memory_Block_Size-1:0]		DI_Low;
	
	
	//output to CPU
	output									Rdy_CPU;
	
	//output to Memory
	output									Req_Low;
	output									Wr_Low;
	
	//output to CPU
	output	[31:0]							DO_CPU;
	
	//output to Memory
	output	[`Width_of_A_Low-1:0]			A_Low;
	output	[`Memory_Block_Size-1:0]		DO_Low;
	
	
	wire	[`Tag_Width-1:0]				Tag;
	wire 	[`Index_Width-1:0]				Index;
	wire	[`Word_Select_Width-1:0]		Word_Select;
	wire	[`Width_of_A_Low-1:0]			A_Low_Port0;	//来自EA的A_Low: Tag+Index
	wire	[`Width_of_A_Low-1:0]			A_Low_Port1;	//Cache的Tag字段 + EA的Index字段
	wire	[`Wn_Width-1:0]					Wn;				//Mux的选择信号，决定传入Cache block的数据是来自CPU还是下一级的Memory
	
	
	assign	Tag = A_CPU[31:(32 -`Tag_Width)];
	assign	Index = A_CPU[(31 -`Tag_Width):(32-`Tag_Width-`Index_Width)];
	assign	Word_Select = A_CPU[(31-`Tag_Width-`Index_Width):(32-`Tag_Width-`Index_Width-`Word_Select_Width)];
	assign	A_Low_Port0 = A_CPU[31:(32-`Tag_Width-`Index_Width)];
	
	
	
	
	
	
	
	
	
	
	
	