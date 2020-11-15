`timescale 1ns / 1ps

/*------------------- 全局参数 -------------------*/
`define RST_ENABLE      1'b0                // 复位信号有效  RST_ENABLE
`define RST_DISABLE     1'b1                // 复位信号无效
`define ZERO_WORD       32'h00000000        // 32位的数值0
`define ZERO_DWORD      64'b0               // 64位的数值0
`define WRITE_ENABLE    1'b1                // 使能写
`define WRITE_DISABLE   1'b0                // 禁止写
`define READ_ENABLE     1'b1                // 使能读
`define READ_DISABLE    1'b0                // 禁止读
`define ALUOP_BUS       7 : 0               // 译码阶段的输出aluop_o的宽度
`define SHIFT_ENABLE    1'b1                // 移位指令使能 
`define ALUTYPE_BUS     2 : 0               // 译码阶段的输出alutype_o的宽度  
`define TRUE_V          1'b1                // 逻辑“真”  
`define FALSE_V         1'b0                // 逻辑“假”  
`define CHIP_ENABLE     1'b1                // 芯片使能  
`define CHIP_DISABLE    1'b0                // 芯片禁止  
`define WORD_BUS        31: 0               // 32位宽
`define DOUBLE_REG_BUS  63: 0               // 两倍的通用寄存器的数据线宽度
`define RT_ENABLE       1'b1                // rt选择使能
`define SIGNED_EXT      1'b1                // 符号扩展使能
`define IMM_ENABLE      1'b1                // 立即数选择使能
`define UPPER_ENABLE    1'b1                // 立即数移位使能
`define MREG_ENABLE     1'b1                // 写回阶段存储器结果选择信号
`define BSEL_BUS        3 : 0               // 数据存储器字节选择信号宽度
/************************转移指令添加 begin*******************************/
`define JUMP_BUS        25: 0               // J型指令字中instr_index字段的宽度
`define JTSEL_BUS       1 : 0               // 转移地址选择信号的宽度
/*********************** 转移指令添加 end*********************************/
`define PC_INIT         32'h00000000        // PC初始值

/*------------------- 指令字参数 -------------------*/
`define INST_ADDR_BUS   31: 0               // 指令的地址宽度
`define INST_BUS        31: 0               // 指令的数据宽度

// 操作类型alutype
`define NOP             3'b000
`define ARITH           3'b001
`define LOGIC           3'b010
`define MOVE            3'b011
`define SHIFT           3'b100
/************************转移指令添加 begin*******************************/
`define JUMP            3'b101
/*********************** 转移指令添加 end*********************************/
/************************异常处理 begin*******************************/
`define PRIVILEGE       3'b110
/************************异常处理 end*********************************/

// 内部操作码aluop
`define MINIMIPS32_LUI             8'h05
`define MINIMIPS32_MFHI            8'h0C
`define MINIMIPS32_MFLO            8'h0D
`define MINIMIPS32_MTHI            8'h0E
`define MINIMIPS32_MTLO            8'h0F
`define MINIMIPS32_SLL             8'h11 //SLLv // 最终添加指令
`define MINIMIPS32_SRL      8'h12 //SRLV // 最终添加指令
`define MINIMIPS32_SRA      8'h13 //SRAV // 最终添加指令
`define MINIMIPS32_MULT            8'h14
`define MINIMIPS32_MULTU    8'h15 // 最终添加指令
`define MINIMIPS32_DIV             8'h16
`define MINIMIPS32_DIVU     8'h17 // 最终添加指令
`define MINIMIPS32_ADD             8'h18 //ADDI // 最终添加指令
`define MINIMIPS32_ADDIU           8'h19 //ADDU // 最终添加指令
`define MINIMIPS32_SUB      8'h1a // 最终添加指令
`define MINIMIPS32_SUBU            8'h1B
`define MINIMIPS32_AND             8'h1C //ANDI // 最终添加指令
`define MINIMIPS32_ORI             8'h1D //OR // 最终添加指令
`define MINIMIPS32_XOR      8'h1e //XORI // 最终添加指令
`define MINIMIPS32_NOR      8'h1f // 最终添加指令
`define MINIMIPS32_SLT             8'h26 //SLTI // 最终添加指令
`define MINIMIPS32_SLTIU           8'h27 //SLTU // 最终添加指令
`define MINIMIPS32_J               8'h2C
`define MINIMIPS32_JR              8'h2D
`define MINIMIPS32_JAL             8'h2E
`define MINIMIPS32_JALR     8'h2f // 最终添加指令
`define MINIMIPS32_BEQ             8'h30
`define MINIMIPS32_BNE             8'h31
`define MINIMIPS32_BLEZ     8'h32 // 最终添加指令
`define MINIMIPS32_BGTZ     8'h33 // 最终添加指令
`define MINIMIPS32_BLTZ     8'h34 // 最终添加指令
`define MINIMIPS32_BGEZ     8'h35 // 最终添加指令
`define MINIMIPS32_BLTZAL   8'h36 // 最终添加指令
`define MINIMIPS32_BGEZAL   8'h37 // 最终添加指令
`define MINIMIPS32_SYSCALL         8'h86
`define MINIMIPS32_ERET            8'h87
`define MINIMIPS32_MFC0            8'h8C
`define MINIMIPS32_MTC0            8'h8D
`define MINIMIPS32_LB              8'h90
`define MINIMIPS32_LH       8'h91 // 最终添加指令
`define MINIMIPS32_LW              8'h92
`define MINIMIPS32_LBU      8'h94 // 最终添加指令
`define MINIMIPS32_LHU      8'h95 // 最终添加指令
`define MINIMIPS32_SB              8'h98
`define MINIMIPS32_SH       8'h99 // 最终添加指令
`define MINIMIPS32_SW              8'h9A

/*------------------- 通用寄存器堆参数 -------------------*/
`define REG_BUS         31: 0               // 寄存器数据宽度
`define REG_ADDR_BUS    4 : 0               // 寄存器的地址宽度
`define REG_NUM         32                  // 寄存器数量32个
`define REG_NOP         5'b00000            // 零号寄存器
/************************除法和流水线暂停 begin*********************************/
/*------------------- 流水线暂停 -------------------*/
`define STALL_BUS       3 : 0               // 暂停信号宽度
`define STOP            1'b1                // 流水线暂停
`define NOSTOP          1'b0                // 流水线不暂停

/*------------------- 除法指令参数 -------------------*/
`define DIV_FREE            2'b00           // 除法准备状态
`define DIV_BY_ZERO         2'b01           // 判断是否除零状态
`define DIV_ON              2'b10           // 除法开始状态
`define DIV_END             2'b11           // 除法结束状态
`define DIV_READY           1'b1            // 除法运算结束信号
`define DIV_NOT_READY       1'b0            // 除法运算未结束信号
`define DIV_START           1'b1            // 除法开始信号
`define DIV_STOP            1'b0            // 除法未开始信号
/************************除法和流水线暂停 begin*********************************/

/************************异常处理 begin*******************************/
/*------------------- CP0参数 -------------------*/
`define CP0_INT_BUS         5 : 0           // 中断信号的宽度
`define CP0_BADVADDR        8               // BadVAddr寄存器地址（编号）
`define CP0_STATUS          12              // Status寄存器地址（编号）
`define CP0_CAUSE           13              // Cause寄存器地址（编号）
`define CP0_EPC             14              // EPC寄存器地址（编号）

/*------------------- 异常处理参数 -------------------*/
`define EXC_CODE_BUS        4 : 0           // 异常类型编码宽度
`define EXC_INT             5'b00           // 中断异常的编码
`define EXC_ADEL            5'h04           // 加载或取指地址错异常的编码
`define EXC_ADES            5'h05           // 存储地址错异常的编码
`define EXC_SYS             5'h08           // 系统调用异常的编码
`define EXC_BREAK           5'h09           // Break异常的编码
`define EXC_RI              5'h0a           // 错误指令异常的编码
`define EXC_OV              5'h0c           // 整数溢出异常的编码
`define EXC_NONE            5'h10           // 无异常
`define EXC_ERET            5'h11           // ERET异常的编码
`define EXC_ADDR            32'h00000100    // 异常处理程序入口地址
`define EXC_INT_ADDR        32'h00000040    // 中断异常处理程序入口地址

`define NOFLUSH             1'b0            // 不清空流水线
`define FLUSH               1'b1            // 发生异常，清空流水线
/************************异常处理 end*********************************/

/************************SoC添加 begin*******************************/
`define IO_ADDR_BASE        16'hbfd0        // 外部IO设备基址
/************************SoC添加 end*********************************/
