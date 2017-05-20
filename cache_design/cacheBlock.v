`include "data_def.v"

module cacheBlock(
			clk,
			En_Word,						//Block块内的字使能信号，用来判断选择哪个字
			En_Byte,						//Block块内的字节使能信号，用来实现半字或字节操作。
			Index,							//选择Cache行
			Wr,								//对SRAM的写信号
			ValidNew,						//用于设置valid标志
			DirtyNew,						//用于设置dirty标志
			Data_In, 						//从CPU或者Memory传入的数据
			Tag_In,							//从CPU传入的Tag字段
			
			Dirty_Out,						//从Block中读出的dirty位，用来判断是否进行过写操作
			Valid_Out,						//从Block中读出的valid位，用来检测是否命中
			Tag_Out,						//从Block中读出的Tag字段，用于检测是否命中
			Data_Out						//从Block中读出的数据，用于传回CPU或写入下一级的Memory
			//Rdy_Low							//当下一级Memory完成对Cache Block的写操作后，Rdy_Low
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
//根据En_Word和En_Byte这两个字段来选择Block Ram中实际的数据
//////////////////////////////////////////////////////////////////////
		always @(*) begin
			if(Wr == 1) begin
				//字选择
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
				//半字选择
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
				//字节选择
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
//block_ram0:用来实现Cache Block，存放实际的数据
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
		//使用IP核
		//***********************************************************/
		/*
		blk_mem_gen_0 U_Block_RAM_DATA(
								.clka(clk), 		// input 				clka
								.ena(1'b1), 		// input 				ena
								.wea(wea_data), 	// input 	[15:0] 		wea 选择字节
								.addra(Index), 		// input 	[9:0] 		addra
								.dina(Data_In), 	// input 	[127:0] 	dina
								.douta(Data_Out) 	// output 	[127:0] 	douta
							);
		*/					
//////////////////////////////////////////////////////////////////////
//block_ram1:用来保存TAG、有效位和脏位
//////////////////////////////////////////////////////////////////////	

		//将脏位、有效位、Tag位存入到名为FLAG的Block Ram中
		assign	data_flag = {4'b0000,DirtyNew,ValidNew,Tag_In};
		
		//存储TAG、有效位和脏位时，所有的字节都用上了，因而wea_flag为3‘b111
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
							
							
		
		