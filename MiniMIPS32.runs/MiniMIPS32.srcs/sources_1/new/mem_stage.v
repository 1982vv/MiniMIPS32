`include "defines.v"

module mem_stage (
    input  wire                         cpu_rst_n,

    // ��ִ�н׶λ�õ���Ϣ
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire                         mem_wreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
    input  wire                         mem_mreg_i,
    input  wire [`REG_BUS      ]        mem_din_i,
    input  wire                         mem_whilo_i,
    input  wire [`DOUBLE_REG_BUS      ] mem_hilo_i,
    
    // ����д�ؽ׶ε���Ϣ
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire                         mem_wreg_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
    output wire                         mem_mreg_o,
    output wire [`BSEL_BUS      ]       dre,
    output wire                         mem_whilo_o,
    output wire [`DOUBLE_REG_BUS      ] mem_hilo_o,
    
    //�������ݴ洢�����ź�
    output wire                         dce,
    output wire [`INST_ADDR_BUS     ]   daddr,
    output wire [`BSEL_BUS          ]   we,
    output wire [`REG_BUS           ]   din
    );

    // �����ǰ���Ƿô�ָ���ֻ��Ҫ�Ѵ�ִ�н׶λ�õ���Ϣֱ�����
    assign mem_wa_o     = (cpu_rst_n == `RST_ENABLE) ? 5'b0  : mem_wa_i;
    assign mem_wreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_wreg_i;
    assign mem_dreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_wd_i;
    assign mem_whilo_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_whilo_i;
    assign mem_hilo_o   = (cpu_rst_n == `RST_ENABLE) ? 64'b0 : mem_hilo_i;
    assign mem_mreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_mreg_i;
    
    //ȷ����ǰ�ķô�ָ��
    wire inst_lb = (mem_aluop_i == 8'h90);
    wire inst_lw = (mem_aluop_i == 8'h92);
    wire inst_sb = (mem_aluop_i == 8'h98);
    wire inst_sw = (mem_aluop_i == 8'h9A);
    //11.10
    wire inst_lbu =(mem_aluop_i == 8'h52);
    wire inst_lh =(mem_aluop_i == 8'h53);
    wire inst_lhu =(mem_aluop_i == 8'h54);
    wire inst_sh =(mem_aluop_i == 8'h55);
    
    //������ݴ洢���ķ��ʵ�ַ
    assign daddr = (cpu_rst_n == `RST_ENABLE)?`ZERO_WORD:mem_wd_i;
    
    //������ݴ洢�����ֽ�ʹ���ź�
    assign dre[3] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_lb & (daddr[1:0] == 2'b00)) | inst_lw | (inst_lbu & (daddr[1:0] == 2'b00)) |
                    (inst_lh & (daddr[1:0]==2'b00)) | (inst_lhu & (daddr[1:0]==2'b00)) );
    assign dre[2] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_lb & (daddr[1:0] == 2'b01)) | inst_lw | (inst_lbu & (daddr[1:0] == 2'b01)) |
                    (inst_lh & (daddr[1:0]==2'b00)) | (inst_lhu & (daddr[1:0]==2'b00)));
    assign dre[1] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_lb & (daddr[1:0] == 2'b10)) | inst_lw | (inst_lbu & (daddr[1:0] == 2'b10)) |
                    (inst_lh & (daddr[1:0]==2'b10)) | (inst_lhu & (daddr[1:0]==2'b10)));
    assign dre[0] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_lb & (daddr[1:0] == 2'b11)) | inst_lw | (inst_lbu & (daddr[1:0] == 2'b11)) |
                    (inst_lh & (daddr[1:0]==2'b10)) | (inst_lhu & (daddr[1:0]==2'b10))); 
        
    //������ݴ洢��ʹ���ź�
    assign dce = (cpu_rst_n == `RST_ENABLE)?1'b0:
                 (inst_lb | inst_lw | inst_sb | inst_sw | inst_lbu | inst_lh | inst_lhu | inst_sh);
    
    //������ݴ洢�����ֽ�ʹ���ź�
    assign we[3] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b00)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b00)));
    assign we[2] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b01)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b00)));
    assign we[1] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b10)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b10)));
    assign we[0] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b11)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b10)));
    
    //ȷ����д�����ݴ洢��������
    wire [`WORD_BUS] din_reverse = {mem_din_i[7:0],mem_din_i[15:8],mem_din_i[23:16],mem_din_i[31:24]};
    wire [`WORD_BUS] din_byte = {mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0]};
    assign din = (cpu_rst_n == `RST_ENABLE)?`ZERO_WORD:
                 (we == 4'b1111)?din_reverse:
                 (we == 4'b1000)?din_byte:
                 (we == 4'b0100)?din_byte:
                 (we == 4'b0010)?din_byte:
                 (we == 4'b0001)?din_byte:`ZERO_WORD;
endmodule