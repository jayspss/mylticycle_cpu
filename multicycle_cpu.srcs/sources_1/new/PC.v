`timescale 1ns / 1ps

module PC(
   input clk,                    //ʱ��
   input rst,                    //�����ź�
   input PCWre,                  //PC�Ƿ���ģ����Ϊ0��PC������
   input [31:0] nextPC,          //��ָ��
   output reg[31:0] currentPC    //��ǰָ��
   );
   initial
   begin
        currentPC <= 0;  //PC��ʼ��
   end
   always@(posedge clk or posedge rst)
   begin
      if (rst)
         currentPC <= 0;  //������ã���ֵΪ0
      else 
      begin
         if (PCWre)
            currentPC <= nextPC;
         else
            currentPC <= currentPC;
      end
   end
endmodule