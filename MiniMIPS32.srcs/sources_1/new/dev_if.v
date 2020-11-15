`include "defines.v"

module dev_if(
    input  wire sys_rst_n,

    input  wire [`INST_ADDR_BUS] iaddr,
    input  wire                  ice,
    output wire [`INST_BUS     ] inst,

    input  wire                  dce,
    input  wire [`BSEL_BUS     ] we,
    input  wire [`INST_ADDR_BUS] daddr,
    input  wire [`INST_BUS     ] din,
    output wire [`INST_BUS     ] dout,

    output wire                  inst_ce,
    output wire [`INST_ADDR_BUS] inst_addr,
    input  wire [`INST_BUS     ] inst_dout,

    output wire                  data_ce,
    output wire [`BSEL_BUS     ] data_we,
    output wire [`INST_ADDR_BUS] data_addr,
    output wire [`INST_BUS     ] data_din,
    input  wire [`INST_BUS     ] data_dout,
    
    output wire                  io_ce,
    output wire                  io_we,
    output wire [`INST_ADDR_BUS] io_addr,
    output wire [`INST_BUS     ] io_din,
    input  wire [`INST_BUS     ] io_dout
    );

    // 产生与指令存储器相关的信号
    assign inst_ce   = (sys_rst_n == `RST_ENABLE) ? 1'b0 : ice;
    assign inst_addr = (sys_rst_n == `RST_ENABLE) ? `ZERO_WORD : iaddr;
    assign inst      = (sys_rst_n == `RST_ENABLE) ? `ZERO_WORD : inst_dout;

    // 产生与数据存储器相关的信号
    assign data_ce   = (sys_rst_n == `RST_ENABLE) ? 1'b0 : 
                       (daddr[31:16] != `IO_ADDR_BASE) ? dce : 1'b0;
    assign data_we   = (sys_rst_n == `RST_ENABLE) ? 4'b0 : we;
    assign data_addr = (sys_rst_n == `RST_ENABLE) ? `ZERO_WORD : daddr;
    assign data_din  = (sys_rst_n == `RST_ENABLE) ? `ZERO_WORD : din;

    // 产生与I/O设备相关的信号
    assign io_ce     = (sys_rst_n == `RST_ENABLE) ? 1'b0 : 
                       (daddr[31:16] == `IO_ADDR_BASE) ? dce : 1'b0;
    assign io_we     = (sys_rst_n == `RST_ENABLE) ? 1'b0 : |we;
    assign io_addr   = (sys_rst_n == `RST_ENABLE) ? `ZERO_WORD : daddr;
    assign io_din    = (sys_rst_n == `RST_ENABLE) ? `ZERO_WORD : din;

    // 从数据存储器或I/O设备中获取数据
    assign dout = (daddr[31:16] == `IO_ADDR_BASE) ? io_dout : data_dout;
endmodule
