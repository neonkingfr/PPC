/*
** cache_controller的基本信息：
**    (1)采用有限状态机机制，分为INIT、TAG、MB、WB四个状态
**    
*/

module cache_controller(
			//input
			clk,rst,
			Req_CPU,Wr_CPU,
			Rdy_Low,
			Dirty,Hit,Word_Select,
			//output
			Rdy_CPU,
			Req_Low,Wr_Low,
			Wn,ValidNew,DirtyNew,En_Word,En_Byte,Wr,
			ASel
			);
		
	input								clk;
	input								rst;
	input								Req_CPU;
	input								Wr_CPU;
	input								Rdy_Low;
	input								Dirty;
	input								Hit;
	input	[`Word_Select_Width-1:0]	Word_Select;
	
	output								Rdy_CPU;
	output								Req_Low;
	output								Wr_Low;
	output	[`Wn_Width-1:0]				Wn;
	output								ValidNew;
	output								DirtyNew;
	output	[`En_Word_Width-1:0]		En_Word;
	output	[`En_Byte_Width-1:0]		En_Byte;
	output								Wr;
	output								ASel;
	
/******************************FSM*********************************/
	parameter INIT = 2'b00;
	parameter TAG  = 2'b01;
	parameter MB   = 2'b10;
	parameter WB   = 2'b11;
	
	reg [1:0] state;
	reg [1:0] nextstate;
	
	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			state <= INIT;
		else begin
			state <= nextstate;
		end
	end // end always
	
	
			
			
			
			