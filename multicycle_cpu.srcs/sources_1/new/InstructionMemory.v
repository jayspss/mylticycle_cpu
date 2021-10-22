`timescale 1ns / 1ps
module InstructionMemory(
    input clk,          //ʱ��
    input InsMenRW,     //1д0��
    input [31:0] IAddr, //ָ���ַ
    output reg[5:0] op,
    output reg[4:0] rs,
    output reg[4:0] rt,
    output reg[4:0] rd,
    output reg[5:0] fun,
    output reg[15:0] immediate, //iָ��
    output reg[25:0] address,    //jָ��
    output reg[31:0] instruction
);
    reg[31:0] mem[0:255];    //256�ֵ�����
    //reg[31:0] instruction;
    initial begin//��ʼ������ȡָ��
        op<=0;
        rs<=0;
        rt<=0;
        rd<=0;
        fun<=0;
        immediate<=0;
        address<=0;
        instruction<=0;
        $readmemb("D:/project/vivado/multicycle_cpu/ins.txt",mem);//��˴洢,ָ��ĸ��ֽڴ洢���ڴ�ĵ��ֽ�
    end
    //�ӵ�ַȡֵ��Ȼ�����
    always@(posedge clk) begin
        instruction=mem[IAddr/4];
        op=instruction[31:26];
        rs=instruction[25:21];
        rt=instruction[20:16];
        rd=instruction[15:11];
        fun=instruction[5:0];
        immediate=instruction[15:0];
        address=instruction[25:0];
    end
endmodule