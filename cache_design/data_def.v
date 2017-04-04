
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
//����128��ʾCache Block�Ĵ�СΪ4�֣�16�ֽڣ�
`define Cache_Block_Size 128
`define Memory_Block_Size 128

//the size of Tag+Valid+Dirty
//��Ҫ��������Դﵽ�����ֽ�
`define flag_Tag_Size 24

//the width of A_Low
//����28��ʾTag�ֶ�+Index�ֶεĳ��ȣ���16KB��Cache��С����28
`define Width_of_A_Low 28

//the width of Tag
//��ַ��ǣ���16KB��Cache��С��Cache blockΪ4�ֵ�����£�Tag�ֶ�Ϊ18λ
`define Tag_Width 18

//the width of Index
//Index�ֶ�����ѡ��Cache�У���16KB��Cache��С��Cache blockΪ4�ֵ�����£����ֶ�Ϊ10λ����ʾ��1024��Cache��
`define Index_Width 10

//the width of word select
//���ֶ�����ѡ���֣���4�ֵ�����£����ֶ�Ϊ2λ
`define Word_Select_Width 2

//the width of byte select
//���ֶ�����ѡ���ֽڣ���4�ֵ�����£����ֶ�Ϊ2λ
`define Byte_Select_Width 2

//the width of Wn ,
//Wn�ֶ���������Mux,��ѡ����ʵ�����(DI_CPU����DI_Low)����Cache Block
`define Wn_Width 4

//the width of En_Word
//En_Word�ֶ�����ʹ���ֶΣ��ֱ��Ӧ�ĸ���
`define En_Word_Width 4

//the width of En_Byte
//En_Byte�ֶ����ֽ�ʹ���ֶΣ�
`define En_Byte_Width 4

//word instruction
`define Word_Instruction 2'b00

//half word instruction
`define Half_Instruction 2'b01

//Byte instruction
`define Byte_Instruction 2'b10

