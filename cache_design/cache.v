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
			DI_CPU,DI_Low,		//�ֱ��ʾ����CPU��Memory������
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
	wire	[`Width_of_A_Low-1:0]			A_Low_Port0;	//����EA��A_Low: Tag+Index
	wire	[`Width_of_A_Low-1:0]			A_Low_Port1;	//Cache��Tag�ֶ� + EA��Index�ֶ�
	wire	[`Wn_Width-1:0]					Wn;				//Mux��ѡ���źţ���������Cache block������������CPU������һ����Memory
	
	
	assign	Tag = A_CPU[31:(32 -`Tag_Width)];
	assign	Index = A_CPU[(31 -`Tag_Width):(32-`Tag_Width-`Index_Width)];
	assign	Word_Select = A_CPU[(31-`Tag_Width-`Index_Width):(32-`Tag_Width-`Index_Width-`Word_Select_Width)];
	assign	A_Low_Port0 = A_CPU[31:(32-`Tag_Width-`Index_Width)];
	
	
	
	
	
	
	
	
	
	
	
	