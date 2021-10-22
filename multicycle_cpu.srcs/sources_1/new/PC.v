`timescale 1ns / 1ps

module PC(
   input clk,                    //时钟
   input rst,                    //重置信号
   input PCWre,                  //PC是否更改，如果为0，PC不更改
   input [31:0] nextPC,          //新指令
   output reg[31:0] currentPC    //当前指令
   );
   initial
   begin
        currentPC <= 0;  //PC初始化
   end
   always@(posedge clk or posedge rst)
   begin
      if (rst)
         currentPC <= 0;  //如果重置，赋值为0
      else 
      begin
         if (PCWre)
            currentPC <= nextPC;
         else
            currentPC <= currentPC;
      end
   end
endmodule