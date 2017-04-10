`include "data_def.v"

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
			Wn,ValidNew,DirtyNew,En_Word,Wr,
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
	//input 	[`Byte_Select_Width-1:0]	Byte_Select;
	
	output								Rdy_CPU;
	output								Req_Low;
	output								Wr_Low;
	output	[`Wn_Width-1:0]				Wn;
	output								ValidNew;
	output								DirtyNew;
	output	[`En_Word_Width-1:0]		En_Word;
	//output	[`En_Byte_Width-1:0]		En_Byte;
	output								Wr;
	output								ASel;
	
	reg   [`En_Word_Width-1:0]		     En_Word;
	reg   [`Wn_Width-1:0]				 Wn;
	
                        
/******************************FSM*********************************/
	parameter INIT = 2'b00;
	parameter TAG  = 2'b01;
	parameter MB   = 2'b10;
	parameter WB   = 2'b11;
	
	parameter Word_Select_0 = 2'b00;
	parameter Word_Select_1 = 2'b01;
	parameter Word_Select_2 = 2'b10;
	parameter Word_Select_3 = 2'b11;
	
	parameter En_Word_0 = 4'b0001;
	parameter En_Word_1 = 4'b0010;
	parameter En_Word_2 = 4'b0100;
	parameter En_Word_3 = 4'b1000;
	parameter En_Word_MB =4'b1111;
	parameter En_Word_default = 4'b0000;
	
	
	parameter Wn_0 = 4'b1110;
	parameter Wn_1 = 4'b1101;
	parameter Wn_2 = 4'b1011;
	parameter Wn_3 = 4'b0111;
	parameter Wn_MB_Read = 4'b1111;
	parameter Wn_TAG = 4'b0000;
	parameter Wn_default = 4'b0000;
	
	reg [1:0] state;
	reg [1:0] nextstate;
	
	always @(posedge clk ) begin
		if (rst) begin
			state <= INIT;
		end
		else begin
			state <= nextstate;
		end
	end // end always
	
	//状态机状态迁移
	always @( * ) begin
		case (state)
		INIT: begin
			nextstate = TAG;
		end
		
		TAG: begin
			if (Req_CPU && ~Hit && Dirty)
				nextstate = WB;
			else if (Req_CPU && ~Hit && ~Dirty)
				nextstate = MB;
			else
				nextstate = TAG;
		end
		
		WB: begin
			if (Rdy_Low)
				nextstate = MB;
			else
				nextstate = WB;
		end
		
		MB: begin
			if (Rdy_Low)
				nextstate = TAG;
			else
				nextstate = MB;
		end
		
		default: begin
			nextstate = INIT;
		end
		endcase
	end // end always
		
	
/*******************************控制信号***************************/
	
	/*******************产生写允许信号Wr***************************
		(1)在TAG状态下，CPU有写操作的请求
		(2)在MB状态下，来自下一级Memory的数据已经准备好
	*************************************************************/
	assign Wr = ((state==TAG) && Wr_CPU) || (state==MB && Rdy_Low && Wr_CPU);
	//assign Wr = ((state==TAG) && Wr_CPU) || (state==MB && Rdy_Low && Wr_CPU);
	
	
	/*******************4位字使能En_Word****************************
		(1)在TAG状态下，根据CPU传入的A_CPU[3:2]，即Word_Select，
		   来完成En_Word的赋值。
		(2)在MB状态下，En_Word的所有位有效。
	**************************************************************/
	always @( * ) begin
		if(state == TAG) begin
			case(Word_Select)
			Word_Select_0:begin
				 En_Word = En_Word_0;
			end
			
			Word_Select_1:begin
				 En_Word = En_Word_1;
			end
			
			Word_Select_2:begin
				 En_Word = En_Word_2;
			end
			
			Word_Select_3:begin
				 En_Word = En_Word_3;
			end
			
			default:begin
				 En_Word = En_Word_0;
			end
			endcase
		end 
		else if (state == MB)begin
			 En_Word = En_Word_MB;
		end
		else 
			 En_Word = En_Word_default;
	end //end always
		
		
	/**********************4位Mux控制信号Wn *******************
		(1)在TAG状态下全为0，表明写操作直接使用CPU的值。
		(2)在MB状态下，读操作直接选择Memory中的值，写操作就混合CPU,Memory
	**************************************************************/
	always @(*) begin
		if(state == TAG) begin
			 Wn = Wn_TAG;
		end
		else if(state == MB)begin
			if(Wr_CPU) begin
				case(Word_Select)
				Word_Select_0:begin
					 Wn = Wn_0;
				end
			
				Word_Select_1:begin
					 Wn = Wn_1;
				end
			
				Word_Select_2:begin
					 Wn = Wn_2;
				end
			
				Word_Select_3:begin
					 Wn = Wn_3;
				end
			
				default:begin
					 Wn = Wn_0;
				end
				endcase
			end
			else begin
				 Wn = Wn_MB_Read;
			end
		end
		else begin
			 Wn = Wn_default;
		end
	end //end always
			
	/*******************ValidNew信号***************************
		(1)置位cache block是否有效
	*************************************************************/
	assign ValidNew = (state == TAG) || (state == MB);
	
	
	/*******************DirtyNew信号***************************
		(1)表明Cache Block是否被修改
	*************************************************************/
	assign DirtyNew = (state == TAG) || (state==MB && Wr_CPU);
	
	
	/*******************ASel信号***************************
		(1)控制器通过ASel选择输出CPU地址，
		(2)默认是A_CPU[31:4],否则为{Tag_Cache,A_CPU[11:4]}
		(3)在WB状态下有效，表示输出该Cache块的主存地址
	*************************************************************/
	assign ASel = (state == WB);
	
	
	/*******************Rdy_CPU信号***************************
		(1)表明可以返回Cache中的值给CPU
	*************************************************************/
	/*？？？在MB阶段就返回Rdy_Low,同时转向TAG状态，Rdy_Low继续有效，
	那么问题来了，当产生Rdy_Low信号后，并不能马上读取Cache中的数据。
	*/
	

	assign Rdy_CPU = (state == TAG && Hit == 1 );
	//assign Rdy_CPU = (state == TAG) || ((state==MB) && Rdy_Low);
	
	
	
	/*******************Req_Low信号***************************
		(1)需要向Memory回写数据或从Memory中获取数据时置位
	*************************************************************/

	assign Req_Low = (state == WB || state == MB);
	
	/*******************Wr_Low信号***************************
		(1)需要向Memory回写数据时置位
	*************************************************************/
	assign Wr_Low = (state == WB);

endmodule
	

	
		
		
			
		
		
	
	
	
	
			
			
			
			