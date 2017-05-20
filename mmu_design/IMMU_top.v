/**********************************************************
//	Note:
//		1.在IMMU中，需要对指令进行权限检测；而在DMMU中，需要
		  对Load/Store类型指令进行权限检测。
		2.诸如PID0-PID2、MMUCSR0之类的寄存器的初始化动作（未解决？？？？）
***********************************************************/
module IMMU_top(
				clk,rst,
				EA,
				MSR_IS,MSR_PR,
				Miss,Exception
			   );
			   
	input				clk;
	input				rst;
	input	[31:0]		EA;
	
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

	
	
	
/*/////////////////////////////////////////////////
PID0-PID2:进程ID寄存器
	name	bits			description
			32:53 	 		Reserved
	PID		54:63  			Process ID
	
reset value: 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg		[31:0]		PID0;
	reg		[31:0]		PID1;
	reg		[31:0]		PID2;
	
	wire	[7:0]		PID0_DATA;
	wire	[7:0]		PID1_DATA;
	wire	[7:0]		PID2_DATA;
	
	assign 	PID0_DATA = PID0[31:24];
	assign 	PID1_DATA = PID1[31:24];
	assign 	PID2_DATA = PID2[31:24];
	
/*/////////////////////////////////////////////////
MMUCSR0:MMU控制状态寄存器
	name		bits			description
				32:60 			Reserved
	L2TLB0_FI	61    			TLB0 flash invalidate(write 1 to invalidate)
	L2TLB1_FI	62    			TLB1 flash invalidate(write 1 to invalidate)
				63	  			Reserved

reset value : 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg		[31:0]		MMUCSR0;
	wire 				L2TLB0_FI;
	wire				L2TLB1_FI;
	
	assign	L2TLB0_FI_MMUCSR0 = MMUCSR0[29];
	assign	L2TLB1_FI_MMUCSR0 = MMUCSR0[30];
	

/*/////////////////////////////////////////////////
MMUCFG:MMU配置寄存器(Read Only)
	name		bits			description
				32:48 			Reserved
	NPIDS		49:52    		Number of PID registers
	PIDSIZE		53:57			PID registers size 
				58:59			Reserved
	NTLBS		60:61			Number of TLBs
	MAVN		62:63			MMU architecture version number
	
reset value: 32'h0000_31C4 
/////////////////////////////////////////////////*/	
	reg 	[31:0]		MMUCFG;

/*/////////////////////////////////////////////////
TLB0CFG:TLB0配置寄存器(Read Only)
	name		bits			description
	ASSOC		32:39 			Associativity of TLB0
	MINSIZE		40:43			Minimum page size of TLB0
	MAXSIZE		40:47			Maximum page size of TLB0
	IPROT		48				Invalidate protect capability of TLB0
	AVAIL		49				Page size availability of TLB0
				50:51			Reserved
	NENTRY		52:63			Number of entries in TLB0
	
reset value: 32'h0211_0010 (只有16路 entry)
/////////////////////////////////////////////////*/	
	reg		[31:0]		TLB0CFG;
	
/*/////////////////////////////////////////////////
TLB1CFG:TLB1配置寄存器(Read Only)
	name		bits			description
	ASSOC		32:39 			Associativity of TLB1
	MINSIZE		40:43			Minimum page size of TLB1
	MAXSIZE		40:47			Maximum page size of TLB1
	IPROT		48				Invalidate protect capability of TLB1
	AVAIL		49				Page size availability of TLB1
				50:51			Reserved
	NENTRY		52:63			Number of entries in TLB1
	
reset value: 32'h1011_8010(不支持可变页表)
/////////////////////////////////////////////////*/	
	reg		[31:0]		TLB1CFG;
	
/*/////////////////////////////////////////////////
MAS0:
	name		bits			description
				32:34			Reserved
	TLBSEL		35				Selects TLB for access
				36:43			Reserved
	ESEL		44:47			Entry select
				48:61			Reserved
	NV			62:63			Next victim
	
reset value: 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg		[31:0]		MAS0;
	
	wire				TLBSEL_MAS0;
	wire	[3:0]		ESEL_MAS0;
	wire	[1:0]		NV_MAS0;
	
	assign	TLBSEL_MAS0 = MAS0[3];
	assign	ESEL_MAS0 = MAS0[15:12];
	assign	NV_MAS0 = MAS0[31:30];
	
/*/////////////////////////////////////////////////
MAS1:
	name		bits			description
	V			32				TLB valid bit
	IPROT		33				Invalidate protect
				34:39			Reserved
	TID			40:47			Translation identity
				48:50			Reserved
	TS			51				Translation space
	TSIZE		52:55			Translation size
				56:63			Reserved
	
reset value: 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg		[31:0]		MAS1;
	
	wire				V_MAS1;
	wire				IPROT_MAS1;
	wire	[7:0]		TID_MAS1;
	wire				TS_MAS1;
	wire	[3:0]		TSIZE_MAS1;
	
	assign	V_MAS1 = MAS1[0];
	assign	IPROT_MAS1 = MAS1[1];
	assign 	TID_MAS1 = MAS1[15:8];
	assign	TS_MAS1 = MAS1[19];
	assign	TSIZE_MAS1 = MAS1[23:20];
	
/*/////////////////////////////////////////////////
MAS2:
	name		bits			description
	EPN			32:51			Effective page number
				52:56			Reserved
	X0			57				Implementation-dependent page attribute
	X1			58				Implementation-dependent page attribute
	W			59				Write-through
	I			60				Caching-inhibited
	M			61				Memory coherency required
	G			62				Guarded
	E			63				Endianness
	 
reset value: 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg		[31:0]		MAS2;
	
	wire	[19:0]		EPN_MAS2;
	wire	[1:0]		X0_X1_MAS2;
	wire	[4:0]		WIMGE_MAS2;
	
	assign	EPN_MAS2 = MAS2[19:0];
	assign	X0_X1_MAS2 = MAS2[26:25];
	assign	WIMGE_MAS2 = MAS2[31:27];
	

/*/////////////////////////////////////////////////
MAS3:
	name		bits			description
	RPN			32:51			Real page number
				52:53			Reserved
	U0_U3		54:57			User attribute bits
	UX			58				User State Execute Enable
	SX			59				Supervisor State Execute Enable
	UW			60				User State Write Enable
	SW			61				Supervisor State Write Enable
	UR			62				User State Read Enable
	SR			63				Supervisor State Read Enable
		 
reset value: 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg		[31:0]		MAS3;
	
	wire	[19:0]		RPN_MAS3;
	wire	[1:0]		U0_U3_MAS3;
	wire	[5:0]		PERMIS_MAS3;
	
	assign	RPN_MAS3 = MAS3[19:0];
	assign	U0_U3_MAS3 = MAS3[25:22];
	assign	PERMIS_MAS3 = MAS3[31:26];
	
	
/*/////////////////////////////////////////////////
MAS4:
	name		bits			description
				32:33			Reserved
	TLBSELD		34:35			TLBSEL default value
				36:45			Reserved
	TIDSELD		46:47			TID default selection value
				48:51			Reserved
	TSIZED		52:55			Default TSIZE value
				56				Reserved
	X0D			57				Default X0 value
	X1D			58				Default X1 value
	WD			59				Default W value
	ID			60				Default	I value
	MD			61				Default	M value
	GD			62				Default G value
	ED			63				Default E value
		 
reset value: 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg		[31:0]		MAS4;
	
	wire	[1:0]		TLBSELD_MAS4;
	wire	[1:0]		TIDSELD_MAS4;
	wire	[3:0]		TSIZED_MAS4;
	wire	[1:0]		X0D_X1D_MAS4;
	wire	[4:0]		PERMISD_MAS4;
	
	assign	TLBSELD_MAS4 = MAS4[3:2];
	assign	TIDSELD_MAS4 = MAS4[15:14];
	assign	TSIZED_MAS4 = MAS4[23:20];
	assign	X0D_X1D_MAS4 = MAS4[26:25];
	assign	PERMISD_MAS4 = MAS4[31:27];
	
	
/*/////////////////////////////////////////////////
MAS6:
	name		bits			description
				32:39			Reserved
	SPID0		40:47			Search PID0
				48:62			Reserved
	SAS			63				Address space(AS) value for searches
		 
reset value: 32'h0000_0000
/////////////////////////////////////////////////*/	
	reg 	[31:0]		MAS6;
	
	wire	[7:0]		SPID0_MAS6;
	wire				SAS_MAS6;
	
	assign	SPID0_MAS6 = MAS6[15:8];
	assign	SAS_MAS6 = MAS6[31];
	
	

//////////////////////////////////////////////////
//               Judge IMMU entry hit 
//////////////////////////////////////////////////
	assign	EA_EPN = EA[31:12];
	
	HitJudge_IMMU _HitJudge_IMMU(
		.AS(MSR_IS),
		.PID0(PID0_DATA), 
		.PID1(PID1_DATA), 
		.PID2(PID2_DATA), 
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
	
	
	
	
	
	