/**********************************************************
//	Note:
//		1.在IMMU中，需要对指令进行权限检测；而在DMMU中，需要
		  对Load/Store类型指令进行权限检测。
***********************************************************/
module IMMU_top(
				clk,rst,
				EA,PID0,PID1,PID2,
				MSR_IS,MSR_PR,
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
	
	wire	[19:0]		EA_EPN;
	wire 				TLB_entry_V;
	wire 				TLB_entry_TS;
	wire	[7:0]		TLB_entry_TID;
	wire	[19:0]		TLB_entry_EPN;
	wire	[5:0]		TLB_entry_PERMIS;
	wire				Hit;

//////////////////////////////////////////////////
//               Judge IMMU entry hit 
//////////////////////////////////////////////////
	assign	EA_EPN = EA[31:12];
	
	HitJudge_IMMU _HitJudge_IMMU(
		.AS(MSR_IS),
		.PID0(PID0), 
		.PID1(PID1), 
		.PID2(PID2), 
		.EA_EPN(EA_EPN),
		.MSR_PR(MSR_PR),
		.TLB_entry_V(TLB_entry_V),
		.TLB_entry_TS(TLB_entry_TS),
		.TLB_entry_TID(TLB_entry_TID),
		.TLB_entry_EPN(TLB_entry_EPN),
		.TLB_entry_PERMIS(TLB_entry_PERMIS),
		.Hit(Hit),
		.Exception(Exception)
	);
	
	
	
	
	
	