`timescale 1ns / 1ps
module DataMemory(
    input [1:0] DataMemRW,//11,�ֽ�д��10�ֽڶ���01��д��00�ֶ�
    input [31:0] DAddr,
    input [31:0] DataIn,
    output reg [31:0] DataOut
);
    reg [7:0] memory[0:1023];//1024�ֽڣ�256����
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] <= 0;
        for (i = 0; i < 32; i = i + 1)
            DataOut[i] <= 0;
    end
    always@(*) begin
        if (DAddr<1024) begin
            case(DataMemRW)
            2'b00: begin//�ֶ�
                DataOut<= {memory[DAddr],memory[DAddr+1],memory[DAddr+2],memory[DAddr+3]};
            end
            2'b01: begin//��д
                {memory[DAddr],memory[DAddr+1],memory[DAddr+2],memory[DAddr+3]} <= DataIn;
            end
            2'b10: begin//�ֽڶ�
                DataOut<= {24'b0,memory[DAddr]};
            end
            2'b11: begin//�ֽ�д
                memory[DAddr]<=DataIn[7:0];
            end
            default:begin//�ֶ�
                DataOut[31:24] <= memory[DAddr];
                DataOut[23:16] <= memory[DAddr+1];
                DataOut[15:8] <= memory[DAddr+2];
                DataOut[7:0] <= memory[DAddr+3];
            end
            endcase
        end
        else begin
            DataOut=0;
        end
        
    end
endmodule