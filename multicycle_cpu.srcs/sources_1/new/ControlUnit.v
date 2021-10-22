`timescale 1ns / 1ps

module ControlUnit(
    input clk,              //ʱ��
    input rst,              //����
    input [5:0] op,         //ָ�����
    input [4:0] rt,
    input [5:0] fun,
    output reg[2:0] PCSrc,  //PCָ����Դ
    output reg nPCSel,      //0ѡ��PC+4��1ѡ����ת���֧�ĵ�ַ
    output reg PCWre,       //PC�Ƿ���ģ����Ϊ0��PC�����ģ�IF״̬�ɸ�
    output reg ALUSrcA,     //
    output reg ALUSrcB,     //
    output reg RegWre,      //�Ĵ���дʹ���źţ�Ϊ1ʱ����ʱ������д��
    output reg[1:0] WbRegSrc,    //д��Ĵ�����������Դ��00lw,lb,10jal,11alu
    output reg[1:0] WbSelReg, //ѡ��д�ص��ĸ��Ĵ���
    output reg InsMemRW,    //ָ��洢����д�����źţ�1д��0��
    output reg[1:0] DataMemRW,   //���ݴ洢�����ݴ洢����д�����źţ�1д��0��
    output reg[1:0] ExtSel, //���Ϊ1x�����з�����չ��01��immediateȫ��0��00��sa(dhhh hh00 0000)ȫ��0
    output reg[3:0] ALUOp    //ALU�������Ʋ�����
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
            state<=3'b000;//ȡָ
            PCWre=0;    //PC����
            RegWre=0;   //RF��д
        end
        else begin
            case(state)
                3'b000: begin//ȡָIF
                    state<=3'b001;//Ĭ����һ״̬Ϊ����
                    PCWre=0;    //PC����
                    RegWre=0;   //�Ĵ�������
                    DataMemRW=2'b00;//DM����
                end
                3'b001: begin//����ID
                    if ((op==op_r&&fun==funct_jr)||op==op_j||op==op_jal||op==op_halt) begin
                        state=3'b000;
                        if (op==op_halt) begin
                            PCWre=0;//PC����
                        end
                        else begin
                            PCWre=1;//PC�ɱ�
                        end
                        if (op==op_jal) begin
                            RegWre=1;//д
                        end
                        else begin
                            RegWre=0;
                        end
                    end
                    else begin
                        state=3'b010;
                    end
                end
                3'b010: begin//ִ��EXE
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
                3'b011: begin//�ô�MEM
                    if (op==op_lw||op==op_lb) begin
                        state=3'b100;
                        RegWre=1;
                    end
                    else begin//sw,sb
                        state=3'b000;
                        PCWre=1;
                    end
                end
                //3'b100: begin//д��WB
                default:begin
                    state=3'b000;
                    PCWre=1;
                    RegWre=0;
                end
            endcase
        end
    end
    
    always@(*)begin
        //InsMemRW=0;//��

        if ((op==op_r&&fun==funct_sll)||(op==op_r&&fun==funct_srl)||(op==op_r&&fun==funct_sra)) begin
            ALUSrcA=1;//sll,srl,sra��sa
        end
        else begin
            ALUSrcA=0;//rs
        end

        if (op==op_addi||op==op_addiu||op==op_andi||op==op_ori||op==op_xori||op==op_lw||op==op_lb||op==op_sw||op==op_sb) begin
            ALUSrcB=1; //����չ��������
        end
        else begin
            ALUSrcB=0;//rt
        end

        //��չģ�����
        if ((op==op_r&&fun==funct_sll)||(op==op_r&&fun==funct_srl)||(op==op_r&&fun==funct_sra)) begin
            ExtSel=2'b00;//sa��չ
        end
        else if(op==op_addiu) begin
            ExtSel=2'b01;//0��չ
        end
        else begin
            ExtSel=2'b10;//addi,andi,ori,xori
        end

        //ALU��������
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

        //PCѡ��
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

        //ѡ���ĸ�д��Ĵ���
        if (op==op_lw||op==op_lb) begin
            WbRegSrc=2'b00;
        end
        else if (op==op_jal) begin
            WbRegSrc=2'b10;
        end
        else begin
            WbRegSrc=2'b11;//alu
        end

        //д���ĸ��Ĵ���,11,$0
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