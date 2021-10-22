`timescale 1ns / 1ps
module InstructionMemory(
    input clk,          //时钟
    input InsMenRW,     //1写0读
    input [31:0] IAddr, //指令地址
    output reg[5:0] op,
    output reg[4:0] rs,
    output reg[4:0] rt,
    output reg[4:0] rd,
    output reg[5:0] fun,
    output reg[15:0] immediate, //i指令
    output reg[25:0] address,    //j指令
    output reg[31:0] instruction
);
    reg[31:0] mem[0:255];    //256字的数组
    //reg[31:0] instruction;
    initial begin//初始化并读取指令
        op<=0;
        rs<=0;
        rt<=0;
        rd<=0;
        fun<=0;
        immediate<=0;
        address<=0;
        instruction<=0;
        $readmemb("D:/project/vivado/multicycle_cpu/ins.txt",mem);//大端存储,指令的高字节存储在内存的低字节
    end
    //从地址取值，然后输出
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