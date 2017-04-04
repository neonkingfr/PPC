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
			Rdy_Low,			//来自下一级Memory的准备完毕信号
			DI_CPU,DI_Low,		//分别表示来自CPU和Memory的数据
			Ins_Type,			//表示指令的类型（字、半字、字节）
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
	input									Rdy_Low;
	input	[31:0]							DI_CPU;
	//input from Memory
	input	[`Memory_Block_Size-1:0]		DI_Low;
	
	input	[1:0] 							Ins_Type;
	
	
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
	
	wire	[31:0]							Word0_To_Cache;
	wire 	[31:0]							Word1_To_Cache;
	wire	[31:0]							Word2_To_Cache;
	wire	[31:0]							Word3_To_Cache;
	wire	[`Cache_Block_Size-1:0]			Data_In;
	
	wire									Hit;
	wire	[`En_Byte_Width-1:0]			En_Byte;
	
	
	
	assign	Tag = A_CPU[31:(32 -`Tag_Width)];
	assign	Index = A_CPU[(31 -`Tag_Width):(32-`Tag_Width-`Index_Width)];
	assign	Word_Select = A_CPU[(31-`Tag_Width-`Index_Width):(32-`Tag_Width-`Index_Width-`Word_Select_Width)];
	assign	Byte_Select = A_CPU[1:0];
	assign	A_Low_Port0 = A_CPU[31:(32-`Tag_Width-`Index_Width)];
	
	/*******************用来选择传入CACHE的数据*************************/
	MUX2	_mux_Word2(
			.d0(DI_CPU),
			.d1(DI_Low[31:0]),
			.s(Wn[0]),
			.y(Word0_To_Cache)
			);
			
	MUX2	_mux_Word2(
			.d0(DI_CPU),
			.d1(DI_Low[63:32]),
			.s(Wn[1]),
			.y(Word1_To_Cache)
			);
	
	MUX2	_mux_Word2(
			.d0(DI_CPU),
			.d1(DI_Low[95:64]),
			.s(Wn[2]),
			.y(Word2_To_Cache)
			);
	
	MUX2	_mux_Word2(
			.d0(DI_CPU),
			.d1(DI_Low[127:96]),
			.s(Wn[3]),
			.y(Word3_To_Cache)
			);
	assign Data_In = {Word3_To_Cache,Word2_To_Cache,Word1_To_Cache,Word0_To_Cache};
	
	
	
	
	/************************根据指令类型确定Byte_Select******************/
	always @ (*) begin
		if(Ins_Type == 0) 
			En_Byte = 4'b1111;
		else if(Ins_Type == 1) begin
			if(Byte_Select == 0 || Byte_Select == 1)
				En_Byte = 4'b0011;
			else if(Byte_Select == 2 || Byte_Select == 3)
				En_Byte = 4'b1100;
			end
		else if(Ins_Type == 2) begin
			if(Byte_Select == 0)
				En_Byte = 4'b0001;
			else if (Byte_Select == 1)
				En_Byte = 4'b0010;
			else if (Byte_Select == 2)
				En_Byte = 4'b0100;
			else if (Byte_Select == 3)
				En_Byte = 4'b1000;
			end
		else
			En_Byte = 4'bxxxx;
	end //end always
	
	/************************cacheBlock*******************************/
	
	CacheBlock  _cacheBlock(
			.clk(clk),
			.En_Word(En_Word),				//Block块内的字使能信号，用来判断选择哪个字
			.En_Byte(En_Byte),				//Block块内的字节使能信号，用来实现半字或字节操作。
			.Index(Index),					//选择Cache行
			.Wr(Wr),						//对SRAM的写信号
			.ValidNew(ValidNew),			//用于设置valid标志
			.DirtyNew(DirtyNew),			//用于设置dirty标志
			.Data_In(Data_In), 				//从CPU或者Memory传入的数据
			.Tag_In(Tag),					//从CPU传入的Tag字段
			
			.Dirty_Out(Dirty_Out),			//从Block中读出的dirty位，用来判断是否进行过写操作
			.Valid_Out(Valid_Out),			//从Block中读出的valid位，用来检测是否命中
			.Tag_Out(Tag_Out),				//从Block中读出的Tag字段，用于检测是否命中
			.Data_Out(Data_Out)				//从Block中读出的数据，用于传回CPU或写入下一级的Memory
		//	.Rdy_Low(Rdy_Low)				//当下一级Memory完成对Cache Block的写操作后，Rdy_Low
		);
			
	assign Hit = Valid_Out && ( A_CPU[31:(32 -`Tag_Width)] == Tag_Out);
	
	
	/************************cache controller****************************/
	Cache_Controller  _cache_controller(
			//input 
			.clk(clk),
			.rst(rst),
			.Req_CPU(Req_CPU),
			.Wr_CPU(Wr_CPU),
			.Rdy_Low(Rdy_Low),
			.Dirty(Dirty_Out),
			.Hit(Hit),
			.Word_Select(Word_Select),
			//output
			.Rdy_CPU(Rdy_CPU),
			.Req_Low(Req_Low),
			.Wr_Low(Wr_Low),
			.Wn(Wn),
			.ValidNew(ValidNew),
			.DirtyNew(DirtyNew),
			.En_Word(En_Word),
			.Wr(Wr),
			.ASel(ASel)
			);
	
	
	/**********************用4选1数据选择器选择到DO_CPU的数据***************/
	MUX4  _mux_Word4(
			.d0(Data_Out[31:0]), 
			.d1(Data_Out[63:32]), 
			.d2(Data_Out[95:64]), 
			.d3(Data_Out[127:96]),
			.s(Word_Select), 
			.y(DO_CPU)
		);
		
	/*********************用2选1选择器选择传入下一级的地址******************/
	
	assign A_Low_Port1 = {Tag_Out,Index};
	
	MUX2_ASEL _mux_Word2(
			.d0(A_Low_Port0),
			.d1(A_Low_Port1),
			.s(ASel),
			.y(A_Low)
		);
		
	/********************传入到下一级Memory的数据***************************/
	
	assign DO_Low = Data_Out;
	
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	