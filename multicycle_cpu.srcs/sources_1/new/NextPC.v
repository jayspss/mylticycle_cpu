`timescale 1ns / 1ps
module NextPC(
    input rst,
    input [2:0] PCSrc,//PC选择
    input [31:0] currentPC,
    input [31:0] imm,
    input [25:0] addr,//
    input [31:0] rs,
    input [31:0] rt,
    output reg[31:0] nextPC,
    output [31:0] nPC//默认情况下的pc+4
    );
    assign nPC = currentPC+4;
    always@(*) begin
        if(rst)
            nextPC=0;
        else
            case(PCSrc)
                3'b000:nextPC=($signed(rs)==$signed(rt))?(currentPC+4+imm*4):(currentPC+4);//beq
                3'b001:nextPC=($signed(rs)!=$signed(rt))?(currentPC+4+imm*4):(currentPC+4);//bne
                3'b010:nextPC=($signed(rs)>=0)?(currentPC+4+imm*4):(currentPC+4);//bgez
                3'b011:nextPC=($signed(rs)>0)?(currentPC+4+imm*4):(currentPC+4);//bgtz
                3'b100:nextPC=($signed(rs)<=0)?(currentPC+4+imm*4):(currentPC+4);//blez
                3'b101:nextPC=($signed(rs)<0)?(currentPC+4+imm*4):(currentPC+4);//bltz
                3'b110:nextPC=rs;//jr
                3'b111:nextPC={currentPC[31:26],addr};//j,jal
            endcase
    end
endmodule