module ucpu(
	rstn, clk,
	ram_wc, ram_rc, o_a, o_d,
	rom_d, next_upc, 
	uir, alu_d,
	alu_ir, r_mdr, /*r_mdrin,*/ a0, a1, a2, a3,
	alu_f, alu_df, alu_f_en, pc);
	input rstn;
	input clk;
	output ram_wc;
	output ram_rc;
	inout [7:0]o_d;
	output [7:0]o_a;
	
	//*** sim look ***
	output [7:0]next_upc;
	output [23:0]rom_d;
	output [23:0]uir;
	output [15:0]alu_d;
	output [15:0]alu_ir;
	output [15:0]r_mdr;
	//output [7:0]r_mdrin;
	//***look***
	output [7:0]a0;
	output [7:0]a1;
	output [7:0]a2;
	output [7:0]a3;
	output [2:0]alu_f;
	output [2:0]alu_df;
	output alu_f_en;
	output [15:0]pc;
	//***look***
	
	wire [7:0]next_upc;
	wire [2:0]alu_fop;
	wire [3:0]alu_asrc;
	wire [3:0]alu_bsrc;
	wire [15:0]alu_d;
	wire [2:0] alu_df;
	wire alu_f_en;
	wire [2:0] alu_f;
	wire ram_wc, ram_rc;
	wire [23:0]uir;
	wire [7:0]uir_imm8;
	wire [7:0]r_mdrin;
	assign uir_imm8 = uir[7:0];
	
	wire [15:0]r_mar;
	wire [15:0]r_mdr;
	assign o_a = r_mar[7:0];
	
	regalu regalu1(clk, rstn,
			alu_fop, alu_asrc, alu_bsrc,
			uir_imm8,
			alu_d, alu_f, alu_df,
			r_mar, r_mdr, {8'b0, o_d},//{8'b0, r_mdrin[7:0]},
			ram_rc, alu_ir,
			a0, a1, a2, a3, pc);
	
	ucu ucu1(
		/* clock */
		clk, rstn,
		/* urom-part */
		rom_d, next_upc,
		/* regalu-part */
		alu_fop, alu_asrc, alu_bsrc, alu_d, alu_df, alu_f_en, alu_f,
		/* ram-part */
		ram_wc, ram_rc,
		/* uir ouput */
		uir);
	
	/*\74465 o_d_bus(.gn1(~ram_wc), .gn2(1'b0),
		.a1(r_mdr[0]), .a2(r_mdr[1]), .a3(r_mdr[2]), .a4(r_mdr[3]),
		.a5(r_mdr[4]), .a6(r_mdr[5]), .a7(r_mdr[6]), .a8(r_mdr[7]),
		.y1(o_d[0]), .y2(o_d[1]), .y3(o_d[2]), .y4(o_d[3]),
		.y5(o_d[4]), .y6(o_d[5]), .y7(o_d[6]), .y8(o_d[7]));*/
	assign o_d = !ram_rc ? r_mdr[7:0] : 8'hzz;
	//assign r_mdrin = o_d;
	
	\lpm_rom um (.address(next_upc),.q(rom_d),.memenab(1'b1), .inclock(~clk));
	defparam
		um.LPM_WIDTH = 24,
		um.LPM_WIDTHAD = 8,
		um.LPM_ADDRESS_CONTROL = "REGISTERED",
		um.LPM_OUTDATA = "UNREGISTERED",
		um.LPM_FILE = "sim_um.mif";              //微程序码（HEX）文件，在同目录不要路径

	/*\lpm_ram_dq mm(.data(r_mdr[7:0]),
              .address(o_a), 
              .we(ram_wc),
              .inclock(~clk), //地址和we输入寄存clock，与LPM_ADDRESS_CONTROL对应
              .q(r_mdrin[7:0]));
	defparam
		mm.LPM_WIDTH = 8,
		mm.LPM_WIDTHAD = 8,
		//mm.LPM_NUMWORDS = 256,
		mm.LPM_INDATA = "REGISTERED",
		mm.LPM_ADDRESS_CONTROL = "REGISTERED",
		mm.LPM_OUTDATA = "UNREGISTERED",
		mm.LPM_FILE = "cpu12_mm.mif",
		mm.LPM_TYPE = "LPM_RAM_DQ",
		mm.LPM_HINT = "UNUSED";*/
	/*\lpm_ram_io mm (.address(r_mar),.we(ram_wc),.inclock(~clk),.outenab(ram_rc),.dio(o_d));
	defparam
		mm.LPM_WIDTH   = 8,                      //数据宽度
		mm.LPM_WIDTHAD = 8,                      //地址宽度
        mm.LPM_INDATA = "UNREGISTERED",          //数据输入不寄存，不要inclock
		mm.LPM_ADDRESS_CONTROL = "REGISTERED",   //地址输入寄存，要inclock
		mm.LPM_OUTDATA = "UNREGISTERED",         //输出数据不寄存，不要outclock
		mm.LPM_FILE = "cpu12_mm.mif",             //运行的目标（HEX）文件，在同目录不要路径
		mm.LPM_HINT = "UNUSED",                  //for VHDL 
        //mm.LPM_TYPE = "LPM_RAM_IO",              //类型：双向
        mm.USE_EAB	= "ON";                      //FPGA隐藏块使用              //FPGA隐藏块使用*/

endmodule