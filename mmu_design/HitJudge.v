/************************************************************
**  IMMU
*************************************************************/
module HitJudge_IMMU(
				AS,PID0,PID1,PID2,
				EA_EPN,MSR_PR,
				TLB_entry_V,TLB_entry_TS,TLB_entry_TID,
				TLB_entry_EPN,TLB_entry_PERMIS,
				Hit,Exception
			);
	//input from external
	input				AS;
	input	[7:0]		PID0;
	input	[7:0]		PID1;
	input	[7:0]		PID2;
	input	[19:0]		EA_EPN;
	input				MSR_PR;
	//input from TLB
	input 				TLB_entry_V;
	input 				TLB_entry_TS;
	input	[7:0]		TLB_entry_TID;
	input	[19:0]		TLB_entry_EPN;
	input	[5:0]		TLB_entry_PERMIS;
	
	output				Hit;
	output	[4:0]		Exception;
	
	wire				PID_Match;
	wire				TLB_Match; 
	
	wire 				Permis_UX;
	wire 				Permis_SX;
	wire				Permis;
	
	wire				ISI_TLB_UX;
	wire				ISI_TLB_SX;
	
	wire				Exception_ISI;
	

	//TLB: (V,TS,EPN,PID) match
	assign PID_Match = (TLB_entry_TID == 8'h00) || (PID0 == TLB_entry_TID) || (PID1 == TLB_entry_TID) || (PID2 == TLB_entry_TID);
	assign TLB_Match = (TLB_entry_V == 1'b1 ) && (TLB_entry_TS == AS) && PID_Match && (TLB_entry_EPN == EA_EPN);
	
	//Permis[5:0] : SR,UR,SW,UW,SX,UX     
	assign Permis_UX = (MSR_PR == 1'b1) && (TLB_entry_PERMIS[0] == 1'b1);
	assign Permis_SX = (MSR_PR == 1'b0) && (TLB_entry_PERMIS[1] == 1'b1);
	assign Permis = Permis_UX || Permis_SX;
	
	//Hit
	assign Hit = TLB_Match && Permis;
	
	//detect ISI Interupt
	assign	ISI_TLB_UX = (MSR_PR == 1'b1) && (TLB_entry_PERMIS[0] == 1'b0);
	assign	ISI_TLB_SX = (MSR_PR == 1'b0) && (TLB_entry_PERMIS[1] == 1'b0);
	assign	Exception_ISI = ISI_TLB_UX || ISI_TLB_SX;
	
	assign	Exception = Exception_ISI ? `ISI : 5'b00000;
	
endmodule
	
	
	
/************************************************************
**  DMMU
*************************************************************/	
	
module HitJudge_DMMU(
				AS,PID0,PID1,PID2,
				EA_EPN,MSR_PR,
				TLB_entry_V,TLB_entry_TS,TLB_entry_TID,
				TLB_entry_EPN,TLB_entry_PERMIS,
				Ins_Type,
				Hit,Exception
			);
	//input from external
	input				AS;
	input	[7:0]		PID0;
	input	[7:0]		PID1;
	input	[7:0]		PID2;
	input	[19:0]		EA_EPN;
	input				MSR_PR;
	//input from TLB
	input 				TLB_entry_V;
	input 				TLB_entry_TS;
	input	[7:0]		TLB_entry_TID;
	input	[19:0]		TLB_entry_EPN;
	input	[5:0]		TLB_entry_PERMIS;
	input				Ins_Type;		// 0:Load Instruction
										// 1:Store Instruction
	
	output				Hit;
	output	[4:0]		Exception;

	wire				PID_Match;
	wire				TLB_Match; 
	
	wire 				Permis_UW;
	wire 				Permis_SW;
	wire 				Permis_UR;
	wire 				Permis_SR;
	wire				Permis;
	
	
	wire				DSI_TLB_UW;
	wire				DSI_TLB_SW;
	wire				DSI_TLB_UR;
	wire				DSI_TLB_SR;
	
	wire				Exception_DSI;

	//TLB: (V,TS,EPN,PID) match
	assign PID_Match = (TLB_entry_TID == 8'h00) || (PID0 == TLB_entry_TID) || (PID1 == TLB_entry_TID) || (PID2 == TLB_entry_TID);
	assign TLB_Match = (TLB_entry_V == 1'b1 ) && (TLB_entry_TS == AS) && PID_Match && (TLB_entry_EPN == EA_EPN);
	

	//Permis[5:0] : SR,UR,SW,UW,SX,UX    
	assign Permis_UW = (MSR_PR == 1'b1) && (Ins_Type == 1'b1) && (TLB_entry_PERMIS[2] == 1'b1);
	assign Permis_SW = (MSR_PR == 1'b0) && (Ins_Type == 1'b1) && (TLB_entry_PERMIS[3] == 1'b1);
	assign Permis_UR = (MSR_PR == 1'b1) && (Ins_Type == 1'b0) && (TLB_entry_PERMIS[4] == 1'b1);
	assign Permis_SR = (MSR_PR == 1'b0) && (Ins_Type == 1'b0) && (TLB_entry_PERMIS[5] == 1'b1);
	assign Permis = Permis_UW || Permis_SW || Permis_UR || Permis_SR;
	
	//Hit
	assign Hit = TLB_Match && Permis;
	
	//detect DSI Interupt
	assign	DSI_TLB_UW = (MSR_PR == 1'b1) && (Ins_Type == 1'b1) && (TLB_entry_PERMIS[2] == 1'b0);
	assign	DSI_TLB_SW = (MSR_PR == 1'b0) && (Ins_Type == 1'b1) && (TLB_entry_PERMIS[3] == 1'b0);
	assign	DSI_TLB_UR = (MSR_PR == 1'b1) && (Ins_Type == 1'b0) && (TLB_entry_PERMIS[4] == 1'b0);
	assign	DSI_TLB_SR = (MSR_PR == 1'b0) && (Ins_Type == 1'b0) && (TLB_entry_PERMIS[5] == 1'b0);
	assign	Exception_DSI = DSI_TLB_UW || DSI_TLB_SW || DSI_TLB_UR || DSI_TLB_SR;
	
	assign	Exception = Exception_DSI ? `DSI : 5'b00000;
	
endmodule
	
	