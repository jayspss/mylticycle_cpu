`timescale 1ns / 1ps
module cpu(
    input clk,
    input rst,
    output [5:0] op,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [5:0] fun,
    output [15:0] immediate,
    output [31:0] RFReData1_reg,
    output [31:0] RFReData2_reg,
    output [31:0] instruction,
    output [31:0] WrRegData,
    output [31:0] DMDataOut_reg,
    output [31:0] curAddress,
    output [31:0] newAddress,
    output [31:0] ALUresult_reg
    //output [2:0] state,
    //output [2:0] PCSrc,
    //output [1:0] WbRegSrc,
    //output [1:0]WbSelReg,
    //output [1:0]DataMemRW,
    //output [1:0]ExtSel
);
    wire [2:0] PCSrc;
    wire [1:0] WbRegSrc,DataMemRW,ExtSel,WbSelReg;
    wire nPCSel,PCWre,ALUSrcA,ALUSrcB,RegWre,InsMemRW;
    wire [31:0] extimm,RFReData1,RFReData2,ALUresult,DMDataOut,nextPC,nPC,ALUA,ALUB;
    wire [25:0] address;
    wire [4:0] WrRegAddr;
    wire [3:0] ALUOp;


    ControlUnit cu(clk,rst,op,rt,fun,PCSrc,nPCSel,PCWre,ALUSrcA,ALUSrcB,RegWre,WbRegSrc,WbSelReg,InsMemRW,DataMemRW,ExtSel,ALUOp);
    PC pc(clk,rst, PCWre, newAddress, curAddress);
    NextPC npc(rst,PCSrc,curAddress,extimm,address,RFReData1_reg,RFReData2_reg,nextPC,nPC);
    InstructionMemory im(clk,InsMemRW,curAddress,op,rs,rt,rd,fun,immediate, address,instruction);
    RegisterFile rf(clk, RegWre, rs, rt, WrRegAddr, WrRegData, RFReData1, RFReData2);
    
    ALU alu(ALUOp,ALUA,ALUB,ALUresult);
    SignZeroExtend sze(ExtSel, immediate, extimm);
    DataMemory dm(DataMemRW, ALUresult_reg, RFReData2_reg, DMDataOut);
    MultipUnit mu();
   
    //线转寄存器
    WireToReg wtrA(clk, RFReData1, RFReData1_reg);
    WireToReg wtrB(clk, RFReData2, RFReData2_reg);
    WireToReg wtrALU(clk, ALUresult, ALUresult_reg);
    WireToReg wtrMEM(clk, DMDataOut, DMDataOut_reg);
    //2路选择器
    MUX2_32 muxALUA(ALUSrcA, RFReData1_reg, extimm, ALUA);
    MUX2_32 muxALUB(ALUSrcB, RFReData2_reg, extimm, ALUB);
    MUX2_32 muxnPC(nPCSel,nPC,nextPC,newAddress);
    //4路选择器
    MUX4_32 muxWbSrc(WbRegSrc,DMDataOut_reg,0,nPC,ALUresult_reg,WrRegData);
    MUX4_5 muxWbSel(WbSelReg,rd,rt,5'b11111,5'b0,WrRegAddr);
endmodule