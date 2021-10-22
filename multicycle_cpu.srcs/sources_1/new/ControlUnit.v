`timescale 1ns / 1ps

module ControlUnit(
    input clk,              //时钟
    input rst,              //重置
    input [5:0] op,         //指令操作
    input [4:0] rt,
    input [5:0] fun,
    output reg[2:0] PCSrc,  //PC指令来源
    output reg nPCSel,      //0选择PC+4，1选择跳转或分支的地址
    output reg PCWre,       //PC是否更改，如果为0，PC不更改，IF状态可改
    output reg ALUSrcA,     //
    output reg ALUSrcB,     //
    output reg RegWre,      //寄存器写使能信号，为1时，在时钟上沿写入
    output reg[1:0] WbRegSrc,    //写入寄存器的数据来源，00lw,lb,10jal,11alu
    output reg[1:0] WbSelReg, //选择写回到哪个寄存器
    output reg InsMemRW,    //指令存储器读写控制信号，1写，0读
    output reg[1:0] DataMemRW,   //数据存储器数据存储器读写控制信号，1写，0读
    output reg[1:0] ExtSel, //如果为1x，进行符号扩展；01，immediate全补0；00，sa(dhhh hh00 0000)全补0
    output reg[3:0] ALUOp    //ALU操作控制操作码
    //output reg[2:0] state
    );
    reg[2:0] state;
    parameter[5:0]
        op_r=6'b000000,
        op_addi=6'b001000,
        op_addiu=6'b001001,
        op_andi=6'b001100,
        op_ori=6'b001101,
        op_xori=6'b001110,
        op_sw=6'b101011,
        op_lw=6'b100011,
        op_sb=6'b101000,
        op_lb=6'b100000,
        op_beq=6'b000100,
        op_bgez=6'b000001,
        op_bgtz=6'b000111,
        op_blez=6'b000110,
        op_bltz=6'b000001,
        op_bne=6'b000101,
        op_j=6'b000010,
        op_jal=6'b000011,
        op_halt=6'b111111,

        funct_add=6'b100000,
        funct_addu=6'b100001,
        funct_sub=6'b100010,
        funct_subu=6'b100011,
        //funct_mult=6'b011000,
        //funct_multu=6'b011001,
        //funct_div=6'b011010,
        //funct_divu=6'b011011,
        funct_and=6'b100100,
        funct_or=6'b100101,
        funct_nor=6'b100111,
        funct_xor=6'b100110,
        funct_slt=6'b101010,
        funct_sltu=6'b101011,
        funct_sll=6'b000000,
        funct_srl=6'b000010,
        funct_sra=6'b000011,
        funct_sllv=6'b000100,
        funct_srlv=6'b000110,
        funct_srav=6'b000111,
        //funct_mfhi=6'b010000;
        //funct_mflo=6'b010010;
        funct_jr=6'b001000;

    parameter[4:0]
        rt_bgez=5'b00001,
        rt_bgtz=5'b00000,
        rt_blez=5'b00000,
        rt_bltz=5'b00000;
    initial begin
        PCSrc=3'b000;
        nPCSel=0;
        PCWre=0;
        ALUSrcA=0;
        ALUSrcB=0;
        RegWre=0;
        WbRegSrc=2'b00;
        WbSelReg=2'b00;
        InsMemRW=0;
        DataMemRW=2'b00;
        ExtSel=2'b00;
        ALUOp=3'b000;
        state=3'b000;
    end
    always@(negedge clk or posedge rst)
    begin
        if(rst) begin
            state<=3'b000;//取指
            PCWre=0;    //PC不变
            RegWre=0;   //RF不写
        end
        else begin
            case(state)
                3'b000: begin//取指IF
                    state<=3'b001;//默认下一状态为译码
                    PCWre=0;    //PC不变
                    RegWre=0;   //寄存器不变
                    DataMemRW=2'b00;//DM读字
                end
                3'b001: begin//译码ID
                    if ((op==op_r&&fun==funct_jr)||op==op_j||op==op_jal||op==op_halt) begin
                        state=3'b000;
                        if (op==op_halt) begin
                            PCWre=0;//PC不变
                        end
                        else begin
                            PCWre=1;//PC可变
                        end
                        if (op==op_jal) begin
                            RegWre=1;//写
                        end
                        else begin
                            RegWre=0;
                        end
                    end
                    else begin
                        state=3'b010;
                    end
                end
                3'b010: begin//执行EXE
                    if(op==op_r||op==op_addi||op==op_addiu||op==op_andi||op==op_ori||op==op_xori)begin
                        state=3'b100;//WB
                        RegWre=1;
                    end
                    else if(op==op_beq||op==op_bgez||op==op_bgtz||op==op_blez||op==op_bltz||op==op_bne) begin
                        state=3'b000;//IF
                        PCWre=1;
                    end
                    else begin
                        state=3'b011;//MEM
                        if (op==op_sw) begin
                            DataMemRW=2'b01;
                        end
                        else if(op==op_sb) begin
                            DataMemRW=2'b11;
                        end
                        else if(op==op_lb) begin
                            DataMemRW=2'b10;
                        end
                    end
                end
                3'b011: begin//访存MEM
                    if (op==op_lw||op==op_lb) begin
                        state=3'b100;
                        RegWre=1;
                    end
                    else begin//sw,sb
                        state=3'b000;
                        PCWre=1;
                    end
                end
                //3'b100: begin//写回WB
                default:begin
                    state=3'b000;
                    PCWre=1;
                    RegWre=0;
                end
            endcase
        end
    end
    
    always@(*)begin
        //InsMemRW=0;//读

        if ((op==op_r&&fun==funct_sll)||(op==op_r&&fun==funct_srl)||(op==op_r&&fun==funct_sra)) begin
            ALUSrcA=1;//sll,srl,sra的sa
        end
        else begin
            ALUSrcA=0;//rs
        end

        if (op==op_addi||op==op_addiu||op==op_andi||op==op_ori||op==op_xori||op==op_lw||op==op_lb||op==op_sw||op==op_sb) begin
            ALUSrcB=1; //被扩展的立即数
        end
        else begin
            ALUSrcB=0;//rt
        end

        //扩展模块代码
        if ((op==op_r&&fun==funct_sll)||(op==op_r&&fun==funct_srl)||(op==op_r&&fun==funct_sra)) begin
            ExtSel=2'b00;//sa扩展
        end
        else if(op==op_addiu) begin
            ExtSel=2'b01;//0扩展
        end
        else begin
            ExtSel=2'b10;//addi,andi,ori,xori
        end

        //ALU操作代码
        if ((op==op_r&&fun==funct_addu)||op==op_addiu||op==op_lw||op==op_sw||op==op_lb||op==op_sb) begin
            ALUOp=4'b0000;
        end
        else if((op==op_r&&fun==funct_add)||op==op_addi) begin
            ALUOp=4'b0001;
        end
        else if ((op==op_r&&fun==funct_subu)) begin
            ALUOp=4'b0010;
        end
        else if((op==op_r&&fun==funct_sub)) begin
            ALUOp=4'b0011;
        end
        else if((op==op_r&&fun==funct_and)||op==op_andi) begin
            ALUOp=4'b0100;
        end
        else if((op==op_r&&fun==funct_or)||op==op_ori) begin
            ALUOp=4'b0101;
        end
        else if((op==op_r&&fun==funct_nor)) begin
            ALUOp=4'b0110;
        end
        else if((op==op_r&&fun==funct_xor)||op==op_xori) begin
            ALUOp=4'b0111;
        end
        else if((op==op_r&&fun==funct_sll)||(op==op_r&&fun==funct_sllv)) begin
            ALUOp=4'b1001;
        end
        else if((op==op_r&&fun==funct_srl)||(op==op_r&&fun==funct_srlv)) begin
            ALUOp=4'b1010;
        end
        else if((op==op_r&&fun==funct_sra)||(op==op_r&&fun==funct_srav)) begin
            ALUOp=4'b1011;
        end
        else if((op==op_r&&fun==funct_slt)) begin
            ALUOp=4'b1100;
        end
        else if((op==op_r&&fun==funct_sltu)) begin
            ALUOp=4'b1101;
        end
        else begin
            ALUOp=4'b1111;
        end

        //PC选择
        if (op==op_beq) begin
            PCSrc=3'b000;
            nPCSel=1;
        end
        else if (op==op_bne) begin
            PCSrc=3'b001;
            nPCSel=1;
        end
        else if (op==op_bgez&&rt==rt_bgez) begin
            PCSrc=3'b010;
            nPCSel=1;
        end
        else if (op==op_bgtz&&rt==rt_bgtz) begin
            PCSrc=3'b011;
            nPCSel=1;
        end
        else if (op==op_blez&&rt==rt_blez) begin
            PCSrc=3'b100;
            nPCSel=1;
        end
        else if (op==op_bltz&&rt==rt_bltz) begin
            PCSrc=3'b101;
            nPCSel=1;
        end
        else if (op==op_r&&fun==funct_jr) begin
            PCSrc=3'b110;
            nPCSel=1;
        end
        else if (op==op_j||op==op_jal) begin
            PCSrc=3'b111;
            nPCSel=1;
        end
        else begin
            nPCSel=0;
        end

        //选择哪个写入寄存器
        if (op==op_lw||op==op_lb) begin
            WbRegSrc=2'b00;
        end
        else if (op==op_jal) begin
            WbRegSrc=2'b10;
        end
        else begin
            WbRegSrc=2'b11;//alu
        end

        //写回哪个寄存器,11,$0
        if (op==op_r&&fun!=funct_jr) begin
            WbSelReg=2'b00;//rd
        end
        else if(op==op_addi||op==op_addiu||op==op_andi||op==op_ori||op==op_xori||op==op_lw||op==op_lb) begin
            WbSelReg=2'b01;//rt
        end
        else begin
            WbSelReg=2'b10;//$31
        end

    end
endmodule