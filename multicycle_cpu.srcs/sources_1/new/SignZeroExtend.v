`timescale 1ns / 1ps

module SignZeroExtend(
    input [1:0] ExtSel,         //���Ʋ�λ�����Ϊ1x�����з�����չ��01��immediateȫ��0��00��sa(dhhh hh00 0000)ȫ��0
    input [15:0] immediate,     //16λ����������
    output [31:0] extimm//�����32λ������
);
    assign extimm[15:0]=(ExtSel==2'b00)?({11'h000,immediate[10:6]}):immediate[15:0];//sa��ָ��ĵ�6����10λ
    assign extimm[31:16]=(ExtSel==2'b10)?(immediate[15]?16'b1111111111111111:16'h0000):16'h0000;
endmodule