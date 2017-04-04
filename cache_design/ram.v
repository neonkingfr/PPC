module ram(
			clk,
			
			
			
			
			
			
			
			// input 				clka
								.ena(Wr), 			// input 				ena
								.wea(wea_data), 	// input 	[15:0] 		wea 选择字节
								.addra(Index), 		// input 	[9:0] 		addra
								.dina(Data_In), 	// input 	[127:0] 	dina
								.douta(Data_Out)
		);