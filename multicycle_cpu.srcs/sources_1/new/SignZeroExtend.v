`timescale 1ns / 1ps

module SignZeroExtend(
    input [1:0] ExtSel,         //控制补位，如果为1x，进行符号扩展；01，immediate全补0；00，sa(dhhh hh00 0000)全补0
    input [15:0] immediate,     //16位立即数输入
    output [31:0] extimm//输出的32位立即数
);
    assign extimm[15:0]=(ExtSel==2'b00)?({11'h000,immediate[10:6]}):immediate[15:0];//sa在指令的第6到第10位
    assign extimm[31:16]=(ExtSel==2'b10)?(immediate[15]?16'b1111111111111111:16'h0000):16'h0000;
endmodule