`timescale 1ns / 1ps
module cpu(
    input clk,                  //CPUִ��ʱ��
    input ena,                  //ʹ���źŶ�
    input rst_n,                //��λ�ź�
    input [31:0] instr_in,      //��ǰҪִ�е�ָ��
    input [31:0] dm_data,       //��ȡ����DMEM�ľ�������
    output dm_ena,              //�Ƿ���Ҫ����DMEM
    output dm_w,                //�������DMEM���Ƿ�Ϊд��
    output dm_r,                //�������DMEM���Ƿ�Ϊ��ȡ
    output [31:0] pc_out,       //���ָ���ַ������IMEMҪȡ����
    output [31:0] dm_addr,      //����DMEM�ĵ�ַ
    output [31:0] dm_data_w     //Ҫд��DMEM������ 
    );
/* ����һЩ�ڲ����� */
/* Decoder�� */
wire add_flag,  addu_flag, sub_flag, subu_flag, and_flag, or_flag, xor_flag, nor_flag,
     slt_flag,  sltu_flag,
     sll_flag,  srl_flag,  sra_flag, sllv_flag,
     srlv_flag, srav_flag,
     jr_flag,
     addi_flag, addiu_flag,
     andi_flag, ori_flag,  xori_flag,
     lw_flag,   sw_flag,
     beq_flag,  bne_flag,
     slti_flag, sltiu_flag,
     lui_flag,
     j_flag,    jal_flag;       //����ָ��ı�־��Ϣ
wire [4:0] RsC;                 //Rs��Ӧ�ļĴ����ĵ�ַ
wire [4:0] RtC;                 //Rt��Ӧ�ļĴ����ĵ�ַ
wire [4:0] RdC;                 //Rd��Ӧ�ļĴ����ĵ�ַ
wire [4:0] shamt;               //λ��ƫ������SLL��SRL��SRA�ã�
wire [15:0] immediate;          //��������I��ָ���ã�
wire [25:0] address;            //��ת��ַ��J��ָ���ã�

/* Control�� */
wire reg_w;                     //RegFile�Ĵ������Ƿ��д��
wire [9:0] mux;                 //9����·ѡ������״̬
wire [4:0] ext_ena;             //EXT��չ�Ƿ�����5��״̬�ֱ��ӦEXT1��EXT5��EXT16��EXT16(S)��EXT18(S),����EXT[0]��ӦEXT1
wire cat_ena;                   //�Ƿ���Ҫƴ��

/* ALU�� */
wire [31:0] a, b;                              //ALU��A��B���������
wire [3:0]  aluc;                       //ALUC��λ����ָ��
wire [31:0] alu_data_out;               //ALU���������
wire zero, carry, negative, overflow;   //�ĸ���־λ

/* �Ĵ�����RegFile�� */
wire [31:0] Rd_data_in;     //Ҫ��Ĵ�����д���ֵ
wire [31:0] Rs_data_out;    //Rs��Ӧ�ļĴ��������ֵ
wire [31:0] Rt_data_out;    //Rt��Ӧ�ļĴ��������ֵ

/* PC�Ĵ����� */
wire [31:0] pc_addr_in;     //��������PC�Ĵ�����ָ���ַ��Ҳ������һ��Ҫִ�е�ָ��
wire [31:0] pc_addr_out;    //���δ�PC�Ĵ����д�����ָ���ַ��Ҳ���ǵ�ǰ��Ҫִ�е�ָ��

/* ���Ӹ�ģ�� */
/* ���š�������չ����· */
wire [31:0] ext1_out;
wire [31:0] ext5_out;
wire [31:0] ext16_out;
wire signed [31:0] ext16_out_signed;
wire signed [31:0] ext18_out_signed;

assign ext1_out         = (slt_flag  || sltu_flag) ? negative : (slti_flag || sltiu_flag) ? carry : 32'hz;
assign ext5_out         = (sll_flag  || srl_flag   || sra_flag) ? shamt : 32'hz;
assign ext16_out        = (andi_flag || ori_flag   || xori_flag || lui_flag) ? { 16'h0 , immediate[15:0] } : 32'hz;
assign ext16_out_signed = (addi_flag || addiu_flag || lw_flag || sw_flag || slti_flag || sltiu_flag) ?  { {16{immediate[15]}} , immediate[15:0] } : 32'hz;
assign ext18_out_signed = (beq_flag  || bne_flag) ? {{14{immediate[15]}}, immediate[15:0], 2'b0} : 32'hz;
//ע�⣺Verilog������ʽ�ؽ��޷�������Ϊ�з�������ֻ��������ʱ�Ż���в�����������ǲ���ͨ����ֵ�ķ�����ɴ��޷��������з���������չ�����뽫����λ���Ƶ���λ

/* ||ƴ������· */
wire [31:0] cat_out;

assign cat_out = cat_ena ? {pc_out[31:28], address[25:0], 2'h0} : 32'hz;

/* NPC��· */
wire [31:0] npc;
assign npc = pc_addr_out + 4;

/* ��·ѡ������· */
wire [31:0] mux1_out;
wire [31:0] mux2_out;
wire [31:0] mux3_out;
wire [31:0] mux4_out;
wire [31:0] mux5_out;
wire [31:0] mux6_out;
wire [31:0] mux7_out;
wire [31:0] mux8_out;
wire [31:0] mux9_out;

assign mux1_out = mux[1] ? cat_out          : mux4_out;
assign mux2_out = mux[2] ? mux9_out         : dm_data;
assign mux3_out = mux[3] ? ext5_out         : ((sllv_flag || srlv_flag || srav_flag) ? { 27'h0, Rs_data_out[4:0] } : Rs_data_out);//�ر�ע������ǼĴ�������λָ�Ҫ�Խ���a�����ݽ��д���ֻȡ�����λ
assign mux4_out = mux[4] ? mux6_out         : Rs_data_out;
assign mux5_out = mux[5] ? mux8_out         : Rt_data_out;
assign mux6_out = mux[6] ? npc              : ext18_out_signed + npc;
assign mux7_out = mux[7] ? pc_addr_out + 4  : mux2_out;
assign mux8_out = mux[8] ? ext16_out_signed : ext16_out;
assign mux9_out = mux[9] ? alu_data_out     : ext1_out;

/* PC��· */
assign pc_addr_in = mux1_out;

/* ALU ���߿� */
assign a = mux3_out;
assign b = mux5_out;

/* IMEM�ӿ� */
assign pc_out = pc_addr_out;

/* DMEM�ӿ� */
assign dm_ena  = (dm_r || dm_w) ? 1'b1 : 1'b0;
assign dm_addr = alu_data_out;
assign dm_data_w = Rt_data_out;

/* �Ĵ�������· */
assign Rd_data_in = mux7_out;

/* ʵ���������� */
Decoder Decoder_inst(
    .instr_in(instr_in),        //��Ҫ�����ָ�Ҳ���ǵ�ǰҪִ�е�ָ��
    .add_flag(add_flag),        //ָ���Ƿ�ΪADD
    .addu_flag(addu_flag),      //ָ���Ƿ�ΪADDU
    .sub_flag(sub_flag),        //ָ���Ƿ�ΪSUB
    .subu_flag(subu_flag),      //ָ���Ƿ�ΪSUBU
    .and_flag(and_flag),        //ָ���Ƿ�ΪAND
    .or_flag(or_flag),          //ָ���Ƿ�ΪOR
    .xor_flag(xor_flag),        //ָ���Ƿ�ΪXOR
    .nor_flag(nor_flag),        //ָ���Ƿ�ΪNOR
    .slt_flag(slt_flag),        //ָ���Ƿ�ΪSLT
    .sltu_flag(sltu_flag),      //ָ���Ƿ�ΪSLTU
    .sll_flag(sll_flag) ,       //ָ���Ƿ�ΪSLL
    .srl_flag(srl_flag),        //ָ���Ƿ�ΪSRL
    .sra_flag(sra_flag),        //ָ���Ƿ�ΪSRA
    .sllv_flag(sllv_flag),      //ָ���Ƿ�ΪSLLV
    .srlv_flag(srlv_flag),      //ָ���Ƿ�ΪSRLV
    .srav_flag(srav_flag),      //ָ���Ƿ�ΪSRAV
    .jr_flag(jr_flag),          //ָ���Ƿ�ΪJR
    .addi_flag(addi_flag),      //ָ���Ƿ�ΪADDI
    .addiu_flag(addiu_flag),    //ָ���Ƿ�ΪADDIU
    .andi_flag(andi_flag),      //ָ���Ƿ�ΪANDI
    .ori_flag(ori_flag),        //ָ���Ƿ�ΪORI
    .xori_flag(xori_flag),      //ָ���Ƿ�ΪXORI
    .lw_flag(lw_flag),          //ָ���Ƿ�ΪLW
    .sw_flag(sw_flag),          //ָ���Ƿ�ΪSW
    .beq_flag(beq_flag),        //ָ���Ƿ�ΪBEQ
    .bne_flag(bne_flag),        //ָ���Ƿ�ΪBNE
    .slti_flag(slti_flag),      //ָ���Ƿ�ΪSLTI
    .sltiu_flag(sltiu_flag),    //ָ���Ƿ�ΪSLTIU
    .lui_flag(lui_flag),        //ָ���Ƿ�ΪLUI
    .j_flag(j_flag),            //ָ���Ƿ�ΪJ
    .jal_flag(jal_flag),        //ָ���Ƿ�ΪJAL
    .RsC(RsC),                  //Rs��Ӧ�ļĴ����ĵ�ַ
    .RtC(RtC),                  //Rt��Ӧ�ļĴ����ĵ�ַ
    .RdC(RdC),                  //Rd��Ӧ�ļĴ����ĵ�ַ
    .shamt(shamt),              //λ��ƫ������SLL��SRL��SRA�ã�
    .immediate(immediate),      //��������I��ָ���ã�
    .address(address)           //��ת��ַ��J��ָ���ã�
    );

/* ʵ���������� */
Controler Controler_inst(              
    .add_flag(add_flag),        //ָ���Ƿ�ΪADD
    .addu_flag(addu_flag),      //ָ���Ƿ�ΪADDU
    .sub_flag(sub_flag),        //ָ���Ƿ�ΪSUB
    .subu_flag(subu_flag),      //ָ���Ƿ�ΪSUBU
    .and_flag(and_flag),        //ָ���Ƿ�ΪAND
    .or_flag(or_flag),          //ָ���Ƿ�ΪOR
    .xor_flag(xor_flag),        //ָ���Ƿ�ΪXOR
    .nor_flag(nor_flag),        //ָ���Ƿ�ΪNOR
    .slt_flag(slt_flag),        //ָ���Ƿ�ΪSLT
    .sltu_flag(sltu_flag),      //ָ���Ƿ�ΪSLTU
    .sll_flag(sll_flag) ,       //ָ���Ƿ�ΪSLL
    .srl_flag(srl_flag),        //ָ���Ƿ�ΪSRL
    .sra_flag(sra_flag),        //ָ���Ƿ�ΪSRA
    .sllv_flag(sllv_flag),      //ָ���Ƿ�ΪSLLV
    .srlv_flag(srlv_flag),      //ָ���Ƿ�ΪSRLV
    .srav_flag(srav_flag),      //ָ���Ƿ�ΪSRAV
    .jr_flag(jr_flag),          //ָ���Ƿ�ΪJR
    .addi_flag(addi_flag),      //ָ���Ƿ�ΪADDI
    .addiu_flag(addiu_flag),    //ָ���Ƿ�ΪADDIU
    .andi_flag(andi_flag),      //ָ���Ƿ�ΪANDI
    .ori_flag(ori_flag),        //ָ���Ƿ�ΪORI
    .xori_flag(xori_flag),      //ָ���Ƿ�ΪXORI
    .lw_flag(lw_flag),          //ָ���Ƿ�ΪLW
    .sw_flag(sw_flag),          //ָ���Ƿ�ΪSW
    .beq_flag(beq_flag),        //ָ���Ƿ�ΪBEQ
    .bne_flag(bne_flag),        //ָ���Ƿ�ΪBNE
    .slti_flag(slti_flag),      //ָ���Ƿ�ΪSLTI
    .sltiu_flag(sltiu_flag),    //ָ���Ƿ�ΪSLTIU
    .lui_flag(lui_flag),        //ָ���Ƿ�ΪLUI
    .j_flag(j_flag),            //ָ���Ƿ�ΪJ
    .jal_flag(jal_flag),        //ָ���Ƿ�ΪJAL
    .zero(zero),                //ALU��־λZF
    .reg_w(reg_w),              //RegFile�Ĵ������Ƿ��д��
    .aluc(aluc),                //ALUC��ָ�����ALUCִ�к��ֲ���
    .dm_r(dm_r),                //DMEM�Ƿ��д��
    .dm_w(dm_w),                //�Ƿ��DMEM�ж�ȡ����
    .ext_ena(ext_ena),          //EXT��չ�Ƿ�����5��״̬�ֱ��ӦEXT1��EXT5��EXT16��EXT16(S)��EXT18(S),����EXT[0]��ӦEXT1
    .cat_ena(cat_ena),          //�Ƿ���Ҫƴ��
    .mux(mux)                   //9����·ѡ������״̬��ѡ��0����ѡ��1��(0û�õ���Ϊ��ʹMUX��ź������±��Ӧ���Զ�һ��)
    );

/* ʵ����ALU */
ALU ALU_inst(                      
    .A(a),                      //��ӦA�ӿ�
    .B(b),                      //��ӦB�ӿ�
    .ALUC(aluc),                //ALUC��λ����ָ��
    .alu_data_out(alu_data_out),//�������
    .zero(zero),                //ZF��־λ��BEQ/BNEʹ��
    .carry(carry),              //CF��־λ��SLTI/SLTIUʹ��
    .negative(negative),        //NF(SF)��־λ��SLT/SLTUʹ��
    .overflow(overflow)         //OF��־λ����ʵû���õ�
    );

/* ʵ�����Ĵ����� */
regfile cpu_ref(                //�Ĵ�����RegFile��д��Ϊͬ������ȡΪ�첽
    .reg_clk(clk),              //ʱ���źţ��½�����Ч
    .reg_ena(ena),              //ʹ���źŶˣ���������Ч
    .rst_n(rst_n),              //��λ�źţ��ߵ�ƽ��Ч����������أ�
    .reg_w(reg_w),              //д�źţ��ߵ�ƽʱ�Ĵ�����д�룬�͵�ƽ����д��
    .RdC(RdC),                  //Rd��Ӧ�ļĴ����ĵ�ַ��д��ˣ�
    .RtC(RtC),                  //Rt��Ӧ�ļĴ����ĵ�ַ������ˣ�
    .RsC(RsC),                  //Rs��Ӧ�ļĴ����ĵ�ַ������ˣ�
    .Rd_data_in(Rd_data_in),    //Ҫ��Ĵ�����д���ֵ��������reg_w��
    .Rs_data_out(Rs_data_out),  //Rs��Ӧ�ļĴ��������ֵ
    .Rt_data_out(Rt_data_out)   //Rt��Ӧ�ļĴ��������ֵ
    );

/* ʵ����PC�Ĵ��� */
PC PC_inst(                     //ָ���ַ�Ĵ���
    .pc_clk(clk),               //PC�Ĵ�����ʱ���źţ�д��Ϊͬ����ʱ���½�����Ч������ȡΪ�첽
    .pc_ena(ena),               //ʹ�ܶ��źţ��ߵ�ƽ��Ч
    .rst_n(rst_n),              //��λ�źţ��ߵ�ƽ��Ч
    .pc_addr_in(pc_addr_in),    //��������PC�Ĵ�����ָ���ַ��Ҳ������һ��Ҫִ�е�ָ��
    .pc_addr_out(pc_addr_out)   //���δ�PC�Ĵ����д�����ָ���ַ��Ҳ���ǵ�ǰ��Ҫִ�е�ָ��
    );

endmodule
