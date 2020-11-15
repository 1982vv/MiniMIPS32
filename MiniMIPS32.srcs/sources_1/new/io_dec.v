`include "defines.v"

`define addrIsLed(addr)     (addr[15:0] == 16'hf000)	// 单色LED灯基址
`define addrIsLedRGB0(addr) (addr[15:0] == 16'hf100)	// 三色灯LED0基址
`define addrIsLedRGB1(addr) (addr[15:0] == 16'hf104)	// 三色灯LED1基址
`define addrIsNum(addr)     (addr[15:0] == 16'hf200)	// 七段数码管基址
`define addrIsTimer(addr)   (addr[15:0] == 16'he000)	// 计时器基址

module io_dec(
    input             	clk,
    input               rst_n,
    input             	ce,
    input   [31:0]		addr,
    input   [31:0]		din,
    input             	we,
	output  [31:0]		dout,
    
    output 	[15:0]		led,
	output  [2:0] 		led_rgb0,
	output  [2:0] 		led_rgb1,
	output	reg [7:0]	num_csn,
	output	reg [6:0]	num_a_g
    );
	
	// I/O设备写使能信号
	wire led_we = we && `addrIsLed(addr);
	wire led_rgb0_we = we && `addrIsLedRGB0(addr); 
	wire led_rgb1_we = we && `addrIsLedRGB1(addr); 
	wire num_we = we && `addrIsNum(addr); 
	wire timer_we = we & `addrIsTimer(addr);

	// 从输入设备（timer）读取的数据
    reg [31:0] timer;
	wire [31:0] data_t = `addrIsTimer(addr) ? timer : 32'h00000000;
	assign dout = {data_t[7:0], data_t[15:8], data_t[23:16], data_t[31:24]};

	// 待写入输出设备（单色LED、三色LED和七段数码管）的数据
    wire [31:0] data_i = {din[7:0], din[15:8], din[23:16], din[31:24]};
	
	// 向I/O设备写入数据
	reg [31:0] led_data;
	assign led = led_data[15:0];
	reg [31:0] led_rgb0_data;
	assign led_rgb0 = led_rgb0_data[2:0];
	reg [31:0] led_rgb1_data;
	assign led_rgb1 = led_rgb1_data[2:0];
	reg [31:0] num_data;
	
	// 单色LED，两个三色LED及七段数码管输出信号
	always @(posedge clk) begin
		if(rst_n == `RST_ENABLE) begin
			led_data <= `ZERO_WORD;
			led_rgb0_data <= `ZERO_WORD;
			led_rgb1_data <= `ZERO_WORD;
			num_data <= `ZERO_WORD;
		end
		else begin
            if(ce == `CHIP_ENABLE)
                case({led_we,led_rgb0_we,led_rgb1_we,num_we})
                    4'b1000: led_data <= data_i;
                    4'b0100: led_rgb0_data <= data_i;
                    4'b0010: led_rgb1_data <= data_i;
                    4'b0001: num_data <= data_i;
                endcase
		end
	end
	
	// timer计时器的实现
    always @(posedge clk) begin
        if(rst_n == `RST_ENABLE) begin
            timer <= 32'd0;
        end
        else if(ce == `CHIP_ENABLE && timer_we) begin
            timer <= data_i;
        end
        else begin
            timer <= timer + 1'b1;
        end
    end

	// 七段数码管的动态扫描
	reg [19:0] div_counter;
	always @(posedge clk) begin 
	    if(rst_n == `RST_ENABLE) begin
	        div_counter <= 0;
	    end
		else begin
			div_counter <= div_counter + 1;
		end
	end
	
    parameter[2:0] SEG1 = 3'b000,
	               SEG2 = 3'b001,
	               SEG3 = 3'b010,
	               SEG4 = 3'b011,
	               SEG5 = 3'b100,
	               SEG6 = 3'b101,
	               SEG7 = 3'b110,
	               SEG8 = 3'b111;
	                
	reg [3:0] value;
    always @(posedge clk) begin
	    if(rst_n == `RST_ENABLE) begin
	        num_csn <= 8'b11111111;
	        value <= 4'b0;
	    end else begin
	        case(div_counter[19:17])
	            SEG1: begin
	                value <= num_data[31:28];
	                num_csn <= 8'b01111111;
	            end
	            SEG2: begin
	                value <= num_data[27:24];
	                num_csn <= 8'b10111111;
	            end
	            SEG3: begin
	                value <= num_data[23:20];
	                num_csn <= 8'b11011111;
	            end
	            SEG4: begin
	                value <= num_data[19:16];
	                num_csn <= 8'b11101111;
	            end
	            SEG5: begin
	                value <= num_data[15:12];
	                num_csn <= 8'b11110111;
	            end
	            SEG6: begin
	                value <= num_data[11:8];
	                num_csn <= 8'b11111011;
	            end
	            SEG7: begin
	                value <= num_data[7:4];
	                num_csn <= 8'b11111101;
	            end
	            SEG8: begin
	                value <= num_data[3:0];
	                num_csn <= 8'b11111110;
	            end
	            default: begin
	            end
	        endcase
	     end
	end
	
    always @(posedge clk) begin
    	if(rst_n == `RST_ENABLE)
    		num_a_g <= 7'b0000000;
    	else begin
			case(value)
				4'd0 : num_a_g <= 7'b0000001;   //0
				4'd1 : num_a_g <= 7'b1001111;   //1
				4'd2 : num_a_g <= 7'b0010010;   //2
				4'd3 : num_a_g <= 7'b0000110;   //3
				4'd4 : num_a_g <= 7'b1001100;   //4
				4'd5 : num_a_g <= 7'b0100100;   //5
				4'd6 : num_a_g <= 7'b0100000;   //6
				4'd7 : num_a_g <= 7'b0001111;   //7
				4'd8 : num_a_g <= 7'b0000000;   //8
				4'd9 : num_a_g <= 7'b0000100;   //9
				4'd10: num_a_g <= 7'b0001000;   //a
				4'd11: num_a_g <= 7'b1100000;   //b
				4'd12: num_a_g <= 7'b0110001;   //c
				4'd13: num_a_g <= 7'b1000010;   //d
				4'd14: num_a_g <= 7'b0110000;   //e
				4'd15: num_a_g <= 7'b0111000;   //f
				default : num_a_g <= 7'b0000000;
			endcase
		end
	end
    
endmodule
