/*
** cache�Ļ���������
**    (1)������Ϊ16KB��ÿ��4���֣���128λ������д�ز���
**    (2)����1024��cache�飬����32λ��ַ��TIO�ṹΪ��
**		 ��18λΪTag,[13:4]ΪIndex,[3:0]Ϊoffset��
**		 ͬʱ��ÿ��Cache�л���һ��dirtyλ��һ��validλ��
**    (3)ʹ������Ϊ128*1024��sram�洢cache�����ݣ�������
**       Ϊ24*256��sram�洢tag��dirty��validλ����������
**       sram�����ù����ַ�ĵ���˫�˿ڴ洢����
*/
module cache(
			//input
			clk,rst,
			Req_CPU,			//����CPU�������ź�
			Wr_CPU,				//����CPU�Ķ�д�źţ�����Ϊ1��ʾ��д������Ϊ0��ʾ�Ƕ�����
			A_CPU,				//����CPU�ĵ�ַ�ź�
			Rdy_Low,			//������һ��Memory��׼������ź�
			DI_CPU,DI_Low,		//�ֱ��ʾ����CPU��Memory������
			Ins_Type,			//��ʾָ������ͣ��֡����֡��ֽڣ�
			//output
			Rdy_CPU,			//��CPU���ݵ�����źţ�������ʱΪ1������ȱʧ�ͷ���0����CPU�ȴ�Cacheִ�����
			Req_Low,			//��Cache����ȱʧʱ����Memory���������ź�
			Wr_Low,				//Cache��Memory���͵Ķ�д�źţ�
								//(1)��Cache������ʱ������Ҫ����д�ط���Cache�е�����д�ص�Memory����ʱWr_LowΪ1��
								//(2)��Cache��Memory�ж���ʱ��Wr_LowΪ0
			A_Low,				//��Cache����ȱʧʱ����Memory���͵�ַ�ź�
			DO_CPU,				//��Cache���ظ�CPU������		
			DO_Low				//��Cache������ʱ��Cacheд�ص�Memory������
			);
	input									clk;
	input									rst;
	//input from CPU
	input									Req_CPU��
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
	wire	[`Width_of_A_Low-1:0]			A_Low_Port0;	//����EA��A_Low: Tag+Index
	wire	[`Width_of_A_Low-1:0]			A_Low_Port1;	//Cache��Tag�ֶ� + EA��Index�ֶ�
	wire	[`Wn_Width-1:0]					Wn;				//Mux��ѡ���źţ���������Cache block������������CPU������һ����Memory
	
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
	
	/*******************����ѡ����CACHE������*************************/
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
	
	
	
	
	/************************����ָ������ȷ��Byte_Select******************/
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
			.En_Word(En_Word),				//Block���ڵ���ʹ���źţ������ж�ѡ���ĸ���
			.En_Byte(En_Byte),				//Block���ڵ��ֽ�ʹ���źţ�����ʵ�ְ��ֻ��ֽڲ�����
			.Index(Index),					//ѡ��Cache��
			.Wr(Wr),						//��SRAM��д�ź�
			.ValidNew(ValidNew),			//��������valid��־
			.DirtyNew(DirtyNew),			//��������dirty��־
			.Data_In(Data_In), 				//��CPU����Memory���������
			.Tag_In(Tag),					//��CPU�����Tag�ֶ�
			
			.Dirty_Out(Dirty_Out),			//��Block�ж�����dirtyλ�������ж��Ƿ���й�д����
			.Valid_Out(Valid_Out),			//��Block�ж�����validλ����������Ƿ�����
			.Tag_Out(Tag_Out),				//��Block�ж�����Tag�ֶΣ����ڼ���Ƿ�����
			.Data_Out(Data_Out)				//��Block�ж��������ݣ����ڴ���CPU��д����һ����Memory
		//	.Rdy_Low(Rdy_Low)				//����һ��Memory��ɶ�Cache Block��д������Rdy_Low
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
	
	
	/**********************��4ѡ1����ѡ����ѡ��DO_CPU������***************/
	MUX4  _mux_Word4(
			.d0(Data_Out[31:0]), 
			.d1(Data_Out[63:32]), 
			.d2(Data_Out[95:64]), 
			.d3(Data_Out[127:96]),
			.s(Word_Select), 
			.y(DO_CPU)
		);
		
	/*********************��2ѡ1ѡ����ѡ������һ���ĵ�ַ******************/
	
	assign A_Low_Port1 = {Tag_Out,Index};
	
	MUX2_ASEL _mux_Word2(
			.d0(A_Low_Port0),
			.d1(A_Low_Port1),
			.s(ASel),
			.y(A_Low)
		);
		
	/********************���뵽��һ��Memory������***************************/
	
	assign DO_Low = Data_Out;
	
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	