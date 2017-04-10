`include "data_def.v"
module memory(	clk,
				Req_Low,
				addr,din,Wr,
				dout,
				Rdy_Low
		);
		input 								clk;
		input								Req_Low;
		input	[9:0]						addr;
		input	[`Memory_Block_Size-1:0]	din;
		input								Wr;
		
		output	[`Memory_Block_Size-1:0]	dout;
		output								Rdy_Low;
		
		reg		[15:0]						wea;
		reg                                 Rdy_Low_temp;
		reg                                 Rdy_Low;
		
	
		always @(posedge clk) begin
			if(Wr)	
				wea = 16'hffff;
			else
				wea = 16'h0000;
		end //end always
		
		Memory _memory (
			.clka(clk),    // input wire clka
			.wea(wea),      // input wire [15 : 0] wea
			.addra(addr),  // input wire [9 : 0] addra
			.dina(din),    // input wire [127 : 0] dina
			.douta(dout)  // output wire [127 : 0] douta
		);
	
	   //assign Rdy_Low  =  Req_Low; 
		always @(posedge clk) begin 
		 
		 Rdy_Low  <=  Req_Low; 
		end
endmodule