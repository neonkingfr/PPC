`include "data_def.v"

/*
** cache_controller�Ļ�����Ϣ��
**    (1)��������״̬�����ƣ���ΪINIT��TAG��MB��WB�ĸ�״̬
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
	
	//״̬��״̬Ǩ��
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
		
	
/*******************************�����ź�***************************/
	
	/*******************����д�����ź�Wr***************************
		(1)��TAG״̬�£�CPU��д����������
		(2)��MB״̬�£�������һ��Memory�������Ѿ�׼����
	*************************************************************/
	assign Wr = ((state==TAG) && Wr_CPU) || (state==MB && Rdy_Low && Wr_CPU);
	//assign Wr = ((state==TAG) && Wr_CPU) || (state==MB && Rdy_Low && Wr_CPU);
	
	
	/*******************4λ��ʹ��En_Word****************************
		(1)��TAG״̬�£�����CPU�����A_CPU[3:2]����Word_Select��
		   �����En_Word�ĸ�ֵ��
		(2)��MB״̬�£�En_Word������λ��Ч��
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
		
		
	/**********************4λMux�����ź�Wn *******************
		(1)��TAG״̬��ȫΪ0������д����ֱ��ʹ��CPU��ֵ��
		(2)��MB״̬�£�������ֱ��ѡ��Memory�е�ֵ��д�����ͻ��CPU,Memory
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
			
	/*******************ValidNew�ź�***************************
		(1)��λcache block�Ƿ���Ч
	*************************************************************/
	assign ValidNew = (state == TAG) || (state == MB);
	
	
	/*******************DirtyNew�ź�***************************
		(1)����Cache Block�Ƿ��޸�
	*************************************************************/
	assign DirtyNew = (state == TAG) || (state==MB && Wr_CPU);
	
	
	/*******************ASel�ź�***************************
		(1)������ͨ��ASelѡ�����CPU��ַ��
		(2)Ĭ����A_CPU[31:4],����Ϊ{Tag_Cache,A_CPU[11:4]}
		(3)��WB״̬����Ч����ʾ�����Cache��������ַ
	*************************************************************/
	assign ASel = (state == WB);
	
	
	/*******************Rdy_CPU�ź�***************************
		(1)�������Է���Cache�е�ֵ��CPU
	*************************************************************/
	/*��������MB�׶ξͷ���Rdy_Low,ͬʱת��TAG״̬��Rdy_Low������Ч��
	��ô�������ˣ�������Rdy_Low�źź󣬲��������϶�ȡCache�е����ݡ�
	*/
	

	assign Rdy_CPU = (state == TAG && Hit == 1 );
	//assign Rdy_CPU = (state == TAG) || ((state==MB) && Rdy_Low);
	
	
	
	/*******************Req_Low�ź�***************************
		(1)��Ҫ��Memory��д���ݻ��Memory�л�ȡ����ʱ��λ
	*************************************************************/

	assign Req_Low = (state == WB || state == MB);
	
	/*******************Wr_Low�ź�***************************
		(1)��Ҫ��Memory��д����ʱ��λ
	*************************************************************/
	assign Wr_Low = (state == WB);

endmodule
	

	
		
		
			
		
		
	
	
	
	
			
			
			
			