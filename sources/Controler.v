`timescale 1ns / 1ps
module Controler(              //�����������ݵ�ǰҪִ�е�ָ���������Ԫ������״̬
    input add_flag,            //ָ���Ƿ�ΪADD
    input addu_flag,           //ָ���Ƿ�ΪADDU
    input sub_flag,            //ָ���Ƿ�ΪSUB
    input subu_flag,           //ָ���Ƿ�ΪSUBU
    input and_flag,            //ָ���Ƿ�ΪAND
    input or_flag,             //ָ���Ƿ�ΪOR
    input xor_flag,            //ָ���Ƿ�ΪXOR
    input nor_flag,            //ָ���Ƿ�ΪNOR
    input slt_flag,            //ָ���Ƿ�ΪSLT
    input sltu_flag,           //ָ���Ƿ�ΪSLTU
    input sll_flag,            //ָ���Ƿ�ΪSLL
    input srl_flag,            //ָ���Ƿ�ΪSRL
    input sra_flag,            //ָ���Ƿ�ΪSRA
    input sllv_flag,           //ָ���Ƿ�ΪSLLV
    input srlv_flag,           //ָ���Ƿ�ΪSRLV
    input srav_flag,           //ָ���Ƿ�ΪSRAV
    input jr_flag,             //ָ���Ƿ�ΪJR
    input addi_flag,           //ָ���Ƿ�ΪADDI
    input addiu_flag,          //ָ���Ƿ�ΪADDIU
    input andi_flag,           //ָ���Ƿ�ΪANDI
    input ori_flag,            //ָ���Ƿ�ΪORI
    input xori_flag,           //ָ���Ƿ�ΪXORI
    input lw_flag,             //ָ���Ƿ�ΪLW
    input sw_flag,             //ָ���Ƿ�ΪSW
    input beq_flag,            //ָ���Ƿ�ΪBEQ
    input bne_flag,            //ָ���Ƿ�ΪBNE
    input slti_flag,           //ָ���Ƿ�ΪSLTI
    input sltiu_flag,          //ָ���Ƿ�ΪSLTIU
    input lui_flag,            //ָ���Ƿ�ΪLUI
    input j_flag,              //ָ���Ƿ�ΪJ
    input jal_flag,            //ָ���Ƿ�ΪJAL
    input zero,                //ALU��־λZF
    /* �����õ���Ԫ����ָ�����ﶼ���漰�� */
    output reg_w,              //RegFile�Ĵ������Ƿ��д��
    output [3:0] aluc,         //ALUC��ָ�����ALUCִ�к��ֲ���
    output dm_r,               //DMEM�Ƿ��д��
    output dm_w,               //�Ƿ��DMEM�ж�ȡ����
    output [4:0] ext_ena,      //EXT��չ�Ƿ�����5��״̬�ֱ��ӦEXT1��EXT5��EXT16��EXT16(S)��EXT18(S),����EXT[0]��ӦEXT1
    output cat_ena,            //�Ƿ���Ҫƴ��
    output [9:0] mux           //9����·ѡ������״̬��ѡ��0����ѡ��1��(0û�õ���Ϊ��ʹMUX��ź������±��Ӧ���Զ�һ��)
    );
/* �����Ǹ�ֵ��Ҳ���Ǹ���Ҫִ�еĲ���������Ԫ������״̬ */
assign reg_w = (!jr_flag && !sw_flag && !beq_flag && !bne_flag && !j_flag) ? 1'b1 : 1'b0;

assign aluc[3] = (slt_flag  || sltu_flag  || sllv_flag || srlv_flag ||
                  srav_flag || sll_flag   || srl_flag  || sra_flag  || 
                  slti_flag || sltiu_flag || lui_flag) ? 1'b1 : 1'b0;
assign aluc[2] = (and_flag  || or_flag    || xor_flag  || nor_flag  ||
                  sllv_flag || srlv_flag  || srav_flag || sll_flag  ||
                  srl_flag  || sra_flag   || andi_flag || ori_flag  ||
                  xori_flag) ? 1'b1 : 1'b0;
assign aluc[1] = (add_flag  || sub_flag   || xor_flag  || nor_flag  ||
                  slt_flag  || sltu_flag  || sllv_flag || sll_flag  ||
                  addi_flag || xori_flag  || slti_flag || sltiu_flag) ? 1'b1 : 1'b0;
assign aluc[0] = (sub_flag  || subu_flag  || or_flag   || nor_flag  ||
                  slt_flag  || sllv_flag  || srlv_flag || sll_flag  ||
                  srl_flag  || ori_flag   || slti_flag || lui_flag  ||
                  beq_flag  || bne_flag) ? 1'b1 : 1'b0;
//aluc[0]��SLLV��SLL��LUI�Ӳ��Ӿ���

assign dm_r = lw_flag ? 1'b1 : 1'b0;
assign dm_w = sw_flag ? 1'b1 : 1'b0;

assign ext_ena[4] = (beq_flag  || bne_flag) ? 1'b1 : 1'b0;                              //EXT18(S)
assign ext_ena[3] = (addi_flag || addiu_flag || lw_flag   || sw_flag ||
                     slti_flag || sltiu_flag) ? 1'b1 : 1'b0;                            //EXT16(S)
assign ext_ena[2] = (andi_flag || ori_flag   || xori_flag || lui_flag) ? 1'b1 : 1'b0;   //EXT16
assign ext_ena[1] = (sll_flag  || srl_flag   || sra_flag) ? 1'b1 : 1'b0;                //EXT5
assign ext_ena[0] = (slt_flag  || sltu_flag  || slti_flag || sltiu_flag) ? 1'b1 : 1'b0; //EXT1

assign cat_ena = (j_flag || jal_flag) ? 1'b1 : 1'b0;

assign mux[9] = (add_flag   || addu_flag  || sub_flag  || subu_flag  ||
                 and_flag   || or_flag    || xor_flag  || nor_flag   ||
                 sll_flag   || srl_flag   || sra_flag  || sllv_flag  ||
                 srlv_flag  || srav_flag  || lui_flag  || addi_flag  || 
                 addiu_flag || andi_flag  || ori_flag  || xori_flag) ? 1'b1 : 1'b0;
assign mux[8] = (addi_flag  || addiu_flag || lw_flag   || sw_flag    ||
                 slti_flag  || sltiu_flag) ? 1'b1 : 1'b0;
assign mux[7] = jal_flag ? 1'b1 : 1'b0;
assign mux[6] = beq_flag ? ~zero : (bne_flag ? zero : 1'b1);
assign mux[5] = (addi_flag  || addiu_flag || andi_flag || ori_flag  ||
                 xori_flag  || lw_flag    || sw_flag   || slti_flag ||
                 sltiu_flag || lui_flag) ? 1'b1 : 1'b0;
assign mux[4] = (!jr_flag && !j_flag && !jal_flag) ? 1'b1 : 1'b0;
assign mux[3] = (sll_flag   || srl_flag   || sra_flag) ? 1'b1 : 1'b0;
assign mux[2] = !lw_flag ? 1'b1 : 1'b0;
assign mux[1] = (j_flag || jal_flag) ? 1'b1 : 1'b0;

endmodule
