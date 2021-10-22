`timescale 1ns / 1ps

module multicycly_cpu_tb;
    reg clk;
    reg rst;
    wire [5:0] op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [5:0] fun;
    wire [15:0] immediate;
    wire [31:0] RFReData1_reg;
    wire [31:0] RFReData2_reg;
    wire [31:0] instruction;
    wire [31:0] WrRegData;
    wire [31:0] DMDataOut_reg;
    wire [31:0] curAddress;
    wire [31:0] newAddress;
    wire [31:0] ALUresult_reg;
    //wire [2:0] state;
    //wire [2:0] PCSrc;
    //wire [1:0] WbRegSrc;
    //wire [1:0]WbSelReg;
    //wire [1:0]DataMemRW;
    //wire [1:0]ExtSel;
    //cpu mcpu(clk,rst,op,rs,rt,rd,fun,immediate,RFReData1_reg,RFReData2_reg,instruction,WrRegData,DMDataOut_reg,curAddress,newAddress,ALUresult_reg,state,PCSrc,WbRegSrc,WbSelReg,DataMemRW,ExtSel);
    cpu mcpu(clk,rst,op,rs,rt,rd,fun,immediate,RFReData1_reg,RFReData2_reg,instruction,WrRegData,DMDataOut_reg,curAddress,newAddress,ALUresult_reg);
    initial begin
        clk=0;
        rst=1;
        #15;
        rst=0;
        #5;
        clk=~clk;
        forever begin // 产生时钟信号，周期为50ns
            #10 clk=~clk;
        end
    end
    //always #10 clk=~clk;
endmodule