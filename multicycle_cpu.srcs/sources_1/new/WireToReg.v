`timescale 1ns / 1ps
module WireToReg(
    input clk,
    input [31:0]datain,
    output reg[31:0]dataout
);
    initial begin
        dataout=32'h00000000;
    end
    always@(negedge clk)begin
        dataout=datain;
    end
endmodule