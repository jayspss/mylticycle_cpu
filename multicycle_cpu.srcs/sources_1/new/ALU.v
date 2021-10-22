`timescale 1ns / 1ps
    module ALU(
    input [3:0] ALUOp,           //ALU������
    input [31:0] A,              //����1
    input [31:0] B,              //����2
    //output reg zero,             //������result�ı�־��result=0���1���������0
    output reg [31:0] result     //ALU������
    );
    always@(ALUOp) begin
        case (ALUOp)
            4'b0000:result=$unsigned(A)+$unsigned(B);   //�޷��ż�
            4'b0001:result=$signed(A)+$signed(B);//�з��ż�
            4'b0010:result=A-B;   //�޷��ż�
            4'b0011:result=$signed(A)-$signed(B);//�з��ż�
            4'b0100:result=A&B;   //��
            4'b0101:result=A|B;   //��
            4'b0110:result=~(A|B);//���nor
            4'b0111:result=A^B;   //���xor
            4'b1000:result=~(A^B);//ͬ��
            4'b1001:result=B<<A;  //sll
            4'b1010:result=B>>A;  //srl
            4'b1011:result=$signed(B)>>A;//sra
            4'b1100:result=($signed(A)<$signed(B))?1:0;   //slt
            4'b1101:result=(A<B)?1:0;                     //sltu
            default:result=0;
        endcase
        /*����zero��־
        if (result)
            zero = 0;
        else
            zero = 1;*/
    end
endmodule