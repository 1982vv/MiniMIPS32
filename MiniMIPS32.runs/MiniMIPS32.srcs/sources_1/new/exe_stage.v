`include "defines.v"

module exe_stage (
    input  wire 					cpu_rst_n,

    // ������׶λ�õ���Ϣ
    input  wire [`ALUTYPE_BUS	] 	exe_alutype_i,
    input  wire [`ALUOP_BUS	    ] 	exe_aluop_i,
    input  wire [`REG_BUS 		] 	exe_src1_i,
    input  wire [`REG_BUS 		] 	exe_src2_i,
    input  wire [`REG_ADDR_BUS 	] 	exe_wa_i,
    input  wire 					exe_wreg_i,
    input  wire                    exe_mreg_i,
    input  wire [`REG_BUS      ]   exe_din_i,
    input  wire                    exe_whilo_i,
    
    //��HLO�Ĵ�����õ�����
    input wire  [`REG_BUS      ]    hi_i,
    input wire  [`REG_BUS      ]    lo_i,
    
    // ����ִ�н׶ε���Ϣ
    output wire [`ALUOP_BUS	    ] 	exe_aluop_o,
    output wire [`REG_ADDR_BUS 	] 	exe_wa_o,
    output wire 					exe_wreg_o,
    output wire [`REG_BUS 		] 	exe_wd_o,
    output wire                     exe_mreg_o,
    output wire [`REG_BUS      ]    exe_din_o,
    output wire                     exe_whilo_o,
    output wire [`DOUBLE_REG_BUS]   exe_hilo_o
    );

    // ֱ�Ӵ�����һ�׶�
    assign exe_aluop_o = (cpu_rst_n == `RST_ENABLE) ? 8'b0 : exe_aluop_i;
    assign exe_mreg_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0: exe_mreg_i;
    assign exe_din_o   = (cpu_rst_n == `RST_ENABLE) ? 32'b0: exe_din_i;
    assign exe_whilo_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0: exe_whilo_i;
    
    wire [`REG_BUS       ]      logicres;       // �����߼�����Ľ��
    wire [`REG_BUS       ]      shiftres;       // ������λ������
    wire [`REG_BUS       ]      moveres;        // �����ƶ������Ľ��
    wire [`REG_BUS       ]      hi_t;           // ����H�Ĵ���������ֵ
    wire [`REG_BUS       ]      lo_t;           // ����LO�Ĵ���������ֵ
    wire [`REG_BUS       ]      arithres;       // �������������Ľ��
    wire [`REG_BUS       ]      memres;         // ����ô������ַ
    wire [`DOUBLE_REG_BUS]      mulres;         // ������ų˷������Ľ��
    
    // �����ڲ�������aluop�����߼�����
    assign logicres=(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:
    //11.8
    (exe_aluop_i == `MINIMIPS32_OR)? (exe_src1_i | exe_src2_i):
    (exe_aluop_i == `MINIMIPS32_NOR)? ~(exe_src1_i | exe_src2_i):
    (exe_aluop_i == `MINIMIPS32_XOR)? (exe_src1_i ^ exe_src2_i):
    (exe_aluop_i == `MINIMIPS32_ANDI)? (exe_src1_i & exe_src2_i):
    (exe_aluop_i == `MINIMIPS32_XORI)? (exe_src1_i & exe_src2_i):
    //11.6
    (exe_aluop_i == `MINIMIPS32_AND)? (exe_src1_i & exe_src2_i):
    (exe_aluop_i == `MINIMIPS32_ORI)? (exe_src1_i | exe_src2_i):
    (exe_aluop_i == `MINIMIPS32_LUI)? exe_src2_i : `ZERO_WORD;

    //�����ڲ�������aluop������λ����
    assign shiftres=(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:
    //11.8
    (exe_aluop_i == `MINIMIPS32_SRL)? (exe_src2_i >> exe_src1_i) :
    (exe_aluop_i == `MINIMIPS32_SRA)? (exe_src2_i >> exe_src1_i) :
    (exe_aluop_i == `MINIMIPS32_SLLV)? (exe_src2_i << exe_src1_i[4:0]) :
    (exe_aluop_i == `MINIMIPS32_SRLV)? (exe_src2_i >> exe_src1_i[4:0]) :
    (exe_aluop_i == `MINIMIPS32_SRAV)? (exe_src2_i >> exe_src1_i[4:0]) :
    //11.6
    (exe_aluop_i == `MINIMIPS32_SLL)? (exe_src2_i << exe_src1_i) : `ZERO_WORD;
    
    //�����ڲ�������aluop���������ƶ�,�õ����µ�HI��LO�Ĵ�����ֵ
     assign hi_t =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:hi_i;
     assign lo_t =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:lo_i;
     assign moveres =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:
     //11.8
     
     //11.6
     (exe_aluop_i== `MINIMIPS32_MFHI)? hi_t:
     (exe_aluop_i== `MINIMIPS32_MFLO)? lo_t: `ZERO_WORD;
     
     //�����ڲ������� aluop������������
     assign arithres =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:
     //11.8 
      (exe_aluop_i == `MINIMIPS32_ADDU) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_SUB) ?(exe_src1_i+(~exe_src2_i)+1):
      (exe_aluop_i == `MINIMIPS32_SLTU) ?(($unsigned(exe_src1_i) < $unsigned(exe_src2_i))?32'b1: 32'b0):
      (exe_aluop_i == `MINIMIPS32_ADDI) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_SLTI) ?(($signed(exe_src1_i) < $signed(exe_src2_i))?32'b1: 32'b0):
      (exe_aluop_i == `MINIMIPS32_LBU ) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_LH ) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_LHU ) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_SH ) ?(exe_src1_i+ exe_src2_i):
      //11.6
      (exe_aluop_i == `MINIMIPS32_ADD) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_LB ) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_LW ) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_SB ) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_SW ) ?(exe_src1_i+ exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_ADDIU )?(exe_src1_i+exe_src2_i):
      (exe_aluop_i == `MINIMIPS32_SUBU)? (exe_src1_i+(~exe_src2_i)+1):
      (exe_aluop_i == `MINIMIPS32_SLT) ?(($signed(exe_src1_i) < $signed(exe_src2_i))?32'b1: 32'b0):
      (exe_aluop_i == `MINIMIPS32_SLTIU)? ((exe_src1_i < exe_src2_i)? 32'b1 : 32'b0): `ZERO_WORD;
      
      //�����ڲ� aluop��������г˷�����,������������һ�׶�
      assign mulres=($signed(exe_src1_i)* $signed(exe_src2_i));
      assign exe_hilo_o=(cpu_rst_n ==`RST_ENABLE)? `ZERO_DWORD:
      (exe_aluop_i == `MINIMIPS32_MTHI)? {exe_src1_i,32'b0}:
      (exe_aluop_i == `MINIMIPS32_MTLO)? {32'b0,exe_src1_i}:
       (exe_aluop_i == `MINIMIPS32_MULTU)? (exe_src1_i*exe_src2_i):
       (exe_aluop_i == `MINIMIPS32_MULT)? mulres: `ZERO_DWORD;
       
    assign exe_wa_o   = (cpu_rst_n   == `RST_ENABLE ) ? 5'b0 	 : exe_wa_i;
    assign exe_wreg_o = (cpu_rst_n   == `RST_ENABLE ) ? 1'b0 	 : exe_wreg_i;
    
    // ���ݲ�������alutypeȷ��ִ�н׶����յ����������ȿ����Ǵ�д��Ŀ�ļĴ��������ݣ�Ҳ�����Ƿ������ݴ洢���ĵ�ַ��
    assign exe_wd_o = (cpu_rst_n   == `RST_ENABLE ) ? `ZERO_WORD : 
                      (exe_alutype_i == `LOGIC    ) ? logicres  : 
                      (exe_alutype_i == `SHIFT    ) ? shiftres  :
                      (exe_alutype_i == `MOVE    ) ? moveres  :
                      (exe_alutype_i == `ARITH    ) ? arithres  :`ZERO_WORD;

endmodule