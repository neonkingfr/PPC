module HitJudge(
				PID0,PID1,PID2,AS,
				EA,MSR_PR,
				Instruction_Fetch,Store_data,Load_data,
				TLB_entry_V,TLB_entry_TS,TLB_entry_TID,
				TLB_entry_EPN,TLB_entry_PERMIS,
				Hit,Exception);
	
	input	[7:0]		PID0;
	input	[7:0]		PID1;
	input	[7:0]		PID2;
	input				AS;
	input	[31:0]		EA;
	input				MSR_PR;
	input				Instruction_Fetch;
	input				Store_data;
	input				Load_data;
	
	input 				TLB_entry_V;
	input 				TLB_entry_TS;
	input	[7:0]		TLB_entry_TID;
	input	[31:0]		TLB_entry_EPN;
	input	[5:0]		TLB_entry_PERMIS;
	
	output				Hit;
	output	[4:0]		Exception;
	
	
	wire				EA_Match; 				
	wire				PID_Match;
	wire 				Permis_UX;
	wire 				Permis_SX;
	wire 				Permis_UW;
	wire 				Permis_SW;
	wire 				Permis_UR;
	wire 				Permis_SR;
	wire				Permis;
	
	wire				ISI_TLB_UX;
	wire				ISI_TLB_SX;
	wire				DSI_TLB_UW;
	wire				DSI_TLB_SW;
	wire				DSI_TLB_UR;
	wire				DSI_TLB_SR;
	
	wire				Exception_ISI;
	wire				Exception_DSI;

	//TLB match
	assign PID_Match =  (PID0 == TLB_entry_TID) || (PID1 == TLB_entry_TID) || (PID2 == TLB_entry_TID);
	assign EA_Match = (TLB_entry_V == 1'b1 ) && (TLB_entry_TS == AS) && ( TLB_entry_TID == 8'b0 || PID_Match) && (TLB_entry_EPN == EA);
	
	//Permis[5:0] : UX,SX,UW,SW,UR,SR
	assign Permis_UX = (MSR_PR == 1'b1) && (Instruction_Fetch == 1'b1) && (TLB_entry_PERMIS[5] == 1'b1);
	assign Permis_SX = (MSR_PR == 1'b0) && (Instruction_Fetch == 1'b1) && (TLB_entry_PERMIS[4] == 1'b1);
	assign Permis_UW = (MSR_PR == 1'b1) && (Store_data == 1'b1) && (TLB_entry_PERMIS[3] == 1'b1);
	assign Permis_SW = (MSR_PR == 1'b0) && (Store_data == 1'b1) && (TLB_entry_PERMIS[2] == 1'b1);
	assign Permis_UR = (MSR_PR == 1'b1) && (Load_data == 1'b1) && (TLB_entry_PERMIS[1] == 1'b1);
	assign Permis_SR = (MSR_PR == 1'b0) && (Load_data == 1'b1) && (TLB_entry_PERMIS[0] == 1'b1);
	assign Permis = Permis_UX || Permis_SX || Permis_UW || Permis_SW || Permis_UR || Permis_SR;
	
	//Hit
	assign Hit = EA_Match && Permis;
	
	//detect ISI Interupt
	assign	ISI_TLB_UX = (MSR_PR == 1'b1) && (Instruction_Fetch == 1'b1) && (TLB_entry_PERMIS[5] == 1'b0);
	assign	ISI_TLB_SX = (MSR_PR == 1'b0) && (Instruction_Fetch == 1'b1) && (TLB_entry_PERMIS[4] == 1'b0);
	assign	Exception_ISI = ISI_TLB_UX || ISI_TLB_SX;
	
	//detect DSI Interupt
	assign	DSI_TLB_UW = (MSR_PR == 1'b1) && (Store_data == 1'b1) && (TLB_entry_PERMIS[3] == 1'b0);
	assign	DSI_TLB_SW = (MSR_PR == 1'b0) && (Store_data == 1'b1) && (TLB_entry_PERMIS[2] == 1'b0);
	assign	DSI_TLB_UR = (MSR_PR == 1'b1) && (Load_data == 1'b1) && (TLB_entry_PERMIS[1] == 1'b0);
	assign	DSI_TLB_SR = (MSR_PR == 1'b0) && (Load_data == 1'b1) && (TLB_entry_PERMIS[0] == 1'b0);
	assign	Exception_DSI = DSI_TLB_UW || DSI_TLB_SW || DSI_TLB_UR || DSI_TLB_SR;
	
	always @(*) begin
		if(Exception_ISI == 1'b1) begin
			Exception = `ISI;
		end
		if(Exception_DSI == 1'b1) begin
			Exception = `DSI;
		end
	end
	
endmodule
	
	
	
	
	
	