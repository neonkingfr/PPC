
module memory_II(
				clk;
				Req_Low;
				addr,
				din,
				Wr,
				dout,
				Rdy_Low
		);
		input								clk;
		input								Req_Low;
		input	[`Width_of_A_Low-1:0]		addr;
		input	[`Memory_Block_Size-1:0]	din;
		input								Wr;
		
		output	[`Memory_Block_Size-1:0]	dout;
		output								Rdy_Low;
		
		
		reg		[15:0]						wea;
		reg                                 Rdy_Low_temp;	