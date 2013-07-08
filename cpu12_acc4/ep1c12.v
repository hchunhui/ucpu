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
  *     1.��ͨ������ģ���ʹ������USB_CPU����ϵͳ�ṹ����ƽ̨���ϵ�оƬ EP1C12Q240C8
  *     2.���ŷ�������Ӧ��ep1c12.qsf
  *     3.��ͬ���͵�CPU,�漰�Կ��ƽӿ�оƬEPM3512�߼��޸�,��epm3512.v 
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
  // ���ٻ���CPU�ڲ�������Ϣ�Ŀռ��ַ�����
  // ע����Ϣ�������ַ��Ӧ��ϵ���û��ɶ��壬��Debug ����ʾ��ԭ��Ϣ�����û�����Ҫ���
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
  // 0x28		Status register						status[7:0]	     ����־�Ĵ���(CF,OF,Z,S...) �û��Զ����λ�ź�									
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
  // 0x44		Clock out(User defined)				clki[7:0]	 ��*1									
  // 0x45		Clock out(User defined)				clki[15:8]		
  // 0x46		Control Signals(User defined)		ctrli[7:0]	 ��*2									
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
  // *1  ���������ź�ʵ���ǻ��ո�������"1"�Ļ��մ�����"1"�ˣ�
  //     ���ղ�����ɺ�Ҫ����λ4  W 0x6005 ��λȫ��������մ�������
  //     �����´ξͲ��ܷ�ӳ��ʵ��������մ�����Ҫ�ڻ����߼�����ơ�
  //     �û��Զ����λ�źš�
  // *2  �����źŻ��հ�����������I/O����д���ֽڿ��ƣ�Ӧ���źţ������ڲ����м�����ź�
  //     ��ͨ����BE/CMD[3:0]��
  //     �û��Զ����λ�źš�
  //
  // ��Face_CPLD EPM3512 ģ�� ���ٻ�����Ϣ��ռ䣺
  // USB_8051 space: 0x6800-0x6C00:  0x6800 + Addr[7:0] 
  // EPM3512�ڱ�����ƶԸÿռ����Ӧ�ĸ��ٻ����߼�----USB_8051���߼� 
  // 0x00-0x03  MD[31:0]   �ⲿ��������     (����0x8000-0x8003 �� ��ʡ���߼�)
  // 0x04-0x06  MA[23:0]   �ⲿ�����ַ
  // 0x07       CS[8:1]    �ⲿ����Ƭѡ
  // 0x08       Flash״̬  �ⲿFlash  D[7:0]={,,,CS,RYBY,RST,W,R}
  // 0x09       ��������   �ⲿ       D[7:0]={BE[3:0],MW,ME,IOW,IOR}
  // 0x0a       T[7:0]     CPU������
  // 0x0b       S[7:0]     CPU��������״̬
  // 0x0C       ����״̬   D[1:0]={PAUSE,RUN}   
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
inout [31:0] MD;  //multiplex data/address of CPU��to outside memory
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
//����  mycpu(CPU core)   ******************************************************
//��ͬ��CPU core�����β��ǲ�ͬ�ģ�����ʱ�������CPU core��������ɾ
 
//���ڲ��м������ʵ�εĴ��������: 
//ע�⣺�����ڲ��м���������ձ��븳��ʵ���ʵ�帳ֵ���������ͨ�����룬��ƽ̨����ʧ�ܡ�

//wire [7:0]  od;    //CPUд������,ʹ��EP1C12��Ƕ�� SRAM �������data
//wire [7:0]  o_d;   //CPU��������,   ..                       ��q
//wire [10:0] o_a;   //��ַ,     ..                       ��address

//wire [10:0] oa;    //debug setup first address of program when o_a is output for mycpu
                     //ע�⣺ʹ��EP1C12��Ƕ�� SRAM ������ʱ, mycpu �ڵĵ�ַ����������ֿ���

wire        ck;          //clock in cycle
wire [2:0]  t;           //����
wire [10:0] pc;          //���������
wire [15:0] i_reg;       //ָ��Ĵ���
wire [7:0]  r0,r1,r2,r3; //4���ۼ���/�Ĵ���

wire        write,read,cy,z; //д �� ��λ ���Ϊ0
wire aa;

//wire [7:0]  uA;  //΢���������rom�ĵ�ַ
//wire [23:0] ud;  //΢������Ƶ�΢���������
//wire [7:0]  upc; //΢���������
//wire [23:0] ui   //΢ָ��Ĵ���
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
cpu12_ac4t mycpu (  //�Զ���16��,����߼�����,4�ۼ���,���Ƶ������ʱ��,��ǰʹ���ⲿ����,
                    //Debug ���ó��������׵�ַ
                  .reset(rst),     //�ܸ�λ
                  .clk(CLK),       //CLK����OCLK �� F_CLK
                  .we(write),      //see correlative 1,8  --д���� we=wc & ck in cpu12_ac4t
                  .rc(read),       //  ..

                  .o_d(MD[7:0]),   //see correlative 2,8  --inout ʹ���ⲿ����򿪣�����ע��
                  //.o_d(o_d),       // ,,                  --(to my_cpu)  CPU������,ʹ��Ƕ��SRAM�򿪣�����ע��
                  //.od(od),         // ,,                  --(from my_cpu)CPUд����,ʹ��Ƕ��SRAM�򿪣�����ע��

                  .o_a(o_a),       //see correlative 3    --input, from mycpu �������ַ(�ⲿ �� �ڲ�Ƕ��SRAM)
                  .oa(A_[10:0]),   //                     --output to mycpu. ��ҪDebug���ó��������׵�ַʱ���򿪣�����_A[10:0]����, �ɸ�λ������ע��
                                         
                  .run(RUN),       //see correlative 4      --RUN=0��Debug���ó��������׵ص�����     
                  .pc_cp(SET_CP),  //  ..                   --Debug���ó��������׵ص�����
                  ._ck(ck),        //see correlative 5      --CPU ����ʱ��,��CLK��Ƶ���ڵ���ʱ��ʱ��CLK
                  ._t(t),          //see correlative 6,8    --CPU ��������
                  //.i_end(END_I),   //see correlative 6      --1��ָ��Ľ��������ź�, ��my_cpu δ�ͳ� i_end, ��ע��
                  .i_reg(i_reg),   //  ..                   --ָ��Ĵ���
                  .pc(pc),         //see correlative 7,8    --���������
                  .r0(r0),         //see correlative 8      --4���ۼ���/�Ĵ���
                  .r1(r1),         //  ..
                  .r2(r2),         //  ..
                  .r3(r3),         //  ..
                  .cy(cy),         //  ..                   --�ӷ�����λ 
                  .z(z)            //  ..                   --�н��Ϊ0
                       );

*/
//ģ��������ź���������źŴ���see correlative 9

/*****************************************************************************************************
   ����ʵ��  my_cpu----cpu_core ������˵��: 
 
һ �β�ʵ�ζ˿���" .�β�(ʵ��) "��ʾ������Ŀȡ��my_cpu����������˿���������ʱҪ����Ŀ��my_cpu������ɾ,
   1)���ص�����,��������Ҫ���Ӹ��ٻ��յ���Ϣ,������my_cpuĿ���ļ���������Ӧ�ķ���۲��ź�,
     �ڱ��ĵ��봦������Ӧ�Ķ˿�.
   2)�β�����ʵ������ͬ���������ɻ�.  ����ʱע��: �βκ�ʵ�ε����ʺͿ�ȵ�һ����
   3)ʵ�εĴ��룺ʵ�δ�����Ӧ�˿�( )�ڣ����ʺͿ��Ҫһ��
     a)�뱾�ĵ���������ź�����һ�¶�Ӧ���β�:
       ��ֱ���ñ��ĵ��������˫���ź���ʵ�δ��루��,�� .clk(CLK)��CLK��
       �������ֱ���ñ��ļ�����˿��źŴ���, ��ʹ���ڲ��м����,�� .we(write)��write,
           ��Щ�ź�������Ҫ��ϻ�����ת��,   ע: ���������Ƿ�ָ,Ҳ������ʱ���߼���3̬�ŵ�.
       ע�⣺�����������Ҫ���ڲ��м��������ϸ������ĵ�����ź�
                 �򽫱��ĵ������źŸ�����ϸ��ڲ��м����
             ������󽫱����ص�������warning�ڣ������������Ҫ���warning��Primitive 'xxx'stuck at GND.
     b)�������ڲ��м������Ϣ�ĸ��ٻ��յ���Ϣ ��.r0(r0)��r0
   4)��ʵ��ʹ���ڲ��м�����Ĵ��루���������ڵ���ʵ��CPU��ǰ������
       ע�⣺�źŵ����ʺͿ�ȵ�һ����,
   5)���뱾�ĵ����롢�����˫���źŶ�Ӧ������һ�µ��β�,
     ������ĵ����롢�����˫���źŵĿ�ȴ����βο��,�����ĸ�λ������:
         input-----�Զ����Դ���
         output----����Ч����
         inout-----������(3̬)������õĸ�λ��ַ��RUN=1��"0"����
     �� correlative 1-8

�� ʹ��EPIC12��Ƕ�� SRAM(���ڲ��߼�) ������ʱ����������غ���Ӧ�ε�˵��������  ----���Ƽ�  

�� ʹ��EPIC12��Ƕ�� rom ��΢������Ƶ�΢��: 
   a ���΢�����õ��м���������ʹ���˿�,
     ��΢�������CPU_Core��ʵ����,����ٻ�����ѡ��upc,uir
   b �� MICROPROGRAM_ROM_Ctrl��,��Ҫ�����򿪻�ע����Ӧ���߼���������
 


********************************************************************************************/

// correlative����أ� 1:   ========================================================
// ��д�������ֽ�����BUS �� Face_CPLD EPM3512 
// ���´�������д�����������˱�ϵͳ�Զ���ָ��CPU ��8086/88 ��8051
//     �������͵�CPU��Ҫ����CPU������BUS���帳ֵC_BE[3:0],����ʹ�õ������ź�C_A[].�_
 
assign C_BE[2]= !(write & RUN);  //write command_pulse 
assign C_BE[3]= !(read & RUN) ;  //read command

assign C_BE[1:0]=2'b00;          //���õĸ�λ����Ϊ��Ч

//assign C_BE[3:0]=4'b0000;      //ʹ��EP1C12��Ƕ�� SRAM ������,write �� read command�������


// correlative 2:   =======================================================
// �������� MD
// ���ⲿ������������� MD ���û��õĸ�λ����,�����Ҫ���߼����,ע������

assign MD[31:8] = (1'b0)? 24'h000000 : 24'hzzzzzz;  //��ʵ������MD[7:0] 
//assign MD[31:16]= (1'b0)? 16'h0000 : 16'hzzzz;    //ʵ������MD[15:0]
 
//assign MD[31:0] = (1'b0)? 32'h00000000 : 24'hzzzzzzzz; //ʹ��EP1C12��Ƕ�� SRAM �����棬MD�����ø���


/* correlative 3:   =======================================================
   ���ⲿ����ĵ�ַ����ͨ��ѡ��(MA / A_)���䲻�õĸ�λ��ַλ���� 
     ���ⲿ����ĵ�ַ������2·--����CPU�����������ѡ��:		
   1)ר�õ�ַ,��ֱ��ͨ��A_[23:0]��3��8λ˫��3̬����3245��MA,��MA��A_[23:0]--����Debug���ó��������׵�ַ.
   2)���ݵ�ַ����ʱ,MD��3��8λ������74373���ΪMA,�������ź���ALE.
   3)����EN_A(EN_MA)��JP_A��6������EN_MA5-0�ֱ����3��3̬����3245�����3��������74373�������.
     ͨ��3��3̬����3245�������������,��֤Debug���ó��������׵�ַ����Ҫ�ĵ�ַ���룬
         ��ʹ���ⲿ���桢CPU���м�RUN=1ʱ��A_[23:0]���õĵ�ַ��λ�������"0"����
         ----����ǰҪ�õĵ�ַλ��������ͨ���޸������߼����: Note 3-1, ��ע����,��Note 3-2
     ��3��������74373���MA����������Ҫ�󼴵�ַ���ݸ���λ�ķ�Χ����:
         ----�����Ҫ���λ����MA2-0���룬��ʵ������
     ע�⣺�е�CPU������������ǽ����͵ģ������ֵ�ַ(ͨ����λ)�Ǻ����ݸ���,������(ͨ����λ)��ר��ֱ�ӵ�ַ.
           ��51ϵ��,8086/88. 
   4)ʹ��EP1C12��Ƕ�� SRAM �����棬MA / A_ ���ø��衣�� correlative 9
*/ 
assign A_[10:0] = (RUN)? o_a : 11'bzzzzzzzzzzz;  //��ʵ����ֱ����A_[10:0]
assign A_[23:11]= (RUN)? 13'b0000000000000 : 13'bzzzzzzzzzzzzz;  //Note 3-1,��A_[23:11]:RUN=0 �ø���; =1,��"0"

//assign A_[23:0] = (1'b0)? 24'h000000 : 24'hzzzzzz;  //Note 3-2 ʹ��EP1C12��Ƕ�� SRAM ������ �� ��ַȫ����MD�ĸ���ʱ��
                                                      //         A_[23:0]�ø���

// correlative 4:   =======================================================
// ���������׵�ַ�����÷���ѡ��CPU�߼����첽��λֱ������ �� Debug����
// ���֪�����Գ��������׵�ַ��������my_cpu(cpu_core)�ڣ����첽��λ���õ�pc��pc_o <= 12'h00e;
//     �� ע������3�������˿�: .run(RUN),.pc_cp(SET_CP), .oa(A_[10:0]��
// ���򣬱��ֵ���3�������˿ڣ�my_cpu(cpu_core)�ڣ����� if (~run) pc_o <= o_a[10:0];

// correlative 5: ======================================================
// CPU����ʱ�ӷ��ص�Face_CPLD EPM3512, �Կ��Ƶ�������ָ���ϵ����
// ���CPU���Ϊ����ʱ�ӣ�ʱ��Դһ�η�Ƶ������,���ٽ����ٴη�Ƶ)
//     ��ע�����ò����˿�._ck(ck)��Note 5-1�߼����, ��Note 5-2-1�� 5-2-2�߼����  
//assign CK=ck;     //Note 5-1
assign CK=CLK;    //Note 5-2-1   
//assign CK=!CLK;   //Note 5-2-2  

// correlative 6: ======================================================
//2ѡ1�� �� �� ע�� 1)�� ����߼����� �� 2)��  ΢�������  ���߼����
// A) CPU���ڷ��ص�Face_CPLD EPM3512
//1)����߼�����:
assign T=t;     //T[0]�����ָʾ��

// B) CPU����һ��ָ��ִ�н����źŷ��ص�Face_CPLD EPM3512,������ͣ
//ָ��ִ�н����ź� END_I = my_cpu ��ÿ��ָ��(��ͬ������) & ��ָ��Ľ�������
//��my_cpu δ�ͳ� i_end,  �� my_cpu�ľ���Ҫ�������������� Note 6-1,2 ,���Note 6-3

wire   i_2cyc = !i_reg[15] | (i_reg[15:13]==3'b111); //Note 6-1 ���ʺϵ�ǰʵ��
assign END_I  = i_2cyc & t[1] | !i_2cyc & t[2];      //Note 6-2 ..

//assign END_I = t[max];  //Note 6-3 �̶����ڲ�����CPU,��ע������ 2���߼�

//2)΢�������: ��ÿ��ָ���΢�������н�����־(ĳλ΢��)��uI[n]

//assign T[0] = ui[n];  //uI[n]=1 ��Ч, ÿ��ָ���΢�������н�����־�����ָʾ
//assign T[3:1]=0;
//assign END_I= ui[n];

// C)ͣ��ָ���ź������Face_CPLD EPM3512,������ͣ
assign STOP = 0;  //δ���ͣ��ָ�� =0, ���� = (ָ�������==ͣ��ָ�������);


// correlative 7: ======================================================
//brekpoint logic ����Ҫ�ϵ����**************************************
// �ϵ��ź������Face_CPLD EPM3512,������ͣ           
// ���my_CPU����û�жϵ����ù���, ��
//��Ҫ,�����߼�����������,  �� ע�� Note 7-1 ;  �粻��Ҫ�ϵ����,��� Note 7-1,ע���¶�
//brekpoint registers of USB_8051 address space Ox6401/2/3
//��ǰֻʹ��16λ,����߿ɾ����Ҫ�����Ƶ�����
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
//assign PC_BKT=0;  //Note 7-1 ���öϵ�,��򿪱���,ע������ϵ��߼�������


// correlative 8: ======================================================
// ���ٻ��� my_CPU���ڲ���Ϣ 
//track and callback space: USB_8051:0x6c00-0x6fff (Read Only)
//NOTE: Should not use (_A[11:8] == 4'b11xx ) as an condition 
//                           in Quartus, it is always false.   
wire en_callback = !_CS & _0x6 && (_A[11:10] == 2'b11) && !_RD; //6Cxx H

// ���ٻ������� write ��ʾ��************************************
// ���ٻ���ʱ Debug W 0x6005 ���� clr, ��ȫ��������մ�����
wire clr= !_CS & _0x6 && (_A[11:0] == 12'h005) && !_WR;    
reg wc;   //д����Ļ��մ����� 
always @(posedge write or posedge clr )  //pulse =>level for callback
begin
  if (clr)
     wc <= 1'b0; 
  else 
     wc <= 1'b1;              
end

//���ٻ��յ���Ϣ������ģ�����ʱ�������Ϣ������Ϊ�ο��̶��ع۲��ڲ���Ϣ��ʹ�������Ϣ��
//���ٻ���CPU�ڲ�������Ϣ�Ŀռ��ַ����� �� �ļ�ͷ
//   �����ĸ��ٻ�����Ϣ������ <��Ϣ���ٻ���>�߼������
reg[7:0] fbd;  //
always @(_A[7:0] or MD[7:0] or A_           //or o_d or od or o_a   
             or r0 or r1 or r2 or r3
             or PC_BKT or cy or z or t or wc or read 
             or i_reg or pc or bp_r0 or bp_r1 )
             
  //������ǰ��� assignment list ��˵���� my_cpu�ľ������
  //    ����Ӧ�ĵ�ַ��Ԫ����Ӧ����Ϣ�����ڲ��м���� fbd;
  //���ν��Ե�ǰʵ��,ʹ���ⲿ����, ���ı�ʵ����Ƕ��(embedded) SRAM ����������޸�
  begin  
    case (_A[7:0])                      //******��ӦDebug���ڵ���Ϣ��************
	  8'h00: fbd <= A_[7:0];                  //�ڲ���ַ����IAB[7:0]    ʹ���ⲿ����ʱ  
	  //8'h00: fbd <= o_a[7:0];                 //�ڲ���ַ����IAB[7:0]    Ƕ��(embedded) SRAM ������
	  8'h01: fbd <= {5'b00000,A_[10:8]};      //�ڲ���ַ����IAB[15:8]   ʹ���ⲿ����ʱ
	  //8'h01: fbd <= {5'b00000,o_a[10:8]};     //�ڲ���ַ����IAB[7:0]    Ƕ��(embedded) SRAM ������
	  8'h04: fbd <= MD[7:0];                  //�ڲ���ַ����IDB[7:0]    ʹ���ⲿ����ʱ
	  //8'h04: fbd <= o_d[7:0];                 //�ڲ���ַ����IDB[7:0]    CPU �� Ƕ��(embedded) SRAM ����
	  //8'h06 fbd <= od[7:0];                  //�ڲ���ַ����IDB[7:0]    CPU д Ƕ��(embedded) SRAM ����   
	  8'h08: fbd <= r0;                       //�ۼ���A
	  8'h0C: fbd <= r1;                       //�ۼ��ݴ���ATC
	  8'h10: fbd <= r2;                       //�Ĵ���A
	  8'h14: fbd <= r3;                       //�Ĵ���B
	  8'h28: fbd <= {PC_BKT,cy,z,t,wc,read};  //״̬�Ĵ���status ,Ƕ��(embedded) SRAM ����ʱ wc��write   
	  8'h2c: fbd <= i_reg[7:0];               //ָ��Ĵ���IR[7:0]
	  8'h2d: fbd <= i_reg[15:8];              //ָ��Ĵ���IR[15:9]
	  8'h30: fbd <= pc[7:0];                  //���������PC[7:0]
	  8'h31: fbd <= {5'b00000,pc[10:8]};       //���������PC[15:8]
	  8'h33: fbd <= bp_r0;                    //�ϵ�Ĵ���BPR[7:0]
	  8'h34: fbd <= bp_r1;                    //�ϵ�Ĵ���BPR[15:8]
	  default : 
	        fbd = 0;	
    endcase	
  end 
 
//ʹ���ⲿ����ʱ������¾䣬embedded SRAM ������ʱ����ע��
 assign _D = (en_callback) ? fbd : 8'hzz;  // to USB_8051, 

// correlative 8: ======================================================

 assign A_31=A_[10]; //Amax, chip of memory,  A_[10]=1,IO_communication for current cpu12, 

//��ʵ�����õĲ���output����Ч����*******************************
assign ALE=0;
assign BUS_CLK=0;
assign D_DIR=0;
assign A_30=0;
assign EN_A=0;      //��ʵ�����ø��õ�ַ
assign INT5 = 1'b1; //(not INT5) 

//���õ�output or inout�źŴ���***********************************
//���õĲ���inout���߿������źųʸ��账����ֹ��3̬����

assign C_A[7:0] = (1'b0)? 8'b0 : 8'bz;
assign C_R[11:0]= (1'b0)? 12'b0 : 12'bz;

//correlative 9: ==============================================================================
/* EP1C12��Ƕ��(embedded) SRAM ���� �ڲ��߼� ������  ******************************************
*****************************************************************************************
(1)��֮�����ص��߼������޸�:  **********************************
   A ��ǰ��ʹ��Ƕ��SRAM���������������߼���䣬ͬʱע��ʹ���ⲿ�������ĸ��߼����
     ע��:ʹ�� SRAM ������ʱ, ����Ӱ����λ���������ⲿ������,����Debug����������,���
          ����������ⲿ�������������ź�,��������Ч����--�������Ч��ƽ,˫�򸳸���. 
   B ��mycpu(CPU_Core)��ʵ����Ƶ��޸ģ�
     1)CPU���ʴ�����������o_d��˫��inout ��Ϊ�ֿ��Ķ�����input o_d��д����output od
     2)��CPU���������ĵ�ַo_aҲ��˫��inout,���Ϊoutput o_a�ô�,input oaΪ���ó��������׵�ַ
       �����ʴ������ĵ�ַo_a��output,Ϊ���ó��������׵�ַ,����input oa
           �����������׵�ַ��֪��,������input oa
       ������Ҫ���߼�������Ӧ����ɾ.(��ʵ������򿪻�ע����Ӧ���߼��������) 
   C ��Ƕ�� SRAM �������������CPU_Core��ʵ����, ���طô����Ϣ���ڸ��ٻ���
   D ����HV�ṹ�ĳ�������ݴ����������ͬǶ��rom��SRAM, SRAMҲ��ѡ���ⲿ������
         ���߼��������ڱ���,Ҳ����CPU_Core��ʵ����,Ҳ�ɽ�����á�
         ʵ������˿������������ĸ��ٻ��ա���ش�����CPU_Core��ʵ����ơ��ο���������������С�
   E ע��:ʹ�� SRAM ������ʱ,��λ�������ⲿ������(8000H�ռ�)�鿴���н�������Ѳ�����,
          ��������λ������D000H�ռ伴_0xd,��(3)

��2��embedded SRAM �����߼�Ҫ�� ��ʾ:      *******************************
   A)����Cyclone(����EP1C12)������lpm_ram_io���Զ���Ϊlpm_ram_dq����ֻ����ͬ����ʽ(�첽���ܳ�ʼ��)
       ʹ��lpm_ram_dq������ͬ����ʽ��ȱʡ������������ݡ���ַ��WE�Ĵ棬Ҫ�ļ���ɳ�ʼ����
       ʹ��lpm_rom   ������ͬ����ʽ��ȱʡ������: ����ַ�Ĵ棬            Ҫ�ļ���ɳ�ʼ����
       �����ֿ������ͬ����ʽ��ʱ��,����inclock��outclockѡ��1�ֻ�ѡ(daul),��������0ͨ����ѡ.
   B)���뷽ʽͬ������embedded SRAM��ʱ��Ҫ��:
     ʱ����Ϲ���inclock(or clock)����ǰ����Ч��д����we(or wren)�����inclock��ǰ����1����ʱ�䵽��
   C)embedded SRAM����������Դ
     1)USB_8051���ʣ���CPU������ʱ��RUN=0����USB_8051 �� 0xDxxx �ռ��дembedded SRAM
       ��Ϊ�˹۲�CPU�ĳ������н����д�����ĳ�����ʼ���ݣ�
           ��ʱ�������USB_8051ʱ���ͬ��ʱ�ӣ�ͬ��ʱ���Ƽ� F_CLK��68013��CLKOUT��
     2)CPU���ʣ�����ִ��ʱ��RUN=1������CPUʹ�÷�Ƶʱ��ʱ��ͬ��ʱ��ѡCK��
                                     ��CPUʹ�õ���ʱ��ʱ��ͬ��ʱ��ѡ!CLK��
                ͬʱ write ��my_cpu�� ��Ҫ & ck �� & !CLK 
           
*/
//(3)inclock ͬ��embedded SRAM��2����Դ���߼����**************************************
// A USB_8051_0xDxxx access  SRAM******************************************************
 // Ƕ��(embedded) SRAM �����棬��򿪱���================================================
 /*
  wire 	d0_code   = _0xd & (_A[11:8]==4'b0000);
  wire  en_rd_ram = !_CS & d0_code & !_RD ;
  wire  en_wr_ram = d0_code & !_WR;
 */

//Ƕ��(embedded) SRAM ������, ��򿪱���================================================= 
/*      
  wire  u51_clk =!_CS & d0_code & (!_WR & F_CLK | !_RD );
 
// B ����RAM�Ķ�ѡһ��CPU or USB_8051
  wire [7:0] data    = RUN? od       : _D;  
  wire [7:0] address = RUN? o_a[7:0] : _A[7:0];     
  wire we            = RUN? write    : en_wr_ram;  
  wire inclock       = RUN? ck       : u51_clk;
 */
   
// C ѡ��ֱ�ӵ���ram �� ����ramʵ��

  // ֱ�ӵ���ram����򿪱��� ===================================================
/*
\lpm_ram_dq mm(.data(data),   
               .address(address), 
               .we(we),
               .inclock(inclock), //д���ݡ���ַ��we������Ĵ�clock
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
 // ����ramʵ��sram_mm mm(��ͬ�ļ���)����򿪱��� ===================================================
 /* 
 \sram_mm mm (.address(address),
	          .clock(inclock),
	          .data(data),     //
	          .wren(we),
	          .q(o_d));
 */
// ���ڲ��߼������ݻ���Ĵ���+��λ��·�̽Ӹ�/�͵�ƽ������������򿪱���===================
/* ��ʵ��˫�ֽڼӳ���42F0+5287=9477�� 
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
	 // 8'h0a: o_d <=8'hff;   // ���������ָ��� ffff H 
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
  if (write==1)     //write ��my_cpu�� ��Ҫ & ck �� & !CLK 
    begin
      case (o_a)
	    2'h08: d_a <= od;
	    2'h09: d_b <= od; 
      endcase  
    end
end




*/

//ʹ��EP1C12��embedded SRAM �� �ڲ��߼� �����棬usb_8051����������򿪱���===============
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

