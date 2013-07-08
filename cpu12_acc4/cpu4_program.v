//自定义4条单字节指令测试程序示例，非本实例的
always @(o_a)
begin
  if (rc==1)
    case (o_a)
	  8'h00: o_d <=8'h00;
	  8'h01: o_d <=8'h00;       
	  8'h02: o_d <=8'h0e;
	  8'h03: o_d <=8'h00;
	  8'h04: o_d <=8'hf0;
	  8'h05: o_d <=8'h87;
	  8'h06: o_d <=8'h42; 
	  8'h07: o_d <=8'h51;
	  8'h08: o_d <=8'h00;       
	  8'h09: o_d <=8'h01;
	  8'h0a: o_d <=  d_a;
	  8'h0b: o_d <=  d_b;
	  8'h0c: o_d <=8'hff;
	  8'h0d: o_d <=8'hff;
	  8'h0e: o_d <=8'h44;
	  8'h0f: o_d <=8'h05;
	  8'h10: o_d <=8'h8a;
	  8'h11: o_d <=8'h46;       
	  8'h12: o_d <=8'hd4;
	  8'h13: o_d <=8'h09;
	  8'h14: o_d <=8'h07;
	  8'h15: o_d <=8'h8b;
	  8'h16: o_d <=8'h08; 
	  8'h17: o_d <=8'hd7;
	default:
	         o_d <=0;
   endcase
  
  else 
    o_d <=0;
end

reg [7:0] d_a,d_b;
always @( posedge q[1] )
begin
  if (wc==1)
    begin
      case (o_a)
	    2'h0a: d_a <= acc;
	    2'h0b: d_b <= acc; 
      endcase  
    end
end
