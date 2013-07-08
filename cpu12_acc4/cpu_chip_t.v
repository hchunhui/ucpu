//��ͨ��ģ���ʹ��оƬ EPF10K30RC208
//Main board of CPU's design and experiment system
//chip of CPU module is epm7256 or epf10K30,  all pin = 208.
//pin define declare 
//pin assign must change file *.acf for epm7256 or epf10K30
//signal_name's pin number, express such as: RA[1:0] is
//  (epm7256-4,3/epf10K30-207,208) => (pin 3,4/208,207)  

module cpu_chip_t (Reset,RUN,CP,IRQ,STOP,I_END,CK,CK_10K,T,PC,//PC_BP
                RD,EN_W,EN_R,R_A,CBD,AA,
                MA,MD,WC,RC,uD,uA,uCK,uCLK,uCP,t_mode,return_ck); //new add:t_mode,return_ck
                      
  //Ctrl and setup signal ************************

  //when RUN=1(reset=0),there is clock and cycle of CPU, CPU running
  input  Reset;     //(pin 10/11), Reset of soft and hard,from interface
  input  RUN;       //(pin 151/161) from interface of host computer
  input  CP;        //(pin 29/36)   when RUN=1 and pulse CP=1(negedge active),from interface
                    //  setup start_first_address of CPU's program
  input  IRQ;       //(pin 28/31) interrupt request from interface of main computer 
  output STOP;      //(pin 80/83) STOP instruction to interface of main computer
  output I_END;     //(pin 81/85) end of per instruction to interface of main computer
  
  
  //outside or inside timer ************************************

  //because ck connected ck_10k  on board, from interface
  //  so they need synchronously define,else conflict
  //When outside timer: they is clock of CPU_cycle
  //When  inside timer: they is main clock of CPU
  //when RUN=1, ck(=ck_10k) is clock;else there is a lack of clock 
  input  CK;         //(pin 184/79)  use
  input  CK_10K;     //(pin 78/186)  no use
  output return_ck;  //(pin 197) return_ck of CPU's inside timer,out to external
  
  //timer_cycle_direction controll----------------
  output t_mode;     //(pin 195) mode of CPU's timer:  
                     //   =1, outside timer,T is input; =0,inside timer,T out to external
  inout  [3:0] T;    //(pin 6,7,8,9/7,8,9,10) t_mode=1,input;=0,output.

  
  //CPU breakpoint and interface ****************************************
  //1) breakpoint_Logic: in interface
  output [11:0] PC; //(pin 15,16,17,18,19,20,21,22,24,25,26,27
                    //    /15,16,17,18,19,24,25,26,27,28,29,30)
                    //program counters of CPU, goto interface for breakpoint
  /*
  //2) breakpoint_Logic: in CPU   
  //  Pleass open PC_BP in module cpu_chip_m ( )
  //pc's pin new define of breakpoint in CPU, pin be the same as output [11:0] pc;
  //Note: interface rejigger(change), cut breakpoint logic(see face_no.tdf) and
  //send out data and address and cs and write and read from interface
  //can used to setup start_first_address of CPU  
  input [10:0]  pc; //PC[7:0]----data of setup breakpoint etc from interface
                    //AA[4:0]----address of setup breakpoint etc from interface, See back
                    //PC[8]------write order(pulse) of setup breakpoint registers etc 
                    //             from interface
                    //PC[9]------read eable of breakpoint registers etc from interface, can't use
                    //PC[10]-----space chip Of setup breakpoint registers etc from interface,
                    //           PC[10]=cs=op & !aa7 & !aa3 & aa2 & aa1;
  output PC_BP      //viz PC[11]-CPU's program breakpoint output to interface    
  */
  
  //outside 8x4 registers***************************************
  inout  [7:0]  RD; //(pin 40,39,38,37,36,35,34,33/47,46,45,44,41,40,39,38)
                    //data of outside 8x4 registers
                    //if inside, no use  =3s
  output EN_W;      //(pin 48/53) write order(pulse) of outside 8x4 registers
                    //if inside, no use  =1
  output EN_R;      //(pin 49/54) read eable of outside 8x4 registers
                    //if inside, no use  =1
  output [1:0]  R_A;//(pin 4,3/207,208)
                    //read address of outside 8x4 registers, 
                    //if inside, no use  =0
  //callback information  to mian_computer********************************
  output [7:0]  CBD;//(pin 62,61,60,59,58,57,56,55/63,62,61,60,58,57,56,55)
                    //data of callback CPU's information
  input  [4:0]  AA; //(pin 205,204,203,202,201/205,204,203,202,200)
                    //address of mian computer

  // outside memory (viz main memory, CPU and mian_computer share ) *******
  inout  [12:0] MA; //(pin 67,68,69,70,71,86,87,88,89,90,91,92,93/
                    //(    68,69,70,71,73,87,88,89,90,92,93,94,95)
                    //share_address_bus of CPU and interface of mian_computer
                    //when RUN=1, out; else is zzz                
  inout  [7:0]  MD; //(pin 95,96,97, 98, 99,100,101,102/
                    //     96,97,99,100,101,102,103,104)
                    //share_data_bus of CPU and interface of mian_computer
                    //when RUN=1 and wc=1, out; else is zz
  output WC;        //(pin 12/13), write enable of CPU (not pulse)
  output RC;        //(pin 13/14), read enable of CPU
                    //WC and RC goto interface and combination with mian_compute_W/R
  
  //outside micro_memory, CPU only read and mian_computer W/R
  //When use inside micro_memory for FPGA_CPU, outside micromemory no use                 
  input  [23:0] uD; //(pin 108,109,110,111,112,113,114,115,
                    //     117,118,119,120,121,122,123,124,
                    //     133,135,136,137,138,139,140,141/
                    //     111,112,113,114,115,116,119,120,
                    //     121,122,125.126,127,128,131,132,
                    //     141,142,143,144,147,148,149,150)
                    //data of micro_memory
  output [10:0] uA; //(pin 161,163,164,166,167,168,169,170,171,172,173/
                    //     164,166,167,168,169,170,172,173,174,175,176)
                    //address of micro_memory, if RUN=1, ua out;else ua is zz
  //because ucLK connected uCK on board
  input  uCK;       //(pin 182/182) no use, must define
  input  uCLK;      //(pin 181/183) clock of upc(micro_program_counters)  
  input  uCP;       //(pin 77/78) clock of uir(micro_instruction_registers)

 //=============================================================================================
 //begin =======================================================================================
 //һ  ����˵�� ********************************************************************************
 //���� cpu_core����ʵ��Ϊ cpu8tv----����ʱ�ӵ���ʱ��  .clk(CK)
 //�βζ˿���.�β�()��ʾ������Ŀȡ��cpu_core����������˿���������ʱҪ����Ŀ��cpu_core������ɾ
 //    �� CPU��12�����ϻ�΢������ƻ��������͵����,���� ���ݲ��۲���Ҫ��ʱ���Ӹ��ٵ��ڲ���Ϣ
 //ʵ�εĴ��룺ʵ�δ�����Ӧ�˿�()�ڣ����ʺͿ��Ҫһ��
 //1)��ֱ���ñ�����������ź���ʵ�δ�����.wc(WC)�е�WC��
 //    �������ֱ���ñ��ļ�����˿��źŴ���, ��T����._t()����ʹ���ڲ��м����t ���룬��._t(t)��
 //        ��ǰCPU���ڲ�ʱ��T���������T[3]���ܲ���ͬt[3]��
 //    ע�⣺�����������Ҫ���ڲ��м�����������ĵ�����źŻ򽫱��ĵ������źŸ����ڲ��м����
 //          ������󽫱����ص�������warning�ڣ������������Ҫ���warning��Primitive 'xxx'stuck at GND.
 //2)���ڲ���Ϣ����ٻ��յ���Ϣ.ac(acc)�е�acc
 //3)��ʵ��ʹ���ڲ��м�������ڲ���Ϣ������t��acc�ȣ�
 //  �����ڵ���ʵ��CPU�˶�ǰ������ע���źŵ����ʺͿ�ȵ�һ���ԣ���ע���źŵ����ʺͿ�ȵ�һ���ԡ�
 //      �в�����ʵ������ͬ���������ɻ�
 
 //��  �ڲ��м�����Ե�ʵ������ ****************************************************************
  wire        cy;
  wire [3:0]  t;
  wire [7:0]  tmp,acc;
  wire [11:0] pc; 
  wire [12:0] o_a;
  wire [15:0] i_reg;
//΢�������ʱ��������
  //wire [7:0]  ua;   //or upc
  //wire [15:0] ud;   //or uir(΢������ƴ����������CPU_CORE)
//��Ƕ��SRAM ������ʱ��������
  //wire        wc,rc;
  //wire [7:0]  md;
  //wire [7:0]  ma;  //���ݼ�������Ҫ����ַλ��

//��  ��������Ƶ�cpu_core ******************************************************************** 
 \cpu8tv cpu_core(  //��ǰcpu8tv: ����ʱ�ӵ���ʱ��,����߼�����
                   .reset(Reset),       //ֱ�Ӵ���
                   .clk(CK),            //ֱ�Ӵ���. or .ck(CK) when outside timer��
                   ._t(t),              //�ڲ��м����,��ʱ����ʱ�� ._t(T)
                   //.ck(return_ck),      //ֱ�Ӵ��롣��ʱ��, ���ص��ⲿ
                   .end_i(I_END),       //ֱ�Ӵ���,������һ��ָ�����   
                   .wc(WC),             //ֱ�Ӵ���
                   .rc(RC),             //  ..
                   .o_d(MD),            //  ..
                   .o_a(o_a),           //�ڲ��м����,��ƽ̨MA��inout
                   .pc(pc),             //�ڲ��м����,����ٻ���,�ڲ��ϵ��߼���Ҫ
                   .i_reg(i_reg),       //���ٻ��յ���Ϣ
                   .ac(acc),            //  ..
                   .cy(cy),             //  ..
                   .tp(tmp),            //  ..
                   //.ua(ua),             //�ڲ��м���� �� ���ٻ���     or (upc)
                   //.ud(ud),             //  ..                         or (uir) 
                   //.uclk(uCLK),         //ֱ�Ӵ���, when outside timer 
                   //.ucp(uCP),           //  ..      ���¾�ֱ�Ӵ��    
                   .run(RUN),   //When RUN=0��under CP, pc <= oa;
                   .cp(CP),     //pulse: Debug setup first address of program 
                   .oa(MA)      //when MA_input,used low 10 bit only when 1-2connect of equipment_JP2 
                 );

//��  ����˵��: *********************************************************************************
//1������ʱ������----ʹ��������: �� ��� 
//   ʱ�������CPU�ڣ�.clk(CK)--��ʱ������,���ɵ�����._t(t) ��������ⲿ 
//                    .ck(return_ck)--����������,����������ⲿ  
//   ʱ���ⲿ�ṩ��   .ck(CK)--����������, ._t(T)  ��������
//   

//2) return_ck to external
//   �������ʱ�򡢷ǵ���ʱ�ӣ��򿪶˿� .ck(return_ck)��ע��������䣬����ע��
     assign return_ck= CK;   //����ʱ����ʱ��ʱ

//3) ���CPU�ù̶����ڣ���ע��.end_i(I_END), �����ѡ����һ��򿪣�
     //assign I_END = t[max]; //�ڲ�ʱ��
     //assign I_END = T[max]; //�ⲿʱ��

//4) ʹ��Ƕ�� SRAM ������
//   A �����Ƕ��SRAM ������ʱ�õ��м��������,������:.wc(wc),.rc(rc),.o_d(md),.o_a(ma),
//   B ��MA���������Ϊ3̬����,�� �� ��
//         ��74465ʱ,���� 1'b0 => 1'b1,�Խ�ֹ��3̬��(����)
//       ����assign, ���� RUN  => 1'b0,��ѡ�����
//   C ��MD���������Ϊ3̬����,��������:
       //\74465 MD_busl(.gn({1'b1,1'b0}),.a(8'hFF),.y(MD));  
//   D ��CPU_Core��ʵ����Ƶ��޸ģ���Ҫ�Ƿ��ʴ�������������˫���Ϊ����д�ֿ���,��ʮ���� B
//        ����Ҫ�����򿪻�ע����Ӧ���߼��������� 
//   E ��Ƕ�� SRAM �������������CPU_Core��ʵ����, ����.wc(wc),.rc(rc),.o_d(md),.o_a(ma),
//         ���ڸ��ٻ���
//   F ��WC��RC������������----������2�����
       //assign WC=1'b0;
       //assign RC=1'b0;
//   G ����HV�ṹ�ĳ�������ݴ����������ͬǶ��rom��SRAM, SRAMҲ��ѡ���ⲿSRAM.
//         ���߼��������ڱ���,Ҳ����CPU_Core��ʵ����,Ҳ�ɽ�����á�
//         ʵ������˿������������ĸ��ٻ��ա���ش�����CPU_Core��ʵ����ơ��ο���������������С�
//   H ʹ�� SRAM ������ʱ,������(�ⲿ)�鿴���н�������Ѳ�����,����:
//     a �Բ��Գ���*.bin,Ҫ������ѭ����������ǰ�ѽ��(����мĴ�����)�����ۼӵ��ۼ��������ٻ�����Ϣ.
//     b ���ֹ�ⲿ����Ƭѡ(�Ľӿ�EPM7256�߼�),RC��Ϊ����,RUN=0ʱDebug�ɶ�SRAM,���Ƚ��鷳.

//5) ���õĸ�λ��ַo_a �� pc ������4��ָ���CPU���������������
     //assign o_a[12:0]=5'b00000;
     //assign pc[11:0]=4'b0000;

//6) ���õĵ��ֽ�ָ��Ĵ��� i_reg ���� ����4��ָ���CPU�������������
     //assign i_reg[7:0] = 8'h00;

//7) ���ٻ�����Ϣ������ģ�����ʱ�������Ϣ���ر���Ϊ�۲��ڲ���Ϣ��ʹ�������
//   �����ĸ��ٻ�����Ϣ�ں��� ʮ�� <��Ϣ���ٻ���>����������
//       ������δ�õĵ�ַ��Ԫ��
//       �����õ�ǰ�Ѳ��õĵ�ַ��Ԫ��
//ע:PC�����ʱ,�������ⲿ����,
//   PC����ʱ,Debug���ڳ����������ʾ������ʵ�ʲ���CPU_PC,���Ա�����<��Ϣ���ٻ���>����ӻ���

//8) ʹ��΢������Ƶ�΢��: 
//   a ���΢�����õ��м���������ʹ���˿�,������ʱ��(���ⲿ),��.uclk()��.ucp()����.
//     ��΢�������CPU_Core��ʵ����,����ٻ�������upc,uir
//   b ��ʮһ micro_PROGRAM_Ctrl��,��Ҫ�����򿪻�ע����Ӧ���߼���������
 
//9) ���֪�����Գ��������׵�ַ������cpu_core�����첽��λ���õ�pc��pc_o <= 12'h00e;
//       ��ע��.run(RUN),.cp(CP),.oa(MA), 
//   ���� ��cpu_core������������䣺pc_o <= {2'b00,oa[9:0];    ������ 
/*
  wire _ck = ck | cp��  //cp ���½��ĺ������,������������� negedge _ck 
  always @(negedge _ck or posedge reset ) 
   begin
      if ( reset)
        pc_o <= 12'h000; 
        //pc_o <= 12'h00e; //֪�����Գ��������׵�ַ=00e H   
      else if (run==0)     //CPU������ʱ, �ӿڷ������׵�ַ����CP�´���PC
        pc_o <= {2'b00,oa[9:0]; //ƽ̨JP4��1-2�����õ�10λ
      else
      casex ({irh[7:5],t,cy_reg})
        ������������
*/

//10�����CPUʹ���ⲿ�Ĵ�����----���߶�
//    ����ϵ�����������λ��(��CPU_core��ģ����ⲿ)----���˶�
//    ͣ������----���Ŷ� 

 
//�� timer �ڲ����ⲿ�Ŀ��� ******************************************************************
//if CPU is inside timer,then mode_t=0,else =1; 
   wire mode_t=0;  //same with t_mode, =0, because cpu8tv is inside timer
   assign t_mode = mode_t; 

//FUNCTION TRI (in, oe)
//   RETURNS (out);
\tri _t0(.in(t[0]),.oe(!mode_t),.out(T[0]));
\tri _t1(.in(t[1]),.oe(!mode_t),.out(T[1]));
\tri _t2(.in(t[2]),.oe(!mode_t),.out(T[2]));
\tri _t3(.in(t[3]),.oe(!mode_t),.out(T[3]));
 
//��  ��ַMA������3̬˫������ѡ�� 1) �� 2) ***************************************************
//    �������������������ó��������׵�ַ��Ҫ
// 1) ��74465
//\74465 MA_busl(.gn({~RUN,1'b0}),.a(o_a[7:0]),.y(MA[7:0]));    //�����ֹ��3̬��,��1'b0 => 1'b1
//\74465 MA_bush(.gn({~RUN,1'b0}),.a(o_a[12:8]),.y(MA[12:8]));  //  ..
// 2) ��assign
assign MA = RUN?(o_a):13'bz_zzzz_zzzz_zzzz;          //only 10k30 �����������,�� RUN  => 1'b0

//��  �ⲿ�Ĵ�������� **************************************************************************
//�����ǰʹ���ⲿ�Ĵ����飬�ڵ���cpu_core�Ķ˿���,
//    ��EN_W,EN_R,R_A,RD����ʵ�δ���,��ע������ 4��:
//�����ǰ��ʹ���ⲿ�Ĵ�����,������ 4�� ���������:
assign EN_W=1;
assign EN_R=1;
assign R_A=2'b00;
// �Ĵ�������RD��3̬���� ��ѡ�� 1 �� 2 �� 3
//assign RD = 1'b0 ? 8'h00:8'hzz;                     //1 for chip_EPM7256 and chip_10K30,have warning  
//\74465 RD_bus(.gn({1'b1,1'b0}),.a(8'hFF),.y(RD));   //2 for chip_EPM7256 and chip_10K30,have warning
assign RD = 8'hzz;                                    //3 for chip_10K30 only, no warning    


//��  brekpoint logic ����*************************************************************************

//1) ��� brekpoint logic ���ⲿ,�� assign PC=pc;----�Ƽ� 
//       ͬʱ module��PC��������Ҫ �� 1),ע�� 2)
//          ע�� brekpoint logic ������
//2) ��� brekpoint logic �ڱ�ģ��,PC[10:0]������,Ҫע�� assign PC=pc; 
//       ͬʱ module()������PC_BP,ǰ���PC��������Ҫ ע�� 1),�� 2)
//          �� brekpoint logic ������ 1) �� 2) 
//       ע�⣺brekpoint logic ���ڲ���2)��3)--���Ƽ�ʹ��
//3) ��� �ϵ��߼������CPU_core, module()������PC_BP,ǰ���PC��������Ҫ ע�� 1),�� 2) 
//       PC[10:0]���¶���Ҫ���뵽CPU_core,PC_BP��CPU_core���,Ҫע�� assign PC=pc
//       �ڵ���cpu_core��Ҫ������Ӧ�Ķ˿������:       
//           .aa(AA),._d(PC[7:0]),..wr(PC[8]),.cs(PC[10]),.pc_bt(PC_BP)     
//   ע��: Ϊ��֤PC[10:0],PC_BP���϶ϵ����ڲ���2)��3)�Ķ����빦��.
//         cpu_chip��EPF10K30���(��д)ǰ,����faceN_usb�ļ��е�face_b.pof��̽ӿ���EPM7256    
  
     assign PC=pc;

//brekpoint logic in cpu_chip  ������======================================== 
//brekpoint registers of USB_8051 ctrl_address a9=1
//��ģ���ź� ����     CPU_core���ź�������
// AA[4:0]--address----input  aa[4:0];
// PC[7:0]--data-------input  _d[7:0];
// PC[8]----write------input  wr; 
// PC[10]---Ƭѡ-------input  cs; 
// PC_BP----�ϵ�-------output pc_bP;

// ��ѡ�� 1) �� 2) ���ַ�ʽ 

/*                   
// 1) immediacy describe  111111111111111111111111

wire[7:0] _D=PC[7:0];  //input
wire WR=PC[8];    //input        
wire cs=PC[10];   //input  "0" active
 
wire en_b_rl = !cs & !AA[0];
wire en_b_rh = !cs &  AA[0];
                    
reg[11:0] bp_r;
reg PC_BP;

always @(negedge WR or posedge reset )
  begin
    if (Reset)
      bp_r <= 0;
    else if (en_b_rl)   bp_r [7:0] <= _D;
    else if (en_b_rh)   bp_r[11:8] <= _D[3:0];
  end
  
 always @(bp_r or pc)   // pc from CPU_core
   begin
	 if (bp_r==pc)
	    PC_BP <=1;
	 else 
	    PC_BP <=0;
   end

  */

// 2) use instance--���Ƽ�  2222222222222222222222
  /*
  \bkpt bp(.reset(Reset),
           .AA0(AA[0]),
           .PC_BP(PC_BP),
           .chip_PC(PC[10:0]),
           .cpu_pc(pc),
           );
  */

  //��  ͣ������ ****************************************************************************
  //When online test of cpu run in cpu experiment system  need
  assign STOP  = 1'b0;  // When no STOP instruction else = OP_code of STOP instruction

   
  //ʮ ��Ϣ���ٻ��գ�feedback cpu'S inside information  from CPU core************************
  //       �ɸ�����Ҫ,�Զ�����ٻ��յ���Ϣ
  //       ��ѡ�� 1) �� 2) ���ַ�ʽ
  //1) immediacy describe   111111111111111111111111
  //   (When no suffice 8 bit,fill in "GND")
  reg [7:0] qq;
  always @(AA[4:0])
    begin
      casex(AA[4:0])
        5'b00000:
          qq <= MA[7:0];              //low 8 bit of inside/outside address bus   
        5'b00001:
          qq <= {4'b0000,MA[11:8]};   //high bit of inside/outside address bu        
        5'b00010:
          qq <= MD;                   //inside/outside data bus
        5'b00011:
          qq <= acc[7:0];             //accumulator register
        //5'b00100: 
          //qq <= 8'b00000000;          //ACT_temp REG   no use
        5'b00101:
          qq <= tmp[7:0];               //TEMP REG
        //5'b00110:
          //qq <= 0;                     //REG0  ������ ud/uir[7:0]  
        //5'b00111:
          //qq <= 0;                     //REG1  ������ ud/uir[15:8]
        //5'b01000:
          //qq <= 0;                     //REG2  ������ ud/uir[23:16]    
        //5'b01001:
          //qq <= 0;                     //REG3     
        5'b01010:
          begin
            qq[0]   <= 1'b0;          //status ZF no use
            qq[1]   <= cy;            //carry
            qq[7:2] <= 6'b000000;     //no use 74181
            //qq[7..2]=(s[],m,cn0);     //74181 alu_op
          end  
        //5'b01011:
        // qq <=8'b00000000;            //ALU out
        5'b01100:
          qq <=i_reg[15:8];          //instruction register high 8 bit
        5'b01101:
          qq <=i_reg[7:0];           //instruction register low 8 bit  
        //5'b01111:
          //qq <=8'b00000000;       //CTRL and enable signal 1, ������ ua/upc
        //5'b11111:
          //qq <= 8'b00000000;      //CTRL and enable signal 2, ������ ua/upc 
        default: 
          qq <= 8'b00000000;
      endcase
    end

  SOFT soft1(qq[0],CBD[0]);  //�ӻ����Ա��������ڲ���Դ����
  SOFT soft2(qq[1],CBD[1]);
  SOFT soft3(qq[2],CBD[2]);
  SOFT soft4(qq[3],CBD[3]);
  SOFT soft5(qq[4],CBD[4]);
  SOFT soft6(qq[5],CBD[5]);
  SOFT soft7(qq[6],CBD[6]);
  SOFT soft8(qq[7],CBD[7]);
  
//2) use instance--���Ƽ� 2222222222222222222222222222  
 /* 
 \callback (.mal(ma[7:0]),
            .mah({3'b000,ma[12:8]}),
            .md(md),
            .acc(acc),
            //.act_reg0(),
            .tmp_reg1(tmp),
            .reg2(pc[7:0]),
            .reg3({4'b0000,pc[11:8]}),
            .alu_sop({6'b000000,cy,1'b0}),
            //.alu_out(),
            .irh(i_reg[15:8]),
            .irl(i_reg[7:0]),
            //.Ctrla(),
            .Ctrlb({6'b000000,wc,rc}),
            .AA(AA),
            .CBD(CBD)
            );

 */

//=========================================================================================
//=========================================================================================
//ʮһ micro_PROGRAM_Ctrl  ****************************************************************
  //A ��΢������� �� ���ڲ�ROM��΢������ƴ�����ʱ,���¾�,����Ҫע��,
  assign uA=0;
  //B ΢������ƴ��������ⲿʱ,��uD��uA, ���򱣳�ע��
    //assign uD=ud; 
    //  ��΢�湲��(����д��΢��),��ַ������3̬����(���õĸ�λ��ַ=0)����ѡ�� 1) �� 2) ��ʽ
    // 1) �� assign  
    //assign uA = RUN?(ua):11'bzzz_zzzz_zzzz; 
    // 2) ��74465  
    //\74465 uA_busl(.gn({~RUN,1'b0}),.a(ua[7:0]),.y(uA[7:0]));
    //\74465 uA_bush(.gn({~RUN,1'b0}),.a(ua[10:8]),.y(uA[10:8]));

  //c ΢������ƴ����������CPU_CORE �� ΢������ƴ��������ⲿʱ,ȫע���¶�����============  
    // ����,Ƕ�� ROM �� ΢������ƴ�����,��ѡ��� 1) �� 2) ��ʽ
    // asynchronism_ROM memory 
    //lpm_rom �⹦��: 
    //FUNCTION lpm_rom (address[LPM_WIDTHAD-1..0], 
    //                  inclock, outclock, memenab)
    //	WITH (LPM_WIDTH, LPM_WIDTHAD, LPM_NUMWORDS, 
    //        LPM_FILE, LPM_ADDRESS_CONTROL, LPM_OUTDATA)
    //	RETURNS (q[LPM_WIDTH-1..0]);

// 1) ֱ������   111111111111111111111111111 
/* 
\lpm_rom um (.address(ua),.q(ud));
  defparam
		um.LPM_WIDTH = 16,     //����λ��,ȡ������΢��λ��
		um.LPM_WIDTHAD = 5,    //��ַλ��,ȡ��΢����������               
		um.LPM_ADDRESS_CONTROL = "UNREGISTERED",  //�첽
		um.LPM_OUTDATA = "UNREGISTERED",          // ..
		um.LPM_FILE = "cpu8u_um.mif";  //΢�����루HEX���ļ�����ͬĿ¼��Ҫ·��
*/

// 2) ����ʵ��--���Ƽ� 2222222222222222222222
/*
\cpu_um_rom um(
               .address(ua),
	           .q(ud)
               );
*/

//===================================================================================
//===================================================================================
//ʮ��  Ƕ��SRAM ������--���Ƽ�******************************************************
   //ʹ��Ƕ��SRAM ������,�����ȴ��¾�,�Բ���д���� we,
   //    ֱ����д����(�����ѡͨ),��������д

   //wire we = wc & CK;

// A) �첽������˫��IO��SRAM(��)--�ֲ����� ##########################################
//   ע��: ��оƬ�ڲ���������3̬(������IO���������),
//         ������*.v�ļ���,Ƕ��SRAM�������첽������˫��IO��ʽ,
//         ������벻��3̬��������,���Ƕ��������θ�ֵ��
//         ����ͼ�α༭������----�����Զ���˫��ֳ����롢��������ڲ�����
//lpm_ram_io �⹦��:  
//FUNCTION lpm_ram_io (address[LPM_WIDTHAD-1..0], we, 
//                     inclock, outclock, outenab, memenab)
//	WITH (LPM_WIDTH, LPM_WIDTHAD, LPM_NUMWORDS, 
//        LPM_FILE, LPM_INDATA, LPM_ADDRESS_CONTROL, LPM_OUTDATA)
//	RETURNS (dio[LPM_WIDTH-1..0]);
//    we--д����,outenab--��ѡͨ,memenab--������Ƭѡ��ʡȱ,��=1���
 
// ��ѡ��� 1 �� 2 ��ʽ 
// 1) ֱ������  111111111111111111111111111111 
/*
\lpm_ram_io mm (.address(o_a),.we(we),.outenab(rc),.dio(o_d));
    defparam
		mm.LPM_WIDTH   = 8,                      //���ݿ��
		mm.LPM_WIDTHAD = 8,                      //��ַ���
		//mm.LPM_NUMWORD =256,                     //��������Ԫ��
        mm.LPM_INDATA = "UNREGISTERED",          //�������벻�Ĵ棬��Ҫinclock
		mm.LPM_ADDRESS_CONTROL = "UNREGISTERED", //��ַ���벻�Ĵ棬��Ҫinclock
		mm.LPM_OUTDATA = "UNREGISTERED",         //������ݲ��Ĵ棬��Ҫoutclock
		mm.LPM_FILE = "cpu8u_mm.mif",             //���е�Ŀ�꣨HEX���ļ�����ͬĿ¼��Ҫ·��
		mm.LPM_HINT = "UNUSED",                  //for VHDL 
        //mm.LPM_TYPE = "LPM_RAM_IO",              //���ͣ�˫��
        mm.USE_EAB	= "ON";                      //FPGA���ؿ�ʹ��
 */

//  2) ����ʵ��--���Ƽ�  2222222222222222222222
 /* 
 \cpu_mm_io mm_io(.address(ma),
	              .we(we),
	              .outenab(rc),
	              .dio(MA)
                  );

 */


// B) �첽�����ݵ�����d�����q�ֿ���SRAM(��)  ############################################
//   ע�⣺�÷�ʽ��CPU_Core��ʵ�����Ҫ����޸ģ�         
//         1)д�������������ݣ�d���ʹӴ�������������(q)Ҫ�ֿ�,
//           �����Ի���벻��3̬��������,���Ƕ��������θ�ֵ��
//         2)�������� o_d ���������� inout Ϊ input,��o_d=md=q
//           д�������ֱ���ɽ���Ĵ������ۼ��������
//               ��ʵ���ĺ�d(data)=ac=acc.
//         3)ע��ԭ���������3̬����74465���
     
//lpm_ram_dq �⹦��: 
//FUNCTION lpm_ram_dq (data[LPM_WIDTH-1..0], address[LPM_WIDTHAD-1..0], 
//                     inclock, outclock, we)
//	WITH (LPM_WIDTH, LPM_WIDTHAD, LPM_NUMWORDS, LPM_FILE, LPM_INDATA,
//        LPM_ADDRESS_CONTROL, LPM_OUTDATA)
//	RETURNS (q[LPM_WIDTH-1..0]);

// ��ѡ��� 1 �� 2 ��ʽ 
// 1) ֱ������  111111111111111111111111111111
/*
\lpm_ram_dq mm(.data(acc),
              .address(ma), 
              .we(we),
              //.inclock(_ck), //��ַ��we����Ĵ�clock����LPM_ADDRESS_CONTROL��Ӧ
              .q(md));
   defparam
        mm.LPM_WIDTH = 8,
		mm.LPM_WIDTHAD = 8,
		//mm.LPM_NUMWORDS = 256,
		mm.LPM_INDATA = "UNREGISTERED",
		mm.LPM_ADDRESS_CONTROL = "UNREGISTERED",
		mm.LPM_OUTDATA = "UNREGISTERED",
        mm.LPM_FILE = "cpu8u_mm.mif",
        mm.LPM_TYPE = "LPM_RAM_DQ",
		mm.LPM_HINT = "UNUSED";
  */

// 2) ����ʵ��--���Ƽ� 2222222222222222222222222
  /*   
   \cpu_mm_dq mm_dq(.address(ma),
	                .we(we),
	                .data(acc),
	                .q(md)
                   );
  */




endmodule

