module ucu(
		/* clock */
		clk, rstn,
		/* urom-part */
		rom_d, next_upc,
		/* regalu-part */
		alu_fop, alu_asrc, alu_bsrc, alu_d, alu_df, alu_f_en, alu_f,
		/* ram-part */
		real_ram_wc, real_ram_rc,
		/* uir output */
		uir
		);
	/* clock */
	input clk;
	input rstn;
	
	/* urom-part */
	input [23:0]rom_d;
	output [7:0]next_upc;
	
	/* regalu-part */
	output [2:0]alu_fop;
	output [3:0]alu_asrc;
	output [3:0]alu_bsrc;
	input [15:0]alu_d;
	input [2:0]alu_df; /* d 标志 */
	output alu_f_en;
	output [2:0]alu_f; /* 2:AO 1:C 0:Z */
	
	/* ram-part */
	output real_ram_wc;
	output real_ram_rc;
	wire ram_wc;
	wire ram_rc;
	assign real_ram_wc = ram_wc;
	assign real_ram_rc = ram_rc;
	
	output [23:0]uir;
	reg [23:0]uir;
	reg [7:0]upc;
	wire [7:0]next_upc;
	//*** uinstruction type ***
	wire [1:0]j_flags;
	wire [7:0]imm8;
	assign alu_f_en = uir[23];
	assign alu_fop = uir[22:20];
	assign alu_asrc = uir[19:16];
	assign alu_bsrc = uir[15:12];
	assign j_flags = uir[11:10];
	assign ram_wc = uir[9];
	assign ram_rc = uir[8];
	assign imm8 = uir[7:0];
	
	reg upc_ld;
	reg [7:0]upc_ldin;
	reg [2:0]alu_f;
	/* 条件转：C,addr;Z,addr+1;AO,addr+2;失败,addr+3 */
	assign next_upc = upc_ld ? upc_ldin : upc + 8'b1;
	always @(upc or j_flags or alu_f_en or alu_f or alu_df or imm8 or alu_d)
	begin
		upc_ld = 1'b0;
		upc_ldin = 8'hxx;
		
		case(j_flags)
		2'b01:
			begin
				upc_ld = 1'b1;
				upc_ldin = imm8 + alu_f;
			end
		2'b10:
			begin
				upc_ld = 1'b1;
				upc_ldin = imm8;
			end
		2'b11:
			begin
				upc_ld = 1'b1;
				upc_ldin = alu_d[7:0];
			end
		default:;
		endcase
	end
	
	always @(posedge clk or negedge rstn)
	begin
		if(!rstn)
		begin
			uir <= 24'b0;
			alu_f <= 3'b000;
			upc <= 8'hff;	//从upc+1开始取微指令
		end
		else
		begin
			uir <= rom_d;
			upc <= next_upc;
			if(alu_f_en)
					alu_f <= alu_df;
		end
	end
endmodule