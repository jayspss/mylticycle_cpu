`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input RegWre,               //дʹ���źţ�Ϊ1ʱ����ʱ��������д��
    input [4:0] rs,             //rs�Ĵ�����ַ����˿�
    input [4:0] rt,             //rt�Ĵ�����ַ����˿�
    input [4:0] WrRegAddr,       //������д��ļĴ����˿ڣ����ַ��Դrt��rd�ֶ�
    input [31:0] WrRegData,     //д��Ĵ�������������˿�
    output [31:0] ReadData1,    //rs�Ĵ�����������˿�
    output [31:0] ReadData2     //rt�Ĵ�����������˿�
    );

    reg [31:0] register[0:31];  //32��32λ�Ĵ���
    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1)  register[i] <= 0;
    end

    // ���Ĵ���
    assign ReadData1 = register[rs];
    assign ReadData2 = register[rt];

    // д�Ĵ���
    always@(posedge clk)
    begin
        // �������ļĴ�����ַ��Ϊ0������RegWreΪ�棬д������
        if (RegWre && WrRegAddr != 0)  register[WrRegAddr] = WrRegData;
    end 

endmodule