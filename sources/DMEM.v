`timescale 1ns / 1ps
module DMEM(                    //DMEM�������ܿ�������Ƴ��첽��ȡ���ݣ�ͬ��д�����ݵ���ʽ
    input dm_clk,               //DMEMʱ���źţ�ֻ��д����ʱʹ��
    input dm_ena,               //ʹ���źŶˣ��ߵ�ƽ��Ч����Чʱ���ܶ�ȡ/д������
    input dm_r,                 //read���źţ���ȡʱ����
    input dm_w,                 //writeд�źţ�д��ʱ����
    input [10:0] dm_addr,       //11λ��ַ��Ҫ��ȡ/д��ĵ�ַ
    input [31:0] dm_data_in,    //д��ʱҪд�������
    output [31:0] dm_data_out   //��ȡʱ��ȡ��������
    );

reg [31:0] dmem [31:0];//DMEM����

assign dm_data_out = (dm_ena && dm_r && !dm_w) ? dmem[dm_addr] : 32'bz;//������ʹ�ܶ˿�������ָ����Ч��дָ����Чʱ���Ž���Ӧ��ַ�������ͳ���������Ϊ���迹

always @(negedge dm_clk)//ʱ��������д������
begin
    if(dm_ena && dm_w &&!dm_r)//������ʹ�ܶ˿�����дָ����Ч�Ҷ�ָ����Чʱ������Ĵ�����д������
        dmem[dm_addr]<=dm_data_in;
end
//������߶�û����/ͬʱ���ߣ�������ʲô����������ֹ������д�ֶ��ĳ�ͻ���
endmodule
