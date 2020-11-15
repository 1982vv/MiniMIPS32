`include "defines.v"

module MiniMIPS32_SYS(
    input wire sys_clk_100M,
    input wire sys_rst_n,
/************************SoC添加 begin*******************************/
    output wire [15:0] led,
	output wire [2 :0] led_rgb0,
	output wire [2 :0] led_rgb1,
	output wire [7 :0] num_csn,
	output wire [6 :0] num_a_g
/************************SoC添加 end*********************************/
    );

    wire                  cpu_clk_50M;
    wire [`INST_ADDR_BUS] iaddr;
    wire                  ice;
    wire [`INST_BUS     ] inst;
    wire                  dce;
    wire [`INST_ADDR_BUS] daddr;
    wire [`BSEL_BUS     ] we;
    wire [`INST_BUS     ] din;
    wire [`INST_BUS     ] dout;
/************************SoC添加 begin*******************************/
    wire [`INST_ADDR_BUS] inst_addr;
    wire                  inst_ce;
    wire [`INST_BUS     ] inst_dout;
    wire                  data_ce;
    wire [`INST_ADDR_BUS] data_addr;
    wire [`BSEL_BUS     ] data_we;
    wire [`INST_BUS     ] data_din;
    wire [`INST_BUS     ] data_dout;
    wire                  io_ce;
    wire [`BSEL_BUS     ] io_we;
    wire [`INST_ADDR_BUS] io_addr;
    wire [`INST_BUS     ] io_din;
    wire [`INST_BUS     ] io_dout;
/************************SoC添加 end*********************************/

    clk_wiz_0 clocking
    (
        // Clock out ports
        .clk_out1(cpu_clk_50M),     // output clk_out1
        // Clock in ports
        .clk_in1(sys_clk_100M)
    );      // input clk_in1

/************************实例化CPU*********************************/
   MiniMIPS32 minimips32 (
        .cpu_clk_50M(cpu_clk_50M),
        .cpu_rst_n(sys_rst_n),
        .iaddr(iaddr), 
        .ice(ice),
        .inst(inst),
        .dce(dce),
        .daddr(daddr),
        .we(we),
        .din(din),
        .dm(dout)
    );

/************************SoC修改 begin*******************************/
    dev_if dev_if0 (
        .sys_rst_n(sys_rst_n),
        .iaddr(iaddr),
        .ice(ice),
        .inst(inst),
        .dce(dce),
        .daddr(daddr),
        .we(we),
        .din(din),
        .dout(dout),

        .inst_ce(inst_ce),
        .inst_addr(inst_addr),
        .inst_dout(inst_dout),
        .data_ce(data_ce),
        .data_we(data_we),
        .data_addr(data_addr),
        .data_din(data_din),
        .data_dout(data_dout),
        .io_ce(io_ce),
        .io_we(io_we),
        .io_addr(io_addr),
        .io_din(io_din),
        .io_dout(io_dout)
    );

    inst_rom inst_rom0 (
      .clka(cpu_clk_50M),    // input wire clka
      .ena(inst_ce),      // input wire ena
      .addra(inst_addr[16:2]),  // input wire [14 : 0] addra
      .douta(inst_dout)  // output wire [31 : 0] douta
    );

    data_ram data_ram0 (
        .clka(cpu_clk_50M),    // input wire clka
        .ena(data_ce),      // input wire ena
        .wea(data_we),      // input wire [3 : 0] wea
        .addra(data_addr[12:2]),  // input wire [10 : 0] addra
        .dina(data_din),    // input wire [31 : 0] dina
        .douta(data_dout)  // output wire [31 : 0] douta
    );

    io_dec io_dec0(
        .clk(cpu_clk_50M),
        .rst_n(sys_rst_n),
        .ce(io_ce),
        .addr(io_addr),
        .din(io_din),
        .dout(io_dout),
        .we(io_we),
        .led(led),
	    .led_rgb0(led_rgb0),
	    .led_rgb1(led_rgb1),
	    .num_csn(num_csn),
	    .num_a_g(num_a_g)
    );
/************************SoC修改 end*********************************/

endmodule
