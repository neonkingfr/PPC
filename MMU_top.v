module IMMU_top(clk,rst,
			   EA,PID0,PID1,PID2,MSR_IS,MSR_PR,
			   Instruction_Fetch,Store_data,Load_data,
			   Miss,Exception
			   );
			   
	input				clk;
	input				rst;
	input	[31:0]		EA;
	input	[7:0]		PID0;
	input	[7:0]		PID1;
	input	[7:0]		PID2;
	input				MSR_IS;
	input				MSR_PR;
	
	output				Miss；
	output	[4:0]		Exception;
	
	wire 				TLB_entry_V;
	wire 				TLB_entry_TS;
	wire	[7:0]		TLB_entry_TID;
	wire	[31:0]		TLB_entry_EPN;
	wire	[5:0]		TLB_entry_PERMIS;
	wire				Hit;

//////////////////////////////////////////////////
//               Judge entry hit 
//////////////////////////////////////////////////
	HitJudge _HitJudge(
		.PID0(PID0), 
		.PID1(PID1), 
		.PID2(PID2), 
		.AS(MSR_IS),
		.EA(EA),
		.MSR_PR(MSR_PR),
		.Instruction_Fetch(Instruction_Fetch),
		.Store_data(Store_data),
		.Load_data(Load_data),
		.TLB_entry_V(TLB_entry_V),
		.TLB_entry_TS(TLB_entry_TS),
		.TLB_entry_TID(TLB_entry_TID),
		.TLB_entry_EPN(TLB_entry_EPN),
		.TLB_entry_PERMIS(TLB_entry_PERMIS),
		.Hit(Hit),
		.Exception(Exception)
	);
	
	
	
	
	
	