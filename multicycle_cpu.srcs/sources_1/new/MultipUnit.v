`timescale 1ns / 1ps
module MultipUnit(
    input clk,
    input rst,
    input [31:0] A,
    input [31:0] B,
    input [2:0]MUOp,
    input MUWre,//使能
    output reg [31:0] MUHI,
    output reg [31:0] MULO
    );
    always @(posedge clk) begin
        if (rst) begin
            MUHI=0;
            MULO=0;            
        end
        else if (MUWre) begin
            case(MUOp)
                3'b000:{MUHI,MULO}=$signed(A)*$signed(B);
                3'b001:{MUHI,MULO}=A*B;//vivado默认为无符号乘法
                3'b010:if (B!=0) begin
                    MULO=$signed(A)/$signed(B);
                    MUHI=$signed(A)%$signed(B);
                end
                3'b011:if (B!=0) begin
                    MULO=A/B;
                    MUHI=A%B;
                end
            endcase
        end
    end
endmodule