`include "defines.v"

module id_stage(
    input  wire                     cpu_rst_n,
    
    // 从取指阶段获得的PC值
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // 从指令存储器读出的指令字
    input  wire [`INST_BUS     ]    id_inst_i,

    // 从通用寄存器堆读出的数据 
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
      
    // 送至执行阶段的译码信息
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire                     id_whilo_o,
    output wire                     id_mreg_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,
    output wire [`REG_BUS]          id_din_o,

    // 送至执行阶段的源操作数1、源操作数2
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // 送至读通用寄存器堆端口的使能和地址
    output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2,
    
    /*-------------------- 定向前推 --------------------*/
    //从执行阶段获得的写回信号
    input wire                      exe2id_wreg,
    input wire [`REG_ADDR_BUS]      exe2id_wa,
    input wire [`INST_BUS]          exe2id_wd,
    //从访存阶段获得的写回信号
    input wire                      mem2id_wreg,
    input wire [`REG_ADDR_BUS]      mem2id_wa,
    input wire [`INST_BUS]          mem2id_wd,
    
    /*-------------------- 跳转指令 --------------------*/
    input wire [`INST_ADDR_BUS]     pc_plus_4,
    
    output wire [`INST_ADDR_BUS]    jump_addr_1,
    output wire [`INST_ADDR_BUS]    jump_addr_2,
    output wire [`INST_ADDR_BUS]    jump_addr_3,
    output wire [`JTSEL_BUS    ]    jtsel,
    output wire [`INST_ADDR_BUS]    ret_addr
    );
    
    // 根据小端模式组织指令字
    wire [`INST_BUS] id_inst = {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

    // 提取指令字中各个字段的信息
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    /*-------------------- 第一级译码逻辑：确定当前需要译码的指令 --------------------*/
    wire inst_reg  = ~|op;//op全0则reg为1
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    
    //10.27 增加15条非跳转指令
    wire inst_subu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_slt = inst_reg& func[5]&~func[4]& func[3]&~func[2]& func[1]&~func[0];
    wire inst_add = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mult = inst_reg&~func[5]& func[4]& func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mfhi = inst_reg&~func[5]& func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo = inst_reg&~func[5]& func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_sll = inst_reg&~func[5]&~func[4] &~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_ori =~op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0];
    wire inst_lui =~op[5]&~op[4]&op[3]& op[2]& op[1]& op[0];
    wire inst_addiu=~op[5]&~op[4]& op[3]& ~op[2]&~op[ 1]& op[0];
    wire inst_sltiu=~op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];
    wire inst_lb =op[5]&~op[4]&~op[3]&~op[2]&op[0];
    wire inst_lw =op[5]&~op[4]&~op[3] &~op[2]& op[1]& op[0];
    wire inst_sb =op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sw =op[5]&~op[4]& op[3]&~op[2]&op[1]&op[0];
    
    //11.8 增加22条非转移指令
    wire inst_addu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& ~func[1]& func[0];
    wire inst_sub = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& ~func[1]& ~func[0];
    wire inst_sltu = inst_reg& func[5]&~func[4]&func[3]&~func[2]& func[1]& func[0];
    wire inst_or = inst_reg& func[5]&~func[4]&~func[3]&func[2]& ~func[1]& func[0];
    wire inst_nor = inst_reg& func[5]&~func[4]&~func[3]&func[2]& func[1]& func[0];
    wire inst_xor = inst_reg& func[5]&~func[4]&~func[3]&func[2]& func[1]& ~func[0];
    wire inst_srl = inst_reg& ~func[5]& ~func[4]& ~func[3]& ~func[2]& func[1]& ~func[0];
    wire inst_sra = inst_reg& ~func[5]& ~func[4]& ~func[3]& ~func[2]& func[1]& func[0];
    wire inst_sllv = inst_reg& ~func[5]& ~func[4]& ~func[3]& func[2]& ~func[1]& ~func[0];
    wire inst_srlv = inst_reg& ~func[5]& ~func[4]& ~func[3]& func[2]& func[1]& ~func[0];
    wire inst_srav = inst_reg& ~func[5]& ~func[4]& ~func[3]& func[2]& func[1]& func[0];
    wire inst_multu = inst_reg& ~func[5]& func[4]& func[3]& ~func[2]& ~func[1]& func[0];
    wire inst_mthi = inst_reg& ~func[5]& func[4]& ~func[3]& ~func[2]& ~func[1]& func[0];
    wire inst_mtlo = inst_reg& ~func[5]& func[4]& ~func[3]& ~func[2]& func[1]& func[0];
    wire inst_addi = ~op[5]& ~op[4]& op[3]& ~op[2]& ~op[1]& ~op[0];
    wire inst_slti = ~op[5]& ~op[4]& op[3]& ~op[2]& op[1]& ~op[0];
    wire inst_andi = ~op[5]& ~op[4]& op[3]& op[2]& ~op[1]& ~op[0];
    wire inst_xori = ~op[5]& ~op[4]& op[3]& op[2]& op[1]& ~op[0];
    wire inst_lbu = op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& ~op[0];
    wire inst_lh = op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0];
    wire inst_lhu = op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& op[0];
    wire inst_sh = op[5]& ~op[4]& op[3]& ~op[2]& ~op[1]& op[0];
    
    //11.13 增加5条转移指令
    wire inst_j = ~op[5]& ~op[4]& ~op[3]& ~op[2]& op[1]& ~op[0];
    wire inst_jal = ~op[5]& ~op[4]& ~op[3]& ~op[2]& op[1]& op[0];
    wire inst_jr = inst_reg &~func[5]& ~func[4]& func[3]& ~func[2]& ~func[1]& ~func[0];
    wire inst_beq = ~op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& ~op[0];
    wire inst_bne = ~op[5]& ~op[4]& ~op[3]& op[2]& ~op[1]& op[0];
    
    //12.14 增加7条转移指令
    wire inst_jalr = inst_reg &~func[5]& ~func[4]& func[3]& ~func[2]& ~func[1]& func[0];
    wire inst_bgez = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& ~id_inst[20]& id_inst[16];
    wire inst_bgtz = ~op[5]& ~op[4]& ~op[3]& op[2]& op[1]& op[0];
    wire inst_blez = ~op[5]& ~op[4]& ~op[3]& op[2]& op[1]& ~op[0];
    wire inst_bltz = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& ~id_inst[20]& ~id_inst[16];
    wire inst_bgezal = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& id_inst[20]& id_inst[16];
    wire inst_bltzal = ~op[5]& ~op[4]& ~op[3]& ~op[2]& ~op[1]& op[0]& id_inst[20]& ~id_inst[16];
    /*------------------------------------------------------------------------------*/
    /*-------------------- 第二级译码逻辑：生成具体控制信号 --------------------*/
    // 操作类型alutype
    assign id_alutype_o[2] =(cpu_rst_n == `RST_ENABLE)? 1'b0: (inst_sll |inst_srl |inst_sra |inst_sllv |inst_srlv |inst_srav
                            | inst_j | inst_jal | inst_jr | inst_beq | inst_bne | inst_jalr |inst_bgez | inst_bgtz | inst_blez
                            | inst_bltz | inst_bgezal | inst_bltzal);
    assign id_alutype_o[1] =(cpu_rst_n == `RST_ENABLE)?1'b0:(inst_and | inst_mfhi | inst_mflo | inst_ori | inst_lui
                            | inst_or | inst_nor | inst_xor |  inst_andi | inst_xori);
    assign id_alutype_o[0] =(cpu_rst_n ==`RST_ENABLE)?1'b0: (inst_add | inst_subu | inst_slt | inst_mfhi | inst_mflo
                            | inst_addiu | inst_sltiu | inst_lb |inst_lw | inst_sb | inst_sw
                            | inst_addu | inst_sub | inst_sltu | inst_mthi | inst_mtlo | inst_andi | inst_slti | inst_lbu 
                            | inst_lh | inst_lhu | inst_sh | inst_j | inst_jal | inst_jr | inst_beq | inst_bne | inst_jalr |inst_bgez | inst_bgtz | inst_blez
                            | inst_bltz | inst_bgezal | inst_bltzal);
    //内部操作码aluop
    assign id_aluop_o[7] =(cpu_rst_n ==`RST_ENABLE)? 1'b0: (inst_lb | inst_lw | inst_sb | inst_sw);
    assign id_aluop_o[6]=(cpu_rst_n ==`RST_ENABLE)? 1'b0:(inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
                         | inst_xor | inst_srl| inst_sra | inst_sllv | inst_srlv | inst_srav | inst_multu 
                         |  inst_mthi | inst_mtlo | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                         | inst_lh |inst_lhu | inst_sh);
    assign id_aluop_o[5] =(cpu_rst_n == `RST_ENABLE)? 1'b0: (inst_slt | inst_sltiu | inst_j | inst_jal 
                            | inst_jr | inst_beq | inst_bne | inst_jalr |inst_bgez | inst_bgtz | inst_blez
                            | inst_bltz | inst_bgezal | inst_bltzal);
    assign id_aluop_o[4] =(cpu_rst_n ==`RST_ENABLE)? 1'b0:
     (inst_add | inst_subu | inst_and | inst_mult | inst_sll |
     inst_ori | inst_addiu | inst_lb | inst_lw | inst_sb | inst_sw
     | inst_andi | inst_xori | inst_lbu | inst_lh |inst_lhu | inst_sh
     | inst_beq | inst_bne| inst_jalr |inst_bgez | inst_bgtz | inst_blez
     | inst_bltz | inst_bgezal | inst_bltzal);
    assign id_aluop_o[3]=(cpu_rst_n==`RST_ENABLE)?1'b0:
     (inst_add | inst_subu | inst_and | inst_mfhi | inst_mflo |
     inst_ori | inst_addiu | inst_sb | inst_sw
     | inst_sllv | inst_srlv | inst_srav | inst_multu 
     |  inst_mthi | inst_mtlo | inst_j | inst_jal 
     | inst_jr | inst_bltzal);
    assign id_aluop_o[2]=(cpu_rst_n==`RST_ENABLE)?1'b0:
     (inst_slt | inst_and | inst_mult | inst_mfhi | inst_mflo|
     inst_ori | inst_lui | inst_sltiu | inst_nor 
     | inst_xor | inst_srl| inst_sra |  inst_mthi | inst_mtlo
     | inst_addi | inst_slti |inst_lhu | inst_sh
     | inst_j | inst_jal | inst_jr | inst_bgtz | inst_blez
     | inst_bltz | inst_bgezal);
     assign id_aluop_o[1] =(cpu_rst_n ==`RST_ENABLE)? 1'b0:
     (inst_subu | inst_slt | inst_sltiu | inst_lw | inst_sw
     | inst_sltu | inst_or | inst_srl| inst_sra | inst_srav | inst_multu
     | inst_addi | inst_slti | inst_lbu | inst_lh | inst_jal
     | inst_jalr |inst_bgez | inst_bltz | inst_bgezal);
     assign id_aluop_o[0] =(cpu_rst_n ==`RST_ENABLE)?1'b0:
     (inst_subu | inst_mflo | inst_sll |
    inst_ori | inst_lui | inst_addiu | inst_sltiu
    | inst_sub | inst_or  | inst_xor | inst_sra | inst_srlv | inst_multu 
    | inst_mtlo  | inst_slti  | inst_xori 
    | inst_lh | inst_sh | inst_jr | inst_bne
    |inst_bgez | inst_blez | inst_bgezal);


    //写通用寄存器使能信号
    assign id_wreg_o=(cpu_rst_n == `RST_ENABLE)?1'b0:
    (inst_add | inst_subu | inst_slt | inst_and | inst_mfhi | inst_mflo | inst_sll |
    inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw
    |inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
    | inst_xor | inst_srl| inst_sra | inst_sllv | inst_srlv | inst_srav
    | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
    | inst_lh |inst_lhu  | inst_jal |inst_jalr | inst_bgezal | inst_bltzal);
    //写HILO寄存器使能信号
    assign id_whilo_o =(cpu_rst_n == `RST_ENABLE)?1'b0:(inst_mult| inst_multu 
                             |  inst_mthi | inst_mtlo) ;
                             
    //生成相等使能信号
    wire equ =(cpu_rst_n == `RST_ENABLE)?1'b0:
               (inst_beq)?(id_src1_o == id_src2_o):
               (inst_bne)?(id_src1_o != id_src2_o):
               (inst_bgez)?($signed(id_src1_o) >= 1'b0):
               (inst_bgtz)?($signed(id_src1_o) > 1'b0):
               (inst_blez)?($signed(id_src1_o) <= 1'b0):
               (inst_bltz)?($signed(id_src1_o) < 1'b0):
               (inst_bgezal)?($signed(id_src1_o) >= 1'b0):
               (inst_bltzal)?($signed(id_src1_o) < 1'b0):1'b0;
    //移位使能指令
    wire shift =inst_sll| inst_srl| inst_sra ;
    //立即数使能信号
    wire immsel = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw
                  | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                  | inst_lh |inst_lhu | inst_sh;

    //目的寄存器选择信号
    wire rtsel=inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw
                | inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                            | inst_lh |inst_lhu ;
    //符号扩展使能信号
    wire sext =inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw
                | inst_addi | inst_slti | inst_lbu 
                | inst_lh |inst_lhu | inst_sh;
    //加载高半字使能信号
    wire upper =inst_lui;
    //存储器到寄存器使能信号
    assign id_mreg_o =(cpu_rst_n == `RST_ENABLE)? 1'b0: (inst_lb | inst_lw| inst_lbu 
                             | inst_lh |inst_lhu );
    //读通用寄存器堆端口1使能信号
    assign rreg1=(cpu_rst_n == `RST_ENABLE)?1'b0:
                                 (inst_add | inst_subu | inst_slt | inst_and | inst_mult|
                                inst_ori | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw
                             | inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
                             | inst_xor | inst_sllv | inst_srlv | inst_srav | inst_multu 
                             |  inst_mthi | inst_mtlo| inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu 
                             | inst_lh |inst_lhu | inst_sh | inst_jr | inst_beq |inst_bne | inst_jalr |inst_bgez 
                             | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal);
    //读通用寄存器堆读端口2使能信号
    assign rreg2=(cpu_rst_n==`RST_ENABLE)?1'b0:
                              (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_sll | inst_sb | inst_sw
                              | inst_addu | inst_sub | inst_sltu | inst_or | inst_nor 
                              | inst_xor | inst_srl| inst_sra | inst_sllv | inst_srlv | inst_srav | inst_multu |inst_sh
                              | inst_beq |inst_bne);
    //生成子程序调用信号
    wire jal=inst_jal | inst_bgezal | inst_bltzal | inst_jalr;
    
    //生成转移地址选择信号
    assign jtsel[1]=inst_jr | inst_beq & equ | inst_bne & equ | inst_bgez& equ | inst_bgtz& equ | inst_blez& equ
                    | inst_bltz& equ | inst_bgezal& equ | inst_bltzal& equ | inst_jalr;
    assign jtsel[0]=inst_j | inst_jal | inst_beq & equ | inst_bne & equ| inst_bgez& equ | inst_bgtz& equ | inst_blez& equ
                    | inst_bltz& equ | inst_bgezal& equ | inst_bltzal& equ;
    
    //产生源操作数选择信号
    wire [1:0] fwrd1 = (cpu_rst_n==`RST_ENABLE)? 2'b00:
                        (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra1 && rreg1 ==`READ_ENABLE)?2'b01:
                        (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra1 && rreg1 ==`READ_ENABLE)?2'b10:
                        (rreg1 ==`READ_ENABLE)?2'b11:2'b00;
                        
    wire [1:0] fwrd2 = (cpu_rst_n==`RST_ENABLE)? 2'b00:
                        (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra2 && rreg2 ==`READ_ENABLE)?2'b01:
                        (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra2 && rreg2 ==`READ_ENABLE)?2'b10:
                        (rreg2 ==`READ_ENABLE)?2'b11:2'b00;
    /*------------------------------------------------------------------------------*/

    // 读通用寄存器堆端口1的地址为rs字段，读端口2的地址为rt字段
    assign ra1 =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD: rs;
    assign ra2 =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:rt;
    //获得指令操作所需的立即数
    wire [31: 0] imm_ext=(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD:
    (upper == `UPPER_ENABLE )?(imm<<16):
    (sext ==`SIGNED_EXT)?{{16{imm[15]}},imm}:{{16{1'b0}},imm};
    //获得待写入目的寄存器的地址(rt或rd)
    assign id_wa_o =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD :
                    (rtsel ==`RT_ENABLE )? rt:
                    (jal == 1'd1     )? 5'b11111:rd;
    //获得访存阶段要存入数据存储器的数据(来自通用寄存器堆读数据端口2)
    assign id_din_o =(cpu_rst_n ==`RST_ENABLE)? `ZERO_WORD: rd2;
    //获得源操作数1。如果 shift信号有效,则源操作数1为移位位数,否则为从读通用寄存器堆端口1获得的数据
    assign id_src1_o =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:
    (shift ==`SHIFT_ENABLE )?{27'b0, sa}:
    (fwrd1 ==2'b01 )? exe2id_wd:
    (fwrd1 ==2'b10 )? mem2id_wd:
     (fwrd1 ==2'b11 )? rd1: `ZERO_WORD;
    //获得源操作数2。如果 immsel信号有效,则源操作数1为立即数,否则为从读通用寄存器堆端口2获得的数据
    assign id_src2_o =(cpu_rst_n == `RST_ENABLE)? `ZERO_WORD:
    (immsel ==`IMM_ENABLE )?imm_ext:
    (fwrd2 ==2'b01 )? exe2id_wd:
    (fwrd2 ==2'b10 )? mem2id_wd:
     (fwrd2 ==2'b11 )? rd2: `ZERO_WORD;
    
    //生成计算转移地址所需信号
    wire [`INST_ADDR_BUS] pc_plus_8=pc_plus_4+4;
    wire [`JUMP_BUS     ] instr_index =id_inst[25:0];
    wire [`INST_ADDR_BUS] imm_jump={{14{imm[15]}},imm,2'b00};
    
    //获得转移地址
    assign jump_addr_1 ={pc_plus_4[31:28],instr_index,2'b00};
    assign jump_addr_2 =pc_plus_4+imm_jump;
    assign jump_addr_3 =id_src1_o;
    
    //生成子程序调用的返回地址
    assign ret_addr =pc_plus_8;
    
endmodule
