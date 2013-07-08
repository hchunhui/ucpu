/****************************************************************
  *
  *	  Copyright (C) 2005 of USTC, All Rights Reserved
  *
  *	  No part of the software may be reproduced or transmitted in any form or 
  *	  by any means, electronic or mechanical, for any purpose, without express  
  *	  written permission of Hardware Center of USTC. It is against the law to   
  *	  copy the software. No part of this program may be reproduced or transmitted   
  *	  in any form or by any means, electronic or mechanical, including photocopying,  
  *	  recording, or information storage and retrieval systems, for any purpose  
  *	  other than the purchaser's personal use, without the express written  
  *	  permission of Hardware Center of USTC.
  *
  *	  PURPOSE:
  *     1.本通用下载模板仅使用于在USB_CPU及其系统结构开发平台板上的芯片 EP1C12Q240C8
  *     2.引脚分配是相应的ep1c12.qsf
  *     3.不同类型的CPU,涉及对控制接口芯片EPM3512逻辑修改,见epm3512.v 
  *	
  ****************************************************************/
/*****************************************************************	  
  *  $Author: Wang Heng cai of USTC $
  *  $Revision: 2.0 $
  *
  *	  MODIFICATION HISTORY:
  *
  *  $Log: ep1c12.v,v $
  *  Revision 2.0  2009/3/4 
  *  Debugged and Tested.
  *  Compiled with Quartus 4.1-6.0 SJ.
  *  Downloaded to EP1C12.
  *
  *  
  *
  *  Revision       2008/2/  
  *     
  ****************************************************************/ 
  
  //================================================================================================
  // assignment list of track and callback address space for information of CPU
  // 跟踪回收CPU内部运行信息的空间地址分配表，
  // 注：信息内容与地址对应关系，用户可定义，但Debug 仍显示的原信息名，用户心里要清楚
  // USB_8051 space: 0x6c00-0x6fff:  0x6c00 + Addr[7:0]
  // Addr[7:0]	function							name 										
  // 0x00 		Internal address bus				i_a[7:0] 				
  // 0x01 		Internal address bus				i_a[15:8] 											
  // 0x02 		Internal address bus				i_a[23:16]   										
  // 0x03		Reserved								-										
  // 0x04		Internal data bus					i_d[7:0]										
  // 0x05		Internal data bus					i_d[15:8]										
  // 0x06		Internal data bus					i_d[23:16]												
  // 0x07		Internal data bus					i_d[31:24]								
  // 0x08		accumulator 						acc[7:0]										
  // 0x09		accumulator							acc[15:8]										
  // 0x0a		accumulator							acc[23:16]												
  // 0x0b		accumulator							acc[31:24]									
  // 0x0c		temp accumulator 					act[7:0]										
  // 0x0d		temp accumulator					act[15:8]										
  // 0x0e		temp accumulator					act[23:16]												
  // 0x0f		temp accumulator					act[31:24]				
  // 0x10 		temp register						temp[7:0] 				
  // 0x11 		temp register						temp[15:8] 											
  // 0x12 		temp register						temp[23:16]   										
  // 0x13		temp register						temp[31:24]  			
  // 0x14		register out A						ro_a[7:0]										
  // 0x15		register out A						ro_a[15:8]										
  // 0x16		register out A						ro_a[23:16]												
  // 0x17		register out A						ro_a[31:24]								  
  // 0x18		register out B						ro_b[7:0]										
  // 0x19		register out B						ro_b[15:8]										
  // 0x1a		register out B						ro_b[23:16]												
  // 0x1b		register out B						ro_b[31:24]		
  // 0x1c		ALU out			 					alu_f[7:0]										
  // 0x1d		ALU out								alu_f[15:8]										
  // 0x1e		ALU out								alu_f[23:16]												
  // 0x1f		ALU out								alu_f[31:24]				  
  // 0x20		register user A						r_usera[7:0]										
  // 0x21		register user A						r_usera[15:8]										
  // 0x22		register user A						r_usera[23:16]												
  // 0x23		register user A						r_usera[31:24]								  
  // 0x24		register user B						r_userb[7:0]										
  // 0x25		register user B						r_userb[15:8]										
  // 0x26		register user B						r_userb[23:16]												
  // 0x27		register user B						r_userb[31:24]			
  // 0x28		Status register						status[7:0]	     即标志寄存器(CF,OF,Z,S...) 用户自定义各位信号									
  // 0x29		Status register						status[15:8]         ..										
  // 0x2a		Reserved								-										
  // 0x2b		Reserved								-
  // 0x2c		Instruction register				IR[7:0]										
  // 0x2d		Instruction register				IR[15:8]															
  // 0x2e		Instruction register				IR[23:16]														
  // 0x2f		Instruction register				IR[31:24]			
  // 0x30		Program Counter						PC[7:0]										
  // 0x31		Program Counter						PC[15:8]															
  // 0x32		Program Counter						PC[23:16]														
  // 0x33		Breakpoint register					BKR[7:0]										
  // 0x34		Breakpoint register					BKR[15:8]															
  // 0x35		Breakpoint register					BKR[23:16]														
  // 0x36		Stack Pointer						SP[7:0]										
  // 0x37		Stack Pointer						SP[15:8]				
  // 0x38		Stack Pointer register				SP_R[7:0]										
  // 0x39		Stack Pointer register				SP_R[15:8]										
  // 0x3a		Stack Pointer register				SP_R[23:16]												
  // 0x3b		Stack Pointer register				SP_R[31:24]			
  // 0x3c		Base Address register				BASE_A[7:0]										
  // 0x3d		Base Address register				BASE_A[15:8]										
  // 0x3e		Base Address register				BASE_A[23:16]												
  // 0x3f		Reserverd									-			
  // 0x40		Indirect Address register			AR[7:0]										
  // 0x41		Indirect Address register			AR[15:8]										
  // 0x42		Indirect Address register			AR[23:16]												
  // 0x43		Indirect Address register			AR[31:24]				
  // 0x44		Clock out(User defined)				clki[7:0]	 见*1									
  // 0x45		Clock out(User defined)				clki[15:8]		
  // 0x46		Control Signals(User defined)		ctrli[7:0]	 见*2									
  // 0x47		Control Signals(User defined)		ctrli[15:8]		
  // 0x48		Micro Program Counter				uPC[7:0]										
  // 0x49		Micro Program Counter				uPC[15:8]										
  // 0x4a		Micro Program Counter				uPC[23:16]												
  // 0x4b		Micro Program Counter				uPC[31:24]			  
  // 0x4c		Micro Instruction register			uIR[7:0]										
  // 0x4d		Micro Instruction register			uIR[15:8]															
  // 0x4e		Micro Instruction register			uIR[23:16]														
  // 0x4f		Micro Instruction register			uIR[31:24]			  
  // 0x50		Micro Program Entry Address			uPC_in[7:0]														
  // 0x51		Micro Program Entry Address			uPC_in[15:8]		
  // 0x52		Micro Program Jump Address			uJMP[7:0]														
  // 0x53		Micro Program Jump Address			uJMP[15:8]		  	    
  // 0x54		Timing out(User defined)			TSi[7:0]										
  // 0x55		Timing out(User defined)			TSi[15:8]		  				
  // 0x56		Timing out(User defined)			TSi[23:16]										
  // 0x57		Timing out(User defined)			TSi[31:24]
  // 0x58		Reserverd								-			
  // 0x59		Reserverd								-			
  // 0x5a		Reserverd								-			
  // 0x5b		Reserverd								-			
  // 0x5c		Reserverd								-			
  // 0x5d		Reserverd								-			
  // 0x5e		Reserverd								-			
  // 0x5f		Reserverd								-			
  // 0x60		Pipeline Control Signals			PL_Ctrl[7:0]			
  // 0x61		Pipeline Control Signals			PL_Ctrl[15:8]			
  // 0x62		Pipeline Control Signals			PL_Ctrl[23:16]			
  // 0x63		Pipeline Control Signals			PL_Ctrl[31:24]
  // 0x64		Pipeline Data 1						PL_D1[7:0]			
  // 0x65		Pipeline Data 1						PL_D1[15:8]			
  // 0x66		Pipeline Data 1						PL_D1[23:16]			
  // 0x67		Pipeline Data 1						PL_D1[31:24]  			
  // 0x68		Pipeline Data 2						PL_D2[7:0]			
  // 0x69		Pipeline Data 2						PL_D2[15:8]			
  // 0x6a		Pipeline Data 2						PL_D2[23:16]			
  // 0x6b		Pipeline Data 2						PL_D3[31:24]  			
  // 0x6c		Pipeline Data 3						PL_D3[7:0]			
  // 0x6d		Pipeline Data 3						PL_D3[15:8]			
  // 0x6e		Pipeline Data 3						PL_D3[23:16]			
  // 0x6f		Pipeline Data 3						PL_D3[31:24]  	
  // 0x70		Interrupt Registers					INT[7:0]			
  // 0x71		Interrupt Registers					INT[15:8]			
  // 0x72		Interrupt Registers					INT[23:16]			
  // 0x73		Interrupt Registers					INT[31:24]  		
  // -			User Define
  //
  // *1  回收脉冲信号实际是回收该脉冲置"1"的回收触发器"1"端，
  //     回收操作完成后要用软复位4  W 0x6005 复位全部脉冲回收触发器，
  //     否则下次就不能反映真实情况，回收触发器要在回收逻辑中设计。
  //     用户自定义各位信号。
  // *2  控制信号回收包括存贮器和I/O读或写，字节控制，应答信号，各种内部、中间控制信号
  //     如通常的BE/CMD[3:0]等
  //     用户自定义各位信号。
  //
  // 在Face_CPLD EPM3512 模块 跟踪回收信息与空间：
  // USB_8051 space: 0x6800-0x6C00:  0x6800 + Addr[7:0] 
  // EPM3512内必须设计对该空间的相应的跟踪回收逻辑----USB_8051读逻辑 
  // 0x00-0x03  MD[31:0]   外部主存数据     (可用0x8000-0x8003 读 可省点逻辑)
  // 0x04-0x06  MA[23:0]   外部主存地址
  // 0x07       CS[8:1]    外部主存片选
  // 0x08       Flash状态  外部Flash  D[7:0]={,,,CS,RYBY,RST,W,R}
  // 0x09       命令总线   外部       D[7:0]={BE[3:0],MW,ME,IOW,IOR}
  // 0x0a       T[7:0]     CPU来周期
  // 0x0b       S[7:0]     CPU来周期内状态
  // 0x0C       运行状态   D[1:0]={PAUSE,RUN}   
  //================================================================================================  

module ep1c12 ( 
				_WR,WR,_RD,_CS,OE,INT5,_D,_A,         // USB_8051
				_0x6,_0xd,RUN,S_INT,S_RST,GCLK,CLK,   // EPM3512 Interface CPLD
				STOP,CK,END_I,T,C_BE,A_31,A_30,ALE,   // ..     
				EN_A,C_A,SET_CP,PC_BKT,               // ..
				MD,A_,                                //Memory
				IRQ,C_R,BUS_CLK,D_DIR,                //CPU_CTRL/IO_CPLD
				F_CLK,OCLK,OSC_CLK,mode,RESET,NMI     //Miscellaneous
                 );
                 
//Begin of pin definition -------------------------------------------------------------------------------------------------------------------------------

// Signals for usb_8051 (68013A)
input _WR;      //write order, use to Level,  _WR=WR
input  WR;      //write order, clock pin of chip, 0 active
input _RD;      //read strobe, 0 active
input _CS;      //chip select, 0 active
input  OE;      //enable read, 0 active
output INT5;    //interrup,Should be output,1 active
inout[7:0] _D;  //data bus
input[11:0] _A; //address bus

// Signals for Interface CPLD epm3512
input _0x6;   //usb_8051 space_decode: setup and callback
input _0xd;   //usb_8051 space_decode: W/R RAM of chip
input RUN;    //RUN=1(have clock), CPU run 
input S_INT;  //soft interrupt of debug
input S_RST;  //soft reset of debug
input GCLK;   //clock pin of chip, source clock1 of CPU 
input CLK;    //CLK=GCLK, use to combination
output STOP;  //instruction of stop of CPU
output CK;    //clock in CPU_instruction_cycle 
output END_I; // per instruction end of CPU
output[3:0] T;    //cycle of instruction of CPU,can change
output[3:0] C_BE; //command(read,write,...) or byte enable of CPU, to outside memory
output A_31;  //highest    address of space of current CPU         
output A_30;  //(highest-1)  ..
output ALE;   //latch of CPU_addres when D/A multiplex(MD)
output EN_A;  //enable addres of CPU goto memory,
              //manual select: MD's latch_registers(373) output MA or A_ via 3245 to MA
input  SET_CP;    //pulse: Debug setup start_first address of program when RUN=0 
output PC_BKT;    //breakpoint of CPU's program counters
inout[7:0] C_A;   //other command/request/acknowledge of CPU (backup)

//Signals for Memory;
inout [31:0] MD;  //multiplex data/address of CPU，to outside memory
inout [23:0] A_;  //address of CPU (no multiplex), to outside memory
                  //inout'S "in" for setup start_first_address with debug
//Signals for IO_CPLD
input[4:1] IRQ;   //interrupt request for CPU
inout[11:0] C_R;  //other command/request/acknowledge of CPU (backup)
output BUS_CLK;   //bus clock of CPU
output D_DIR;     //data_direction of CPU (no use bus switch 3245) 

//Miscellaneous
input F_CLK;   //clock pin of chip,source clock3 of CPU, viz usb_8051 clkout 
               // or sampling clock of QuartusII SignalTap II Logic Analyzer 
input OCLK;    //clock pin of chip,source clock2 of CPU
input OSC_CLK; //OSC_CLK = OCLK, use to combination
input mode;    //mode select of CPU
input RESET;   //switch reset
input NMI;     //No_Mask_interrupt of CPU

//End of pin definition -------------------------------------------------------------------------------------------------------------------------------                       
        
//Begin of Logic --------------------------------------------------------------------------------------------------------------------------------------                       

wire rst = S_RST  /*| RESET*/;  //all Reset  

//==============================================================================
//调用  mycpu(CPU core)   ******************************************************
//不同的CPU core，其形参是不同的，调用时按具体的CPU core，进行增删
 
//用内部中间变量作实参的代入的声明: 
//注意：这种内部中间变量，最终必须赋给实体或被实体赋值，否则可能通过编译，但平台测试失败。

//wire [7:0]  od;    //CPU写出数据,使用EP1C12的嵌入 SRAM 作主存的data
//wire [7:0]  o_d;   //CPU读入数据,   ..                       的q
//wire [10:0] o_a;   //地址,     ..                       的address

//wire [10:0] oa;    //debug setup first address of program when o_a is output for mycpu
                     //注意：使用EP1C12的嵌入 SRAM 作主存时, mycpu 内的地址输出输入必须分开。

wire        ck;          //clock in cycle
wire [2:0]  t;           //周期
wire [10:0] pc;          //程序计数器
wire [15:0] i_reg;       //指令寄存器
wire [7:0]  r0,r1,r2,r3; //4个累加器/寄存器

wire        write,read,cy,z; //写 读 进位 结果为0
wire aa;

//wire [7:0]  uA;  //微程序存贮器rom的地址
//wire [23:0] ud;  //微程序控制的微存读出数据
//wire [7:0]  upc; //微程序计数器
//wire [23:0] ui   //微指令寄存器
wire [10:0] o_a;

ucpu mycpu(
	.rstn(~rst),
	.clk(CLK),
	.ram_wc(write),
	.ram_rc(read),
	.o_d(MD[7:0]),
	.o_a(o_a[7:0]),
	.alu_ir(i_reg),
	.pc(pc),
	.a0(r0),
	.a1(r1),
	.a2(r2),
	.a3(r3),
	.alu_f({aa, cy, z}));
/*
wire [10:0] o_a;
cpu12_ac4t mycpu (  //自定义16条,组合逻辑控制,4累加器,多分频变周期时序,当前使用外部主存,
                    //Debug 设置程序启动首地址
                  .reset(rst),     //总复位
                  .clk(CLK),       //CLK可用OCLK 或 F_CLK
                  .we(write),      //see correlative 1,8  --写脉冲 we=wc & ck in cpu12_ac4t
                  .rc(read),       //  ..

                  .o_d(MD[7:0]),   //see correlative 2,8  --inout 使用外部主存打开，否则注销
                  //.o_d(o_d),       // ,,                  --(to my_cpu)  CPU读数据,使用嵌入SRAM打开，否则注销
                  //.od(od),         // ,,                  --(from my_cpu)CPU写数据,使用嵌入SRAM打开，否则注销

                  .o_a(o_a),       //see correlative 3    --input, from mycpu 送主存地址(外部 或 内部嵌入SRAM)
                  .oa(A_[10:0]),   //                     --output to mycpu. 需要Debug设置程序启动首地址时，打开，可用_A[10:0]代入, 由复位设置则注销
                                         
                  .run(RUN),       //see correlative 4      --RUN=0。Debug设置程序启动首地的允许     
                  .pc_cp(SET_CP),  //  ..                   --Debug设置程序启动首地的脉冲
                  ._ck(ck),        //see correlative 5      --CPU 工作时钟,是CLK分频或在单倍时钟时即CLK
                  ._t(t),          //see correlative 6,8    --CPU 操作周期
                  //.i_end(END_I),   //see correlative 6      --1条指令的结束周期信号, 如my_cpu 未送出 i_end, 则注销
                  .i_reg(i_reg),   //  ..                   --指令寄存器
                  .pc(pc),         //see correlative 7,8    --程序计数器
                  .r0(r0),         //see correlative 8      --4个累加器/寄存器
                  .r1(r1),         //  ..
                  .r2(r2),         //  ..
                  .r3(r3),         //  ..
                  .cy(cy),         //  ..                   --加法器进位 
                  .z(z)            //  ..                   --判结果为0
                       );

*/
//模板的其它信号输入输出信号处理：see correlative 9

/*****************************************************************************************************
   调用实例  my_cpu----cpu_core 参数等说明: 
 
一 形参实参端口用" .形参(实参) "表示，其数目取决my_cpu的输入输出端口数，调入时要根据目标my_cpu进行增删,
   1)下载调试中,如果查错需要增加跟踪回收的信息,必须在my_cpu目标文件中增加相应的仿真观察信号,
     在本文调入处增加相应的端口.
   2)形参名和实参名可同名，但不可混.  代入时注意: 形参和实参的性质和宽度的一致性
   3)实参的代入：实参代入相应端口( )内，性质和宽度要一致
     a)与本文的输入输出信号性质一致对应的形参:
       可直接用本文的输入输出双向信号作实参代入（）,如 .clk(CLK)的CLK，
       如果不便直接用本文件出入端口信号代入, 可使用内部中间变量,如 .we(write)的write,
           这些信号往往需要组合或分类或转接,   注: 这里的组合是泛指,也可能是时序逻辑或3态门等.
       注意：这种情况最终要把内部中间变量或组合赋给本文的输出信号
                 或将本文的输入信号赋或组合给内部中间变量
             否则错误将被隐藏到编译后的warning内，出现许多非设计要求的warning：Primitive 'xxx'stuck at GND.
     b)必须用内部中间变量信息的跟踪回收的信息 如.r0(r0)的r0
   4)凡实参使用内部中间变量的代入（），必须在调用实例CPU段前声明，
       注意：信号的性质和宽度的一致性,
   5)对与本文的输入、输出、双向信号对应的性质一致的形参,
     如果本文的输入、输出、双向信号的宽度大于形参宽度,其多出的高位必须作:
         input-----自动忽略处理
         output----作无效处理
         inout-----作高阻(3态)处理或不用的高位地址在RUN=1作"0"处理
     见 correlative 1-8

二 使用EPIC12的嵌入 SRAM(或内部逻辑) 作主存时，见后面相关和相应段的说明与描述  ----不推荐  

三 使用EPIC12的嵌入 rom 作微程序控制的微存: 
   a 请打开微程序用的中间变量声明和代入端口,
     若微存设计在CPU_Core的实例中,则跟踪回收宜选用upc,uir
   b 见 MICROPROGRAM_ROM_Ctrl段,按要求作打开或注销相应的逻辑描述语句段
 


********************************************************************************************/

// correlative（相关） 1:   ========================================================
// 读写命令与字节允许BUS 到 Face_CPLD EPM3512 
// 以下存贮器读写组合输出仅适宜本系统自定义指令CPU 或8086/88 或8051
//     其它类型的CPU，要根据CPU的命令BUS定义赋值C_BE[3:0],可能使用到备份信号C_A[].
 
assign C_BE[2]= !(write & RUN);  //write command_pulse 
assign C_BE[3]= !(read & RUN) ;  //read command

assign C_BE[1:0]=2'b00;          //不用的高位处理为无效

//assign C_BE[3:0]=4'b0000;      //使用EP1C12的嵌入 SRAM 作主存,write 和 read command，不输出


// correlative 2:   =======================================================
// 数据总线 MD
// 到外部主存的数据总线 MD 不用或不用的高位处理,请打开需要的逻辑语句,注销其它

assign MD[31:8] = (1'b0)? 24'h000000 : 24'hzzzzzz;  //现实例仅用MD[7:0] 
//assign MD[31:16]= (1'b0)? 16'h0000 : 16'hzzzz;    //实例仅用MD[15:0]
 
//assign MD[31:0] = (1'b0)? 32'h00000000 : 24'hzzzzzzzz; //使用EP1C12的嵌入 SRAM 作主存，MD不用置高阻


/* correlative 3:   =======================================================
   到外部主存的地址总线通道选择(MA / A_)及其不用的高位地址位处理 
     到外部主存的地址总线有2路--根据CPU输出总线类型选择:		
   1)专用地址,即直接通过A_[23:0]经3个8位双向3态缓冲3245到MA,或MA到A_[23:0]--用于Debug设置程序启动首地址.
   2)数据地址复用时,MD经3个8位锁存器74373输出为MA,其锁存信号是ALE.
   3)允许EN_A(EN_MA)经JP_A的6个跳针EN_MA5-0分别控制3个3态缓冲3245允许和3个锁存器74373输出允许.
     通常3个3态缓冲3245允许的跳针连接,保证Debug设置程序启动首地址所需要的地址输入，
         在使用外部主存、CPU运行即RUN=1时，A_[23:0]不用的地址高位，作输出"0"处理：
         ----按当前要用的地址位数及其需通道修改下面逻辑语句: Note 3-1, 或注销它,打开Note 3-2
     而3个锁存器74373输出MA允许根据设计要求即地址数据复用位的范围连接:
         ----按设计要求的位连接MA2-0跳针，现实例不连
     注意：有的CPU输出总线类型是交叉型的，即部分地址(通常低位)是和数据复用,而另部分(通常高位)是专用直接地址.
           如51系列,8086/88. 
   4)使用EP1C12的嵌入 SRAM 作主存，MA / A_ 均置高阻。见 correlative 9
*/ 
assign A_[10:0] = (RUN)? o_a : 11'bzzzzzzzzzzz;  //现实例仅直接用A_[10:0]
assign A_[23:11]= (RUN)? 13'b0000000000000 : 13'bzzzzzzzzzzzzz;  //Note 3-1,，A_[23:11]:RUN=0 置高阻; =1,置"0"

//assign A_[23:0] = (1'b0)? 24'h000000 : 24'hzzzzzz;  //Note 3-2 使用EP1C12的嵌入 SRAM 作主存 或 地址全部是MD的复用时，
                                                      //         A_[23:0]置高阻

// correlative 4:   =======================================================
// 程序启动首地址的设置方法选择：CPU逻辑由异步复位直接设置 或 Debug设置
// 如果知道测试程序启动首地址，并已在my_cpu(cpu_core)内，用异步复位设置到pc即pc_o <= 12'h00e;
//     则 注销调子3个参数端口: .run(RUN),.pc_cp(SET_CP), .oa(A_[10:0]，
// 否则，保持调子3个参数端口，my_cpu(cpu_core)内，增加 if (~run) pc_o <= o_a[10:0];

// correlative 5: ======================================================
// CPU工作时钟返回到Face_CPLD EPM3512, 以控制单步、单指、断点操作
// 如果CPU设计为单倍时钟（时钟源一次分频即周期,不再进行再次分频)
//     请注销调用参数端口._ck(ck)与Note 5-1逻辑语句, 打开Note 5-2-1或 5-2-2逻辑语句  
//assign CK=ck;     //Note 5-1
assign CK=CLK;    //Note 5-2-1   
//assign CK=!CLK;   //Note 5-2-2  

// correlative 6: ======================================================
//2选1的 打开 或 注销 1)段 组合逻辑控制 或 2)段  微程序控制  的逻辑语句
// A) CPU周期返回到Face_CPLD EPM3512
//1)组合逻辑控制:
assign T=t;     //T[0]输出点指示灯

// B) CPU的任一条指令执行结束信号返回到Face_CPLD EPM3512,控制暂停
//指令执行结束信号 END_I = my_cpu 的每条指令(不同操作码) & 该指令的结束周期
//如my_cpu 未送出 i_end,  则按 my_cpu的具体要求作如下面描述 Note 6-1,2 ,或打开Note 6-3

wire   i_2cyc = !i_reg[15] | (i_reg[15:13]==3'b111); //Note 6-1 仅适合当前实例
assign END_I  = i_2cyc & t[1] | !i_2cyc & t[2];      //Note 6-2 ..

//assign END_I = t[max];  //Note 6-3 固定周期操作的CPU,请注销上面 2句逻辑

//2)微程序控制: 设每条指令的微程序运行结束标志(某位微码)是uI[n]

//assign T[0] = ui[n];  //uI[n]=1 有效, 每条指令的微程序运行结束标志作点灯指示
//assign T[3:1]=0;
//assign END_I= ui[n];

// C)停机指令信号输出到Face_CPLD EPM3512,控制暂停
assign STOP = 0;  //未设计停机指令 =0, 否则 = (指令操作码==停机指令操作码);


// correlative 7: ======================================================
//brekpoint logic 如需要断点操作**************************************
// 断点信号输出到Face_CPLD EPM3512,控制暂停           
// 如果my_CPU自身没有断点设置功能, 则
//需要,增加逻辑描述段如下,  并 注销 Note 7-1 ;  如不需要断点操作,则打开 Note 7-1,注销下段
//brekpoint registers of USB_8051 address space Ox6401/2/3
//当前只使用16位,设计者可据设计要求类似的增加
 //*
wire en_bp_r = !_CS & _0x6 & (_A[11:10] == 2'b01) & (_A[3:2]==3'b00);   
wire en_bp_r0= en_bp_r & !_A[1] & !_A[0]; 
wire en_bp_r1= en_bp_r & !_A[1] &  _A[0];
reg[7:0] bp_r0;
reg[7:0] bp_r1;

reg PC_BKT;
always @(posedge WR or posedge rst )
  begin
    if (rst)
      begin
      bp_r0 <=0;
      bp_r1 <=0;
      end
    else if (en_bp_r0)   bp_r0 <= _D;
    else if (en_bp_r0)   bp_r1 <= _D;  
  end
  
 always @(bp_r0 or bp_r1 or pc)
   begin
	 if ({bp_r1,bp_r0}=={5'b00000,pc})
	    PC_BKT <=1;
	 else 
	    PC_BKT <=0;
   end
// */
//assign PC_BKT=0;  //Note 7-1 不用断点,请打开本句,注销上面断点逻辑描述段


// correlative 8: ======================================================
// 跟踪回收 my_CPU的内部信息 
//track and callback space: USB_8051:0x6c00-0x6fff (Read Only)
//NOTE: Should not use (_A[11:8] == 4'b11xx ) as an condition 
//                           in Quartus, it is always false.   
wire en_callback = !_CS & _0x6 && (_A[11:10] == 2'b11) && !_RD; //6Cxx H

// 跟踪回收脉冲 write 的示例************************************
// 跟踪回收时 Debug W 0x6005 产生 clr, 清全部脉冲回收触发器
wire clr= !_CS & _0x6 && (_A[11:0] == 12'h005) && !_WR;    
reg wc;   //写脉冲的回收触发器 
always @(posedge write or posedge clr )  //pulse =>level for callback
begin
  if (clr)
     wc <= 1'b0; 
  else 
     wc <= 1'b1;              
end

//跟踪回收的信息正好是模板仿真时的入出信息，包括为牢靠固定地观察内部信息而使其输出信息。
//跟踪回收CPU内部运行信息的空间地址分配表 见 文件头
//   新增的跟踪回收信息在下面 <信息跟踪回收>逻辑段添加
reg[7:0] fbd;  //
always @(_A[7:0] or MD[7:0] or A_           //or o_d or od or o_a   
             or r0 or r1 or r2 or r3
             or PC_BKT or cy or z or t or wc or read 
             or i_reg or pc or bp_r0 or bp_r1 )
             
  //根据最前面的 assignment list 的说明和 my_cpu的具体情况
  //    在相应的地址单元将相应的信息赋给内部中间变量 fbd;
  //本段仅对当前实例,使用外部主存, 若改变实例或嵌入(embedded) SRAM 作主存必须修改
  begin  
    case (_A[7:0])                      //******对应Debug窗口的信息名************
	  8'h00: fbd <= A_[7:0];                  //内部地址总线IAB[7:0]    使用外部主存时  
	  //8'h00: fbd <= o_a[7:0];                 //内部地址总线IAB[7:0]    嵌入(embedded) SRAM 作主存
	  8'h01: fbd <= {5'b00000,A_[10:8]};      //内部地址总线IAB[15:8]   使用外部主存时
	  //8'h01: fbd <= {5'b00000,o_a[10:8]};     //内部地址总线IAB[7:0]    嵌入(embedded) SRAM 作主存
	  8'h04: fbd <= MD[7:0];                  //内部地址总线IDB[7:0]    使用外部主存时
	  //8'h04: fbd <= o_d[7:0];                 //内部地址总线IDB[7:0]    CPU 读 嵌入(embedded) SRAM 主存
	  //8'h06 fbd <= od[7:0];                  //内部地址总线IDB[7:0]    CPU 写 嵌入(embedded) SRAM 主存   
	  8'h08: fbd <= r0;                       //累加器A
	  8'h0C: fbd <= r1;                       //累加暂存器ATC
	  8'h10: fbd <= r2;                       //寄存器A
	  8'h14: fbd <= r3;                       //寄存器B
	  8'h28: fbd <= {PC_BKT,cy,z,t,wc,read};  //状态寄存器status ,嵌入(embedded) SRAM 主存时 wc改write   
	  8'h2c: fbd <= i_reg[7:0];               //指令寄存器IR[7:0]
	  8'h2d: fbd <= i_reg[15:8];              //指令寄存器IR[15:9]
	  8'h30: fbd <= pc[7:0];                  //程序计数器PC[7:0]
	  8'h31: fbd <= {5'b00000,pc[10:8]};       //程序计数器PC[15:8]
	  8'h33: fbd <= bp_r0;                    //断点寄存器BPR[7:0]
	  8'h34: fbd <= bp_r1;                    //断点寄存器BPR[15:8]
	  default : 
	        fbd = 0;	
    endcase	
  end 
 
//使用外部主存时，请打开下句，embedded SRAM 作主存时，则注销
 assign _D = (en_callback) ? fbd : 8'hzz;  // to USB_8051, 

// correlative 8: ======================================================

 assign A_31=A_[10]; //Amax, chip of memory,  A_[10]=1,IO_communication for current cpu12, 

//本实例不用的部分output作无效处理*******************************
assign ALE=0;
assign BUS_CLK=0;
assign D_DIR=0;
assign A_30=0;
assign EN_A=0;      //本实例不用复用地址
assign INT5 = 1'b1; //(not INT5) 

//备用的output or inout信号处理***********************************
//不用的部分inout总线控制类信号呈高阻处理，禁止打开3态缓冲

assign C_A[7:0] = (1'b0)? 8'b0 : 8'bz;
assign C_R[11:0]= (1'b0)? 12'b0 : 12'bz;

//correlative 9: ==============================================================================
/* EP1C12的嵌入(embedded) SRAM 或者 内部逻辑 作主存  ******************************************
*****************************************************************************************
(1)与之间接相关的逻辑描述修改:  **********************************
   A 打开前面使用嵌入SRAM作主存的声明与各逻辑语句，同时注销使用外部存贮器的各逻辑语句
     注意:使用 SRAM 作主存时, 不得影响上位主机访问外部存贮器,否则Debug将发生错误,因此
          本顶层访问外部存贮器的所有信号,必须作无效处理--输出赋无效电平,双向赋高阻. 
   B 对mycpu(CPU_Core)的实例设计的修改：
     1)CPU访问存贮器的数据o_d由双向inout 改为分开的读数据input o_d、写数据output od
     2)若CPU访问贮器的地址o_a也是双向inout,则改为output o_a访存,input oa为设置程序启动首地址
       若访问存贮器的地址o_a是output,为设置程序启动首地址,增加input oa
           若程序启动首地址已知道,则无须input oa
       并按需要作逻辑描述相应的增删.(本实例仅需打开或注销相应的逻辑描述语句) 
   C 若嵌入 SRAM 作主存已设计在CPU_Core的实例中, 返回访存的信息用于跟踪回收
   D 哈佛HV结构的程序和数据存贮器设计类同嵌入rom、SRAM, SRAM也可选用外部存贮器
         其逻辑描述可在本文,也可在CPU_Core的实例中,也可交叉放置。
         实例代入端口与参数、所需的跟踪回收、相关处理，据CPU_Core的实例设计、参考本文类似情况进行。
   E 注意:使用 SRAM 作主存时,上位主机读外部存贮器(8000H空间)查看运行结果方法已不可用,
          而改用上位主机读D000H空间即_0xd,见(3)

（2）embedded SRAM 描述逻辑要点 提示:      *******************************
   A)器件Cyclone(包括EP1C12)不可用lpm_ram_io：自动改为lpm_ram_dq，且只能是同步方式(异步不能初始化)
       使用lpm_ram_dq的输入同步方式，缺省参数项：输入数据、地址及WE寄存，要文件项，可初始化；
       使用lpm_rom   的输入同步方式，缺省参数项: 仅地址寄存，            要文件项，可初始化；
       这两种库的输入同步方式的时钟,可在inclock与outclock选择1种或都选(daul),允许与清0通常不选.
   B)输入方式同步访问embedded SRAM的时序要求:
     时序配合规则：inclock(or clock)上升前沿有效，写允许we(or wren)必须比inclock提前器件1级门时间到达
   C)embedded SRAM的两个访问源
     1)USB_8051访问：在CPU不运行时（RUN=0），USB_8051 在 0xDxxx 空间读写embedded SRAM
       读为了观察CPU的程序运行结果，写用来改程序或初始数据，
           其时序配合由USB_8051时序和同步时钟，同步时钟推荐 F_CLK即68013的CLKOUT。
     2)CPU访问：程序执行时（RUN=1），若CPU使用分频时钟时，同步时钟选CK；
                                     若CPU使用单倍时钟时，同步时钟选!CLK：
                同时 write 在my_cpu内 不要 & ck 或 & !CLK 
           
*/
//(3)inclock 同步embedded SRAM的2访问源的逻辑设计**************************************
// A USB_8051_0xDxxx access  SRAM******************************************************
 // 嵌入(embedded) SRAM 作主存，请打开本段================================================
 /*
  wire 	d0_code   = _0xd & (_A[11:8]==4'b0000);
  wire  en_rd_ram = !_CS & d0_code & !_RD ;
  wire  en_wr_ram = d0_code & !_WR;
 */

//嵌入(embedded) SRAM 作主存, 请打开本段================================================= 
/*      
  wire  u51_clk =!_CS & d0_code & (!_WR & F_CLK | !_RD );
 
// B 访问RAM的二选一：CPU or USB_8051
  wire [7:0] data    = RUN? od       : _D;  
  wire [7:0] address = RUN? o_a[7:0] : _A[7:0];     
  wire we            = RUN? write    : en_wr_ram;  
  wire inclock       = RUN? ck       : u51_clk;
 */
   
// C 选择直接调库ram 或 调用ram实例

  // 直接调库ram，请打开本段 ===================================================
/*
\lpm_ram_dq mm(.data(data),   
               .address(address), 
               .we(we),
               .inclock(inclock), //写数据、地址和we的输入寄存clock
               .q(o_d));
   defparam
        mm.LPM_WIDTH = 8,
		mm.LPM_WIDTHAD = 8,
		//mm.LPM_NUMWORDS = 256,
		mm.LPM_INDATA = "REGISTERED",
		mm.LPM_ADDRESS_CONTROL = "REGISTERED",
		mm.LPM_OUTDATA = "UNREGISTERED",
        mm.LPM_FILE = "cpu4_mm.mif",
        mm.LPM_TYPE = "LPM_RAM_DQ",
		mm.LPM_HINT = "UNUSED";
 
  */
 // 调用ram实例sram_mm mm(在同文件夹)，请打开本段 ===================================================
 /* 
 \sram_mm mm (.address(address),
	          .clock(inclock),
	          .data(data),     //
	          .wren(we),
	          .q(o_d));
 */
// 用内部逻辑即数据缓冲寄存器+多位多路固接高/低电平作存贮器，请打开本段===================
/* 本实例双字节加程序：42F0+5287=9477； 
always @(o_a)
begin
  if (rc==1)
    case (o_a)
	  //8'h00: o_d <=8'h00;   
	  //8'h01: o_d <=8'h00;   //data1    
	  //8'h02: o_d <=8'h0c;   //start first address: 000c H 
	  // 8'h03: o_d <=8'h00;
	  8'h04: o_d <=8'hf0;   //data0
	  8'h05: o_d <=8'h87;   //data1 
	  8'h06: o_d <=8'h42;   //data2
	  8'h07: o_d <=8'h51;   //data3 
	  8'h08: o_d <=d_a;     //result1 
	  8'h09: o_d <=d_b;     //result2 
	 // 8'h0a: o_d <=8'hff;   // 数据与代码分隔符 ffff H 
	 // 8'h0b: o_d <=8'hff;   
	  8'h0c: o_d <=8'h80;   //LD A0,data0 
	  8'h0d: o_d <=8'h04;   
	  8'h0e: o_d <=8'h88;   //LD A1,data1
	  8'h0f: o_d <=8'h05;   
	  8'h10: o_d <=8'h90;   //LD A2,data2
	  8'h11: o_d <=8'h06;       
	  8'h12: o_d <=8'h98;   //LD A3,data3
	  8'h13: o_d <=8'h07;   
	  8'h14: o_d <=8'h01;   //ADD A0,A1
	  8'h15: o_d <=8'ha0;   //ST A0,result1
	  8'h16: o_d <=8'h08;   
	  8'h17: o_d <=8'hc0;   //JC 1b
	  8'h18: o_d <=8'h1b;   
	  8'h19: o_d <=8'hd8;   //JMP 1e 
	  8'h1a: o_d <=8'h1e;
	  8'h1b: o_d <=8'he8;   //LDI A1,01
	  8'h1c: o_d <=8'h01;
	  8'h1d: o_d <=8'h11;   //ADD A2,A1
	  8'h1e: o_d <=8'h13;   //ADD A2,A3
	  8'h1f: o_d <=8'hA0;   //ST A2,result2
	  8'h20: o_d <=8'h09;
	  8'h21: o_d <=8'hd8;   // JMP 21
	  8'h22: o_d <=8'h21;
	
	default:
	         o_d <=0;
   endcase
  
  else 
    o_d <=0;
end

reg [7:0] d_a,d_b;
always @( posedge CLK )
begin
  if (write==1)     //write 在my_cpu内 不要 & ck 或 & !CLK 
    begin
      case (o_a)
	    2'h08: d_a <= od;
	    2'h09: d_b <= od; 
      endcase  
    end
end




*/

//使用EP1C12的embedded SRAM 或 内部逻辑 作主存，usb_8051读操作，请打开本段===============
/*
reg [7:0] U51_RD_D; 
always @(en_rd_ram or o_q or en_callback or fbd)   
  begin
	if (en_rd_ram)         U51_RD_D <= o_d;
	else if (en_callback)  U51_RD_D <= fbd;
	else                   U51_RD_D <= 8'h00;
  end

wire en_u51_rd = en_callback | en_rd_ram;

assign _D = (en_u51_rd) ? U51_RD_D : 8'hzz;
*/





//End of Logic ----------------------------------------------------------------------------------------  

endmodule

