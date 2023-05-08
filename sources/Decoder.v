`timescale 1ns / 1ps
module Decoder(                 //���нӿ������ǰ�������ָ���Ҫ����Ϊ���迹
    input  [31:0] instr_in,     //��Ҫ�����ָ�Ҳ���ǵ�ǰҪִ�е�ָ��
    output add_flag,            //ָ���Ƿ�ΪADD
    output addu_flag,           //ָ���Ƿ�ΪADDU
    output sub_flag,            //ָ���Ƿ�ΪSUB
    output subu_flag,           //ָ���Ƿ�ΪSUBU
    output and_flag,            //ָ���Ƿ�ΪAND
    output or_flag,             //ָ���Ƿ�ΪOR
    output xor_flag,            //ָ���Ƿ�ΪXOR
    output nor_flag,            //ָ���Ƿ�ΪNOR
    output slt_flag,            //ָ���Ƿ�ΪSLT
    output sltu_flag,           //ָ���Ƿ�ΪSLTU
    output sll_flag,            //ָ���Ƿ�ΪSLL
    output srl_flag,            //ָ���Ƿ�ΪSRL
    output sra_flag,            //ָ���Ƿ�ΪSRA
    output sllv_flag,           //ָ���Ƿ�ΪSLLV
    output srlv_flag,           //ָ���Ƿ�ΪSRLV
    output srav_flag,           //ָ���Ƿ�ΪSRAV
    output jr_flag,             //ָ���Ƿ�ΪJR
    output addi_flag,           //ָ���Ƿ�ΪADDI
    output addiu_flag,          //ָ���Ƿ�ΪADDIU
    output andi_flag,           //ָ���Ƿ�ΪANDI
    output ori_flag,            //ָ���Ƿ�ΪORI
    output xori_flag,           //ָ���Ƿ�ΪXORI
    output lw_flag,             //ָ���Ƿ�ΪLW
    output sw_flag,             //ָ���Ƿ�ΪSW
    output beq_flag,            //ָ���Ƿ�ΪBEQ
    output bne_flag,            //ָ���Ƿ�ΪBNE
    output slti_flag,           //ָ���Ƿ�ΪSLTI
    output sltiu_flag,          //ָ���Ƿ�ΪSLTIU
    output lui_flag,            //ָ���Ƿ�ΪLUI
    output j_flag,              //ָ���Ƿ�ΪJ
    output jal_flag,            //ָ���Ƿ�ΪJAL
    output [4:0]  RsC,          //Rs��Ӧ�ļĴ����ĵ�ַ
    output [4:0]  RtC,          //Rt��Ӧ�ļĴ����ĵ�ַ
    output [4:0]  RdC,          //Rd��Ӧ�ļĴ����ĵ�ַ
    output [4:0]  shamt,        //λ��ƫ������SLL��SRL��SRA�ã�
    output [15:0] immediate,    //��������I��ָ���ã�
    output [25:0] address       //��ת��ַ��J��ָ���ã�
    );
/* �����ָ����ԭָ���ж�Ӧ�ı��� */
/* ������Щָ�������չ��OP��ȫΪ0����Ҫ�����6λFUNC�������� */
parameter ADD_OPE   = 6'b100000;
parameter ADDU_OPE  = 6'b100001;
parameter SUB_OPE   = 6'b100010;
parameter SUBU_OPE  = 6'b100011;
parameter AND_OPE   = 6'b100100;
parameter OR_OPE    = 6'b100101;
parameter XOR_OPE   = 6'b100110;
parameter NOR_OPE   = 6'b100111;
parameter SLT_OPE   = 6'b101010;
parameter SLTU_OPE  = 6'b101011;

parameter SLL_OPE   = 6'b000000;
parameter SRL_OPE   = 6'b000010;
parameter SRA_OPE   = 6'b000011;

parameter SLLV_OPE  = 6'b000100;
parameter SRLV_OPE  = 6'b000110;
parameter SRAV_OPE  = 6'b000111;

parameter JR_OPE    = 6'b001000;
/* ������Щָ��ͨ��OP��ֱ�Ӽ������� */
parameter ADDI_OPE  = 6'b001000;
parameter ADDIU_OPE = 6'b001001;
parameter ANDI_OPE  = 6'b001100;
parameter ORI_OPE   = 6'b001101;
parameter XORI_OPE  = 6'b001110;
parameter LW_OPE    = 6'b100011;
parameter SW_OPE    = 6'b101011;
parameter BEQ_OPE   = 6'b000100;
parameter BNE_OPE   = 6'b000101;
parameter SLTI_OPE  = 6'b001010;
parameter SLTIU_OPE = 6'b001011;

parameter LUI_OPE   = 6'b001111;

parameter J_OPE     = 6'b000010;
parameter JAL_OPE   = 6'b000011;

/* �����Ǹ�ֵ */
/* ��ָ��������룬�ж����ĸ�ָ�� */
assign add_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == ADD_OPE )) ? 1'b1 : 1'b0;
assign addu_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == ADDU_OPE)) ? 1'b1 : 1'b0;
assign sub_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SUB_OPE )) ? 1'b1 : 1'b0;
assign subu_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SUBU_OPE)) ? 1'b1 : 1'b0;
assign and_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == AND_OPE )) ? 1'b1 : 1'b0;
assign or_flag   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == OR_OPE  )) ? 1'b1 : 1'b0;
assign xor_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == XOR_OPE )) ? 1'b1 : 1'b0;
assign nor_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == NOR_OPE )) ? 1'b1 : 1'b0;
assign slt_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLT_OPE )) ? 1'b1 : 1'b0;
assign sltu_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLTU_OPE)) ? 1'b1 : 1'b0;

assign sll_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLL_OPE )) ? 1'b1 : 1'b0;
assign srl_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRL_OPE )) ? 1'b1 : 1'b0;
assign sra_flag  = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRA_OPE )) ? 1'b1 : 1'b0;

assign sllv_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SLLV_OPE)) ? 1'b1 : 1'b0;
assign srlv_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRLV_OPE)) ? 1'b1 : 1'b0;
assign srav_flag = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == SRAV_OPE)) ? 1'b1 : 1'b0;
assign jr_flag   = ((instr_in[31:26] == 6'h0) && (instr_in[5:0] == JR_OPE  )) ? 1'b1 : 1'b0;

assign addi_flag  = (instr_in[31:26] == ADDI_OPE ) ? 1'b1 : 1'b0;
assign addiu_flag = (instr_in[31:26] == ADDIU_OPE) ? 1'b1 : 1'b0;
assign andi_flag  = (instr_in[31:26] == ANDI_OPE ) ? 1'b1 : 1'b0;
assign ori_flag   = (instr_in[31:26] == ORI_OPE  ) ? 1'b1 : 1'b0;
assign xori_flag  = (instr_in[31:26] == XORI_OPE ) ? 1'b1 : 1'b0;
assign lw_flag    = (instr_in[31:26] == LW_OPE   ) ? 1'b1 : 1'b0;
assign sw_flag    = (instr_in[31:26] == SW_OPE   ) ? 1'b1 : 1'b0;
assign beq_flag   = (instr_in[31:26] == BEQ_OPE  ) ? 1'b1 : 1'b0;
assign bne_flag   = (instr_in[31:26] == BNE_OPE  ) ? 1'b1 : 1'b0;
assign slti_flag  = (instr_in[31:26] == SLTI_OPE ) ? 1'b1 : 1'b0;
assign sltiu_flag = (instr_in[31:26] == SLTIU_OPE) ? 1'b1 : 1'b0;

assign lui_flag   = (instr_in[31:26] == LUI_OPE  ) ? 1'b1 : 1'b0;

assign j_flag     = (instr_in[31:26] == J_OPE    ) ? 1'b1 : 1'b0;
assign jal_flag   = (instr_in[31:26] == JAL_OPE  ) ? 1'b1 : 1'b0;

/* ȡ��ָ���и����ֵ�ֵ */
assign RsC = (add_flag  || addu_flag || sub_flag  || subu_flag  ||
              and_flag  || or_flag   || xor_flag  || nor_flag   ||
              slt_flag  || sltu_flag || sllv_flag || srlv_flag  ||
              srav_flag || jr_flag   || addi_flag || addiu_flag ||
              andi_flag || ori_flag  || xori_flag || lw_flag    ||
              sw_flag   || beq_flag  || bne_flag  || slti_flag  ||
              sltiu_flag) ? instr_in[25:21] : 5'hz;

assign RtC = (add_flag  || addu_flag  || sub_flag   || subu_flag ||
              and_flag  || or_flag    || xor_flag   || nor_flag  ||
              slt_flag  || sltu_flag  || sll_flag   || srl_flag  ||
              sra_flag  || sllv_flag  || srlv_flag  || srav_flag ||
              sw_flag   || beq_flag   || bne_flag ) ? instr_in[20:16] : 5'hz;

assign RdC = (add_flag  || addu_flag  || sub_flag  || subu_flag  ||
              and_flag  || or_flag    || xor_flag  || nor_flag   ||
              slt_flag  || sltu_flag  || sll_flag  || srl_flag   ||
              sra_flag  || sllv_flag  || srlv_flag || srav_flag) ? instr_in[15:11] : ((
              addi_flag || addiu_flag || andi_flag || ori_flag   || 
              xori_flag || lw_flag    || slti_flag || sltiu_flag ||
              lui_flag) ? instr_in[20:16] : (jal_flag ? 5'd31 : 5'hz));

assign shamt = (sll_flag || srl_flag || sra_flag) ? instr_in[10:6] : 5'hz;        

assign immediate = (addi_flag || addiu_flag || andi_flag  || ori_flag || 
                    xori_flag || lw_flag    || sw_flag    || beq_flag || 
                    bne_flag  || slti_flag  || sltiu_flag || lui_flag) ? instr_in[15:0] : 16'hz;

assign address = (j_flag || jal_flag) ? instr_in[25:0] : 26'hz;     

endmodule
