module regfile_mem_ir(clk, rstn, asrc, bsrc, din_en, din, aout, bout, r_mar, r_mdr, r_mdrin, rc, ir, a0, a1, a2, a3, pc);
	input clk;
	input rstn;
	input [3:0]asrc;
	input [3:0]bsrc;
	input din_en;
	input [15:0]din;
	output [15:0]aout;
	output [15:0]bout;
	
	output [15:0]r_mar;
	output [15:0]r_mdr;
	input [15:0]r_mdrin;
	input rc;
	output [15:0]ir;
	reg [15:0]r[0:15];
	assign r_mar = r[11];
	assign r_mdr = r[10];
	
	//***look***
	output [7:0]a0;
	output [7:0]a1;
	output [7:0]a2;
	output [7:0]a3;
	output [15:0]pc;
	assign a0=r[0][7:0];
	assign a1=r[1][7:0];
	assign a2=r[2][7:0];
	assign a3=r[3][7:0];
	assign pc=r[8];
	//***look***
	
	wire [15:0]ir;
	wire [3:0]ir_asrc;
	wire [3:0]ir_bsrc;
	wire [9:0]ir_addr;
	wire [3:0]ir_op;
	
	reg [15:0]aout;
	reg [15:0]bout;
	
	assign ir = r[9];
	assign ir_op = {ir[15:13], ir[10]};
	assign ir_asrc = {2'b0, ir[12:11]};
	assign ir_bsrc = {2'b0, ir[9:8]};
	assign ir_addr = ir[9:0];
	
	always @(asrc or ir_asrc or ir_bsrc or ir_addr or ir_op)
	begin
		case(asrc)
		4: aout = r[ir_asrc];
		5: aout = r[ir_bsrc];
		6: aout = {6'b0, ir_addr};
		7: aout = {12'b0, ir_op};
		13: aout = {12'b0, ir_asrc};
		default: aout = r[asrc];
		endcase
	end
	
	always @(bsrc or ir_asrc or ir_bsrc or ir_addr or ir_op)
	begin
		case(bsrc)
		4: bout = r[ir_asrc];
		5: bout = r[ir_bsrc];
		6: bout = {6'b0, ir_addr};
		7: bout = {12'b0, ir_op};
		13: bout = {12'b0, ir_bsrc};
		default: bout = r[bsrc];
		endcase
	end
	
	always @(posedge clk or negedge rstn)
	begin
		if(!rstn)
		begin
			r[0] <= 0;
			r[1] <= 0;
			r[2] <= 0;
			r[3] <= 0;
			r[4] <= 0;
			r[5] <= 0;
			r[6] <= 0;
			r[7] <= 0;
			r[8] <= 0;
			r[9] <= 0;
			r[10] <= 0;
			r[11] <= 0;
			r[12] <= 0;
			r[13] <= 0;
			r[14] <= 0;
			r[15] <= 0;
		end
		else
		begin
			if(rc)
				r[10] <= r_mdrin;
			if(din_en)
			begin
				if(asrc == 4'd4)
					r[ir_asrc] <= din;
				else if(asrc == 4'd5)
					r[ir_bsrc] <= din;
				else
					r[asrc] <= din;
			end
		end
	end
endmodule

module alu(fop, a, b, d, df, f);
	input [2:0]fop;
	input [15:0]a;
	input [15:0]b;
	output [15:0]d;
	output [2:0]df;
	input [2:0]f;
	
	reg [15:0]d;
	reg [2:0]df;/* 0:Z 1:C 2:A0 */
	
	always @(fop or a or b or f)
	begin
		df = 3'b0;
		case(fop)
			3'b000: //ld
				d = b;
			3'b001: //add16
				{df[1], d} = a + b;
			3'b010: //nor
				d = ~(a|b);
			3'b011: //ldh
				d = b << 8;
			3'b100: //add8
				begin
					{df[1], d[7:0]} = a[7:0] + b[7:0];
					d[15:8] = 8'b0;
				end
			3'b101: //sub8
				begin
					{df[1], d[7:0]} = a[7:0] - b[7:0];
					d[15:8] = 8'b0;
				end
			3'b110: //shl
				d = b >> 1;
			3'b111: //rrc8
				begin
					d[6:0] = b[7:1];
					df[1] = b[0];
					d[7] = f[1];
					d[15:8] = b[15:8];
				end
			default:
				d = 0;
		endcase
		df[0] = (d == 0);
		df[2] = d[0];
	end
endmodule

module regalu(clk, rstn, fop, asrc, bsrc, imm8, d, alu_f, alu_df, r_mar, r_mdr, r_mdrin, rc, ir, a0, a1, a2, a3, pc);
	input clk, rstn;
	input [2:0]fop;
	input [3:0]asrc;
	input [3:0]bsrc;
	input [7:0]imm8;
	output [15:0]d;
	input [2:0]alu_f;
	output [2:0]alu_df;
	
	output [15:0]r_mar;
	output [15:0]r_mdr;
	input [15:0]r_mdrin;
	input rc;
	output [15:0]ir;
	
	//***look***
	output [7:0]a0;
	output [7:0]a1;
	output [7:0]a2;
	output [7:0]a3;
	output [15:0]pc;
	//***look***
	
	reg [15:0]a;
	reg [15:0]b;
	wire [15:0]d;
	wire [15:0]ra;
	wire [15:0]rb;
	wire [15:0]ir;
	
	//PORTA
	always @(asrc or imm8 or ra)
	begin
		if(asrc[3:0] == 4'b1111)
			a = {8'b0, imm8};
		else
			a = ra;
	end
	
	//PORTB
	always @(bsrc or imm8 or rb)
	begin
		if(bsrc == 4'b1111)
			b = {8'b0, imm8};
		else
			b = rb;
	end
	
	regfile_mem_ir regfile1(clk, rstn, asrc, bsrc, 1'b1, d, ra, rb, r_mar, r_mdr, r_mdrin, rc, ir, a0, a1, a2, a3, pc);
	alu alu1(fop, a, b, d, alu_df, alu_f);
endmodule