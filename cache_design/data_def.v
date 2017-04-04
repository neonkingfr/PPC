
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Master he
// 
// Create Date:    12:32:15 11/17/2016 
// Design Name: 
// Module Name:    data_def 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//the size of Cache block
//其中128表示Cache Block的大小为4字（16字节）
`define Cache_Block_Size 128
`define Memory_Block_Size 128

//the size of Tag+Valid+Dirty
//需要比特填充以达到整数字节
`define flag_Tag_Size 24

//the width of A_Low
//其中28表示Tag字段+Index字段的长度，在16KB的Cache大小下是28
`define Width_of_A_Low 28

//the width of Tag
//地址标记，在16KB的Cache大小，Cache block为4字的情况下，Tag字段为18位
`define Tag_Width 18

//the width of Index
//Index字段用来选择Cache行，在16KB的Cache大小，Cache block为4字的情况下，该字段为10位，表示有1024个Cache行
`define Index_Width 10

//the width of word select
//该字段用来选择字，在4字的情况下，该字段为2位
`define Word_Select_Width 2

//the width of byte select
//该字段用来选择字节，在4字的情况下，该字段为2位
`define Byte_Select_Width 2

//the width of Wn ,
//Wn字段用来控制Mux,以选择合适的数据(DI_CPU或者DI_Low)进入Cache Block
`define Wn_Width 4

//the width of En_Word
//En_Word字段是字使能字段，分别对应四个字
`define En_Word_Width 4

//the width of En_Byte
//En_Byte字段是字节使能字段，
`define En_Byte_Width 4

//word instruction
`define Word_Instruction 2'b00

//half word instruction
`define Half_Instruction 2'b01

//Byte instruction
`define Byte_Instruction 2'b10

