`include "defines.v"

module mem_stage (
    input  wire                         cpu_rst_n,

    // 从执行阶段获得的信息
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire                         mem_wreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
    input  wire                         mem_mreg_i,
    input  wire [`REG_BUS      ]        mem_din_i,
    input  wire                         mem_whilo_i,
    input  wire [`DOUBLE_REG_BUS      ] mem_hilo_i,
    
    // 送至写回阶段的信息
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire                         mem_wreg_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
    output wire                         mem_mreg_o,
    output wire [`BSEL_BUS      ]       dre,
    output wire                         mem_whilo_o,
    output wire [`DOUBLE_REG_BUS      ] mem_hilo_o,
    output wire                         unsign,
    
    //送至数据存储器的信号
    output wire                         dce,
    output wire [`INST_ADDR_BUS     ]   daddr,
    output wire [`BSEL_BUS          ]   we,
    output wire [`REG_BUS           ]   din,
    
    //异常处理
    input wire                          cp0_we_i,
    input wire [`REG_ADDR_BUS       ]   cp0_waddr_i,
    input wire [`REG_BUS            ]   cp0_wdata_i,
    input wire                          wb2mem_cp0_we,
    input wire [`REG_ADDR_BUS       ]   wb2mem_cp0_wa,
    input wire [`REG_BUS            ]   wb2mem_cp0_wd,
    
    input wire [`INST_ADDR_BUS      ]   mem_pc_i,
    input wire                          mem_in_delay_i,
    input wire [`EXC_CODE_BUS       ]   mem_exccode_i,
    
    input wire [`WORD_BUS           ]   cp0_status,
    input wire [`WORD_BUS           ]   cp0_cause,
    
    output wire                         cp0_we_o,
    output wire [`REG_ADDR_BUS      ]   cp0_waddr_o,
    output wire [`REG_BUS           ]   cp0_wdata_o,
    
    output wire [`INST_ADDR_BUS     ]   cp0_pc,
    output wire                         cp0_in_delay,
    output wire [`EXC_CODE_BUS      ]   cp0_exccode,
    output wire [`REG_BUS           ]   cp0_eaddr
    );
    

    
    wire [`WORD_BUS]    status;
    wire [`WORD_BUS]    cause;
    
    assign status = (wb2mem_cp0_we==`WRITE_ENABLE && wb2mem_cp0_wa == `CP0_STATUS) ? wb2mem_cp0_wd : cp0_status;
    assign cause = (wb2mem_cp0_we == `WRITE_ENABLE && wb2mem_cp0_wa  == `CP0_STATUS) ? wb2mem_cp0_wd : cp0_cause;
    
    assign cp0_in_delay = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : mem_in_delay_i;

    assign cp0_pc = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT : mem_pc_i;
    // 如果当前不是访存指令，则只需要把从执行阶段获得的信息直接输出
    assign mem_wa_o     = (cpu_rst_n == `RST_ENABLE) ? 5'b0  : mem_wa_i;
    assign mem_wreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_wreg_i;
    assign mem_dreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_wd_i;
    assign mem_whilo_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_whilo_i;
    assign mem_hilo_o   = (cpu_rst_n == `RST_ENABLE) ? 64'b0 : mem_hilo_i;
    assign mem_mreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_mreg_i;
    
    //确定当前的访存指令
    wire inst_lb = (mem_aluop_i == 8'h90);
    wire inst_lw = (mem_aluop_i == 8'h92);
    wire inst_sb = (mem_aluop_i == 8'h98);
    wire inst_sw = (mem_aluop_i == 8'h9A);
    //11.10
    wire inst_lbu =(mem_aluop_i == 8'h52);
    wire inst_lh =(mem_aluop_i == 8'h53);
    wire inst_lhu =(mem_aluop_i == 8'h54);
    wire inst_sh =(mem_aluop_i == 8'h55);
    
    assign cp0_exccode = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD:
                         ((status[15:10] & cause[15:10]) != 8'h00 && status[1] == 1'b0 && status[0] == 1'b1) ? `EXC_INT:
                         (inst_lh & (mem_wd_i[0]==1))? `EXC_ADEL:
                         (inst_lhu & (mem_wd_i[0]==1))? `EXC_ADEL:
                         (inst_lw & (mem_wd_i[1:0]!=2'b00))? `EXC_ADEL:
                         (inst_sh & (mem_wd_i[0]==1))? `EXC_ADES:
                         (inst_sw & (mem_wd_i[1:0]!=2'b00))? `EXC_ADES:
                         mem_exccode_i;

    // 直接送至写回阶段的信号
    assign cp0_we_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0:cp0_we_i;
    assign cp0_waddr_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : cp0_waddr_i;
    assign cp0_wdata_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :cp0_wdata_i;
    assign cp0_eaddr = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                       (cp0_exccode == `EXC_ADES)?mem_wd_i:
                       (inst_lh & (mem_wd_i[0]==1))? mem_wd_i:
                       (inst_lhu & (mem_wd_i[0]==1))? mem_wd_i:
                       (inst_lw & (mem_wd_i[1:0]!=2'b00))? mem_wd_i:
                       cp0_wdata_i;
    //无符号扩展
    assign unsign = inst_lbu | inst_lhu;
    
    //获得数据存储器的访问地址
    assign daddr = (cpu_rst_n == `RST_ENABLE)?`ZERO_WORD:mem_wd_i;
    
    //获得数据存储器读字节使能信号
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
        
    //获得数据存储器使能信号
    assign dce = (cpu_rst_n == `RST_ENABLE || cp0_exccode==`EXC_ADES)?1'b0:
                 (inst_lb | inst_lw | inst_sb | inst_sw | inst_lbu | inst_lh | inst_lhu | inst_sh);
    
    //获得数据存储器读字节使能信号
    assign we[3] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b00)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b00)));
    assign we[2] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b01)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b00)));
    assign we[1] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b10)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b10)));
    assign we[0] = (cpu_rst_n == `RST_ENABLE)?1'b0:
                    ((inst_sb & (daddr[1:0] == 2'b11)) | inst_sw | (inst_sh & (daddr[1:0] == 2'b10)));
    
    //确定待写入数据存储器的数据
    wire [`WORD_BUS] din_reverse = {mem_din_i[7:0],mem_din_i[15:8],mem_din_i[23:16],mem_din_i[31:24]};
    wire [`WORD_BUS] din_byte = {mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0]};
    wire [`WORD_BUS] din_bytes = {mem_din_i[7:0],mem_din_i[15:8],mem_din_i[7:0],mem_din_i[15:8]};
    assign din = (cpu_rst_n == `RST_ENABLE)?`ZERO_WORD:
                 (we == 4'b1111)?din_reverse:
                 (we == 4'b1000)?din_byte:
                 (we == 4'b0100)?din_byte:
                 (we == 4'b0010)?din_byte:
                 (we == 4'b0001)?din_byte:
                 (we == 4'b1100)?din_bytes:
                 (we == 4'b0011)?din_bytes:`ZERO_WORD;
endmodule