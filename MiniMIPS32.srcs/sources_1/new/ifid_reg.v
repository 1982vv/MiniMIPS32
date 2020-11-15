`include "defines.v"

module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,

	// ����ȡָ�׶ε���Ϣ  
	input  wire [`INST_ADDR_BUS]       if_pc,
	
	// ��������׶ε���Ϣ  
	output reg  [`INST_ADDR_BUS]       id_pc,
	
	//ת��ָ��
	input  wire [`INST_ADDR_BUS]       if_pc_plus_4,
	output reg  [`INST_ADDR_BUS]       id_pc_plus_4
	);

	always @(posedge cpu_clk_50M) begin
	    // ��λ��ʱ����������׶ε���Ϣ��0
		if (cpu_rst_n == `RST_ENABLE) begin
			id_pc 	<= `PC_INIT;
			id_pc_plus_4 <= `ZERO_WORD;
		end
		// ������ȡָ�׶ε���Ϣ�Ĵ沢��������׶�
		else begin
			id_pc	<= if_pc;		
			id_pc_plus_4 <= if_pc_plus_4;
		end
	end

endmodule