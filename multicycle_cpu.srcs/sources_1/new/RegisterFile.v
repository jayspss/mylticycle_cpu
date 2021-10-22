`timescale 1ns / 1ps

module RegisterFile(
    input clk,
    input RegWre,               //写使能信号，为1时，在时钟上升沿写入
    input [4:0] rs,             //rs寄存器地址输入端口
    input [4:0] rt,             //rt寄存器地址输入端口
    input [4:0] WrRegAddr,       //将数据写入的寄存器端口，其地址来源rt或rd字段
    input [31:0] WrRegData,     //写入寄存器的数据输入端口
    output [31:0] ReadData1,    //rs寄存器数据输出端口
    output [31:0] ReadData2     //rt寄存器数据输出端口
    );

    reg [31:0] register[0:31];  //32个32位寄存器
    integer i;
    initial begin
        for(i = 0; i < 32; i = i + 1)  register[i] <= 0;
    end

    // 读寄存器
    assign ReadData1 = register[rs];
    assign ReadData2 = register[rt];

    // 写寄存器
    always@(posedge clk)
    begin
        // 如果缓存的寄存器地址不为0，并且RegWre为真，写入数据
        if (RegWre && WrRegAddr != 0)  register[WrRegAddr] = WrRegData;
    end 

endmodule