`include "G:/PPC/cache_design/data_def.v"
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/07 15:20:29
// Design Name: 
// Module Name: Top_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Top_sim();
     reg                clk;
     reg                rst;
//     reg                Req_CPU;
//     reg                Wr_CPU;
//     reg    [31:0]      A_CPU;
//     reg    [31:0]      DI_CPU;
//     reg    [1:0]       Ins_Type;
//     wire               Rdy_CPU;
//     wire   [31:0]      DO_CPU;
//     reg    [1:0]       count;
     
     initial    begin
        clk=0;
//        Req_CPU=1;
//        Wr_CPU=1;
//        A_CPU=1;
//        DI_CPU=30;
//        Ins_Type=0;
//        count=0;
        rst=0;
        #10;
        rst=1;
        #20;
        rst=0;
     end
     
     always #5 clk = ~clk;
     
//     always@(posedge clk) begin
//        count = count + 1;
//        if(count == 2) begin
//            Wr_CPU = 0;
//        end
//        else if(count == 3) begin 
//            Wr_CPU = 1;
//            A_CPU = A_CPU + 1;
//            DI_CPU = DI_CPU + 1;
//            count = 0;
//        end
//        else begin
//            Wr_CPU = 1;
//        end
//     end // end always
     
//     always@(*) begin 
//        if(A_CPU == 30)
//            A_CPU = 0;
//     end //end always
     
    
     Top _TOP(
        .clk(clk),
        .rst(rst)
//        .Req_CPU(Req_CPU),            //����CPU�������ź� 
//        .Wr_CPU(Wr_CPU),                //����CPU�Ķ�д�źţ�����Ϊ1��ʾ��д������Ϊ0��ʾ�Ƕ�����
//        .A_CPU(A_CPU),                //����CPU�ĵ�ַ�ź�
//        .DI_CPU(DI_CPU),
//        .Ins_Type(Ins_Type),            //��ʾָ������ͣ��֡����֡��ֽڣ�
//        //output
//        .Rdy_CPU(Rdy_CPU),            //��CPU���ݵ�����źţ�������ʱΪ1������ȱʧ�ͷ���0����CPU�ȴ�Cacheִ�����
//        .DO_CPU(DO_CPU)                //��Cache���ظ�CPU������        
        );
    
    
endmodule
