`timescale 1ns / 1ps
    module ALU(
    input [3:0] ALUOp,           //ALU操作码
    input [31:0] A,              //输入1
    input [31:0] B,              //输入2
    //output reg zero,             //运算结果result的标志，result=0输出1，否则输出0
    output reg [31:0] result     //ALU运算结果
    );
    always@(ALUOp) begin
        case (ALUOp)
            4'b0000:result=$unsigned(A)+$unsigned(B);   //无符号加
            4'b0001:result=$signed(A)+$signed(B);//有符号加
            4'b0010:result=A-B;   //无符号减
            4'b0011:result=$signed(A)-$signed(B);//有符号减
            4'b0100:result=A&B;   //与
            4'b0101:result=A|B;   //或
            4'b0110:result=~(A|B);//或非nor
            4'b0111:result=A^B;   //异或xor
            4'b1000:result=~(A^B);//同或
            4'b1001:result=B<<A;  //sll
            4'b1010:result=B>>A;  //srl
            4'b1011:result=$signed(B)>>A;//sra
            4'b1100:result=($signed(A)<$signed(B))?1:0;   //slt
            4'b1101:result=(A<B)?1:0;                     //sltu
            default:result=0;
        endcase
        /*设置zero标志
        if (result)
            zero = 0;
        else
            zero = 1;*/
    end
endmodule