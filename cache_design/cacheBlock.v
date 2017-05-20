`include "data_def.v"

module cacheBlock(
			clk,
			En_Word,						//Block���ڵ���ʹ���źţ������ж�ѡ���ĸ���
			En_Byte,						//Block���ڵ��ֽ�ʹ���źţ�����ʵ�ְ��ֻ��ֽڲ�����
			Index,							//ѡ��Cache��
			Wr,								//��SRAM��д�ź�
			ValidNew,						//��������valid��־
			DirtyNew,						//��������dirty��־
			Data_In, 						//��CPU����Memory���������
			Tag_In,							//��CPU�����Tag�ֶ�
			
			Dirty_Out,						//��Block�ж�����dirtyλ�������ж��Ƿ���й�д����
			Valid_Out,						//��Block�ж�����validλ����������Ƿ�����
			Tag_Out,						//��Block�ж�����Tag�ֶΣ����ڼ���Ƿ�����
			Data_Out						//��Block�ж��������ݣ����ڴ���CPU��д����һ����Memory
			//Rdy_Low							//����һ��Memory��ɶ�Cache Block��д������Rdy_Low
		);
		
		input								clk;
		input	[`En_Word_Width-1:0]		En_Word;
		input	[`En_Byte_Width-1:0]		En_Byte;
		input	[`Index_Width-1:0]			Index;
		input								Wr;
		input								ValidNew;
		input								DirtyNew;
		input	[`Cache_Block_Size-1:0]		Data_In;
		input	[`Tag_Width-1:0]			Tag_In;
		
		output								Dirty_Out;
		output								Valid_Out;
		output	[`Tag_Width-1:0]			Tag_Out;
		output	[`Cache_Block_Size-1:0]		Data_Out;
		//output								Rdy_Low;
		
		
		reg   	[15:0]						wea_data;
		reg		[2:0]						wea_flag;
		wire	[`flag_Tag_Size-1:0]		data_flag;
		wire	[`flag_Tag_Size-1:0]		data_flag_out;

//////////////////////////////////////////////////////////////////////
//����En_Word��En_Byte�������ֶ���ѡ��Block Ram��ʵ�ʵ�����
//////////////////////////////////////////////////////////////////////
		always @(*) begin
			if(Wr == 1) begin
				//��ѡ��
				if(En_Word == 4'b0001 && En_Byte == 4'b1111) begin
					wea_data = 16'h000f;
				end
				else if (En_Word == 4'b0010 && En_Byte == 4'b1111) begin
					wea_data = 16'h00f0;
				end
				else if (En_Word == 4'b0100 && En_Byte == 4'b1111) begin 
					wea_data = 16'h0f00;
				end
				else if (En_Word == 4'b1000 && En_Byte == 4'b1111) begin
					wea_data = 16'hf000;
				end
				//����ѡ��
				///En_Word == 4'b0001
				else if (En_Word == 4'b0001 && En_Byte == 4'b0011) begin
					wea_data = 16'h0003;
				end
				else if (En_Word == 4'b0001 && En_Byte == 4'b1100) begin
					wea_data = 16'h000c;
				end
				///En_Word == 4'b0010
				else if (En_Word == 4'b0010 && En_Byte == 4'b0011) begin
					wea_data = 16'h0030;
				end
				else if (En_Word == 4'b0010 && En_Byte == 4'b1100) begin
					wea_data = 16'h00c0;
				end
				///En_Word == 4'b0100
				else if (En_Word == 4'b0100 && En_Byte == 4'b0011) begin
					wea_data = 16'h0300;
				end
				else if (En_Word == 4'b0100 && En_Byte == 4'b1100) begin 
					wea_data = 16'h0c00;
				end
				///En_Word == 4'b1000
				else if (En_Word == 4'b1000 && En_Byte == 4'b0011) begin 
					wea_data = 16'h3000;
				end
				else if (En_Word == 4'b1000 && En_Byte == 4'b1100) begin 
					wea_data = 16'hc000;
				end
				//�ֽ�ѡ��
				///En_Word == 4'b0001
				else if (En_Word == 4'b0001 && En_Byte == 4'b0001) begin 
					wea_data = 16'h0001;
				end
				else if (En_Word == 4'b0001 && En_Byte == 4'b0010) begin 
					wea_data = 16'h0002;
				end
				else if (En_Word == 4'b0001 && En_Byte == 4'b0100) begin 
					wea_data = 16'h0004;
				end
				else if (En_Word == 4'b0001 && En_Byte == 4'b1000) begin 
					wea_data = 16'h0008;
				end 
				///En_Word == 4'b0010
				else if (En_Word == 4'b0010 && En_Byte == 4'b0001) begin 
					wea_data = 16'h0010;
				end
				else if (En_Word == 4'b0010 && En_Byte == 4'b0010) begin 
					wea_data = 16'h0020;
				end
				else if (En_Word == 4'b0010 && En_Byte == 4'b0100) begin 
					wea_data = 16'h0040;
				end
				else if (En_Word == 4'b0010 && En_Byte == 4'b1000) begin 
					wea_data = 16'h0080;
				end 
				///En_Word == 4'b0100
				else if (En_Word == 4'b0100 && En_Byte == 4'b0001) begin 
					wea_data = 16'h0100;
				end
				else if (En_Word == 4'b0100 && En_Byte == 4'b0010) begin 
					wea_data = 16'h0200;
				end
				else if (En_Word == 4'b0100 && En_Byte == 4'b0100) begin 
					wea_data = 16'h0400;
				end
				else if (En_Word == 4'b0100 && En_Byte == 4'b1000) begin 
					wea_data = 16'h0800;
				end 
				///En_Word == 4'b1000
				else if (En_Word == 4'b1000 && En_Byte == 4'b0001) begin 
					wea_data = 16'h1000;
				end
				else if (En_Word == 4'b1000 && En_Byte == 4'b0010) begin 
					wea_data = 16'h2000;
				end
				else if (En_Word == 4'b1000 && En_Byte == 4'b0100) begin 
					wea_data = 16'h4000;
				end
				else if (En_Word == 4'b1000 && En_Byte == 4'b1000) begin 
					wea_data = 16'h8000;
				end 
				else
					wea_data = 16'hffff; // default value
			end //end if
			else
				wea_data = 16'h0000;
		end //end always
				
			
		
//////////////////////////////////////////////////////////////////////
//block_ram0:����ʵ��Cache Block�����ʵ�ʵ�����
//////////////////////////////////////////////////////////////////////	
		
		blockRam_data U_Block_RAM_DATA(
				.clk(clk),
				.ena(1'b1),
				.wea(wea_data),
				.addra(Index),
				.dina(Data_In),
				.douta(Data_Out)
		);
		
		
		
		/************************************************************/
		//ʹ��IP��
		//***********************************************************/
		/*
		blk_mem_gen_0 U_Block_RAM_DATA(
								.clka(clk), 		// input 				clka
								.ena(1'b1), 		// input 				ena
								.wea(wea_data), 	// input 	[15:0] 		wea ѡ���ֽ�
								.addra(Index), 		// input 	[9:0] 		addra
								.dina(Data_In), 	// input 	[127:0] 	dina
								.douta(Data_Out) 	// output 	[127:0] 	douta
							);
		*/					
//////////////////////////////////////////////////////////////////////
//block_ram1:��������TAG����Чλ����λ
//////////////////////////////////////////////////////////////////////	

		//����λ����Чλ��Tagλ���뵽��ΪFLAG��Block Ram��
		assign	data_flag = {4'b0000,DirtyNew,ValidNew,Tag_In};
		
		//�洢TAG����Чλ����λʱ�����е��ֽڶ������ˣ����wea_flagΪ3��b111
		always @(*) begin 
			if(Wr == 1) 
				wea_flag = 3'b111;
			else
				wea_flag = 3'b000;
		end //end always
		
		
		
		blockRam_flag U_Block_RAM_FLAG(
				.clk(clk),
				.ena(1'b1),
				.wea(wea_flag),
				.addra(Index),
				.dina(data_flag),
				.douta(data_flag_out)
		);
		/*
		blk_mem_gen_1 U_Block_RAM_FLAG (
								.clka(clk), 		// input 				clka
								.ena(1'b1), 		// input 				ena
								.wea(wea_flag), 	// input 	[2:0] 		wea
								.addra(Index), 		// input 	[9:0] 		addra
								.dina(data_flag), 	// input 	[23:0] 		dina
								.douta(data_flag_out) 	// output 	[23:0] 		douta
							);
		*/				
		assign	Tag_Out = data_flag_out[`Tag_Width-1:0];
		assign	Valid_Out = data_flag_out[`Tag_Width];
		assign 	Dirty_Out = data_flag_out[`Tag_Width+1];
		
endmodule
							
							
		
		