//±¾Í¨ÓÃÄ£°å½öÊ¹ÓÃĞ¾Æ¬ EPF10K30RC208
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
 //Ò»  ²ÎÊıËµÃ÷ ********************************************************************************
 //µ÷Èë cpu_core£¬±¾ÊµÀıÎª cpu8tv----µ¥±¶Ê±ÖÓµÄ×ÔÊ±Ğò  .clk(CK)
 //ĞÎ²Î¶Ë¿ÚÓÃ.ĞÎ²Î()±íÊ¾£¬ÆäÊıÄ¿È¡¾öcpu_coreµÄÊäÈëÊä³ö¶Ë¿ÚÊı£¬µ÷ÈëÊ±Òª¸ù¾İÄ¿±êcpu_core½øĞĞÔöÉ¾
 //    Èç CPUÊÇ12ÌõÒÔÉÏ»òÎ¢³ÌĞò¿ØÖÆ»òÆäËüÀàĞÍµÈÇé¿ö,»òÕß ¸ù¾İ²é´í¹Û²ìĞèÒªËæÊ±Ôö¼Ó¸ú×ÙµÄÄÚ²¿ĞÅÏ¢
 //Êµ²ÎµÄ´úÈë£ºÊµ²Î´úÈëÏàÓ¦¶Ë¿Ú()ÄÚ£¬ĞÔÖÊºÍ¿í¶ÈÒªÒ»ÖÂ
 //1)¿ÉÖ±½ÓÓÃ±¾ÎÄÊäÈëÊä³öĞÅºÅ×÷Êµ²Î´úÈëÈç.wc(WC)ÖĞµÄWC£¬
 //    Èç¹û²»±ãÖ±½ÓÓÃ±¾ÎÄ¼ş³öÈë¶Ë¿ÚĞÅºÅ´úÈë, ÈçT´úÈë._t()£¬¿ÉÊ¹ÓÃÄÚ²¿ÖĞ¼ä±äÁ¿t ´úÈë£¬¼´._t(t)£¬
 //        Òòµ±Ç°CPUÊÇÄÚ²¿Ê±Ğò£¬TÊÇÊä³ö£¬ÇÒT[3]¹¦ÄÜ²»ÔÙÍ¬t[3]¡£
 //    ×¢Òâ£ºÕâÖÖÇé¿ö×îÖÕÒª°ÑÄÚ²¿ÖĞ¼ä±äÁ¿¸³¸ø±¾ÎÄµÄÊä³öĞÅºÅ»ò½«±¾ÎÄµÄÊäÈëĞÅºÅ¸³¸øÄÚ²¿ÖĞ¼ä±äÁ¿
 //          ·ñÔò´íÎó½«±»Òş²Øµ½±àÒëºóµÄwarningÄÚ£¬³öÏÖĞí¶à·ÇÉè¼ÆÒªÇóµÄwarning£ºPrimitive 'xxx'stuck at GND.
 //2)ÓÃÄÚ²¿ĞÅÏ¢Èç¸ú×Ù»ØÊÕµÄĞÅÏ¢.ac(acc)ÖĞµÄacc
 //3)·²Êµ²ÎÊ¹ÓÃÄÚ²¿ÖĞ¼ä±äÁ¿»òÄÚ²¿ĞÅÏ¢±äÁ¿Èçt¡¢accµÈ£¬
 //  ±ØĞëÔÚµ÷ÓÃÊµÀıCPUºË¶ÎÇ°ÉùÃ÷£¬×¢ÒâĞÅºÅµÄĞÔÖÊºÍ¿í¶ÈµÄÒ»ÖÂĞÔ£¬²¢×¢ÒâĞÅºÅµÄĞÔÖÊºÍ¿í¶ÈµÄÒ»ÖÂĞÔ¡£
 //      ĞĞ²ÎÃûºÍÊµ²ÎÃû¿ÉÍ¬Ãû£¬µ«²»¿É»ì
 
 //¶ş  ÄÚ²¿ÖĞ¼ä±äÁ¿ĞÔµÄÊµ²ÎÉùÃ÷ ****************************************************************
  wire        cy;
  wire [3:0]  t;
  wire [7:0]  tmp,acc;
  wire [11:0] pc; 
  wire [12:0] o_a;
  wire [15:0] i_reg;
//Î¢³ÌĞò¿ØÖÆÊ±Ôö¼ÓÉùÃ÷
  //wire [7:0]  ua;   //or upc
  //wire [15:0] ud;   //or uir(Î¢³ÌĞò¿ØÖÆ´æÖüÆ÷Éè¼ÆÔÚCPU_CORE)
//ÓÃÇ¶ÈëSRAM ×÷Ö÷´æÊ±Ôö¼ÓÉùÃ÷
  //wire        wc,rc;
  //wire [7:0]  md;
  //wire [7:0]  ma;  //¸ù¾İ¼ì²â³ÌĞòĞèÒª¶¨µØÖ·Î»Êı

//Èı  µ÷ÈëÄãÉè¼ÆµÄcpu_core ******************************************************************** 
 \cpu8tv cpu_core(  //µ±Ç°cpu8tv: µ¥±¶Ê±ÖÓµÄ×ÔÊ±Ğò,×éºÏÂß¼­¿ØÖÆ
                   .reset(Reset),       //Ö±½Ó´úÈë
                   .clk(CK),            //Ö±½Ó´úÈë. or .ck(CK) when outside timer£¬
                   ._t(t),              //ÄÚ²¿ÖĞ¼ä±äÁ¿,×ÔÊ±Ğò£¬ÍâÊ±Ğò ._t(T)
                   //.ck(return_ck),      //Ö±½Ó´úÈë¡£×ÔÊ±Ğò, ·µ»Øµ½Íâ²¿
                   .end_i(I_END),       //Ö±½Ó´úÈë,±äÖÜÆÚÒ»ÌõÖ¸Áî½áÊø   
                   .wc(WC),             //Ö±½Ó´úÈë
                   .rc(RC),             //  ..
                   .o_d(MD),            //  ..
                   .o_a(o_a),           //ÄÚ²¿ÖĞ¼ä±äÁ¿,ÒòÆ½Ì¨MAÊÇinout
                   .pc(pc),             //ÄÚ²¿ÖĞ¼ä±äÁ¿,Òò¸ú×Ù»ØÊÕ,ÄÚ²¿¶ÏµãÂß¼­ĞèÒª
                   .i_reg(i_reg),       //¸ú×Ù»ØÊÕµÄĞÅÏ¢
                   .ac(acc),            //  ..
                   .cy(cy),             //  ..
                   .tp(tmp),            //  ..
                   //.ua(ua),             //ÄÚ²¿ÖĞ¼ä±äÁ¿ »ò ¸ú×Ù»ØÊÕ     or (upc)
                   //.ud(ud),             //  ..                         or (uir) 
                   //.uclk(uCLK),         //Ö±½Ó´úÈë, when outside timer 
                   //.ucp(uCP),           //  ..      ÒÔÏÂ¾ùÖ±½Ó´úÈ    
                   .run(RUN),   //When RUN=0£¬under CP, pc <= oa;
                   .cp(CP),     //pulse: Debug setup first address of program 
                   .oa(MA)      //when MA_input,used low 10 bit only when 1-2connect of equipment_JP2 
                 );

//ËÄ  ´úÈËËµÃ÷: *********************************************************************************
//1£©ÄÚÍâÊ±ĞòÎÊÌâ----Ê¹ÓÃÓëÉèÖÃ: ¼û Îå¶Î 
//   Ê±ĞòÉè¼ÆÔÚCPUÄÚ£º.clk(CK)--Ö÷Ê±ÖÓÊäÈë,Éú³ÉµÄÖÜÆÚ._t(t) ÊÇÊä³öµ½Íâ²¿ 
//                    .ck(return_ck)--ÖÜÆÚÄÚÂö³å,·µ»ØÊä³öµ½Íâ²¿  
//   Ê±ĞòÍâ²¿Ìá¹©£º   .ck(CK)--ÖÜÆÚÄÚÂö³å, ._t(T)  ¾ùÊÇÊäÈë
//   

//2) return_ck to external
//   Èç¹ûÊÇ×ÔÊ±Ğò¡¢·Çµ¥±¶Ê±ÖÓ£¬´ò¿ª¶Ë¿Ú .ck(return_ck)£¬×¢ÏúÏÂÃæÓï¾ä£¬·ñÔò²»×¢Ïú
     assign return_ck= CK;   //µ¥±¶Ê±ÖÓ×ÔÊ±ĞòÊ±

//3) Èç¹ûCPUÓÃ¹Ì¶¨ÖÜÆÚ£¬¿É×¢Ïú.end_i(I_END), °´Çé¿öÑ¡ÏÂÃæÒ»¾ä´ò¿ª£º
     //assign I_END = t[max]; //ÄÚ²¿Ê±Ğò
     //assign I_END = T[max]; //Íâ²¿Ê±Ğò

//4) Ê¹ÓÃÇ¶Èë SRAM ×÷Ö÷´æ
//   A Çë´ò¿ªÓÃÇ¶ÈëSRAM ×÷Ö÷´æÊ±ÓÃµÄÖĞ¼ä±äÁ¿ÉùÃ÷,²¢´úÈë:.wc(wc),.rc(rc),.o_d(md),.o_a(ma),
//   B ¶ÔMAµÄÊä³ö´¦ÀíÎª3Ì¬¸ß×è,¼û Áù ¶Î
//         ÓÃ74465Ê±,ÆäÖĞ 1'b0 => 1'b1,ÒÔ½ûÖ¹´ò¿ª3Ì¬ÃÅ(¸ß×è)
//       »òÓÃassign, ÆäÖĞ RUN  => 1'b0,½öÑ¡Ôñ¸ß×é
//   C ¶ÔMDµÄÊä³ö´¦ÀíÎª3Ì¬¸ß×è,Çë´ò¿ªÏÂÓï¾ä:
       //\74465 MD_busl(.gn({1'b1,1'b0}),.a(8'hFF),.y(MD));  
//   D ¶ÔCPU_CoreµÄÊµÀıÉè¼ÆµÄĞŞ¸Ä£¨Ö÷ÒªÊÇ·ÃÎÊ´æÖüÆ÷µÄÊı¾İÓÉË«Ïò¸ÄÎª¶Á¡¢Ğ´·Ö¿ª£©,¼ûÊ®¶ş¶Î B
//        ²¢°´ÒªÇó×÷´ò¿ª»ò×¢ÏúÏàÓ¦µÄÂß¼­ÃèÊöÓï¾ä¶Î 
//   E ÈôÇ¶Èë SRAM ×÷Ö÷´æÒÑÉè¼ÆÔÚCPU_CoreµÄÊµÀıÖĞ, ·µ»Ø.wc(wc),.rc(rc),.o_d(md),.o_a(ma),
//         ÓÃÓÚ¸ú×Ù»ØÊÕ
//   F ¶ÔWC£¬RCµÄÊä³öÎŞĞ´¦Àí----¼´´ò¿ªÏÂ2¸öÓï¾ä
       //assign WC=1'b0;
       //assign RC=1'b0;
//   G ¹ş·ğHV½á¹¹µÄ³ÌĞòºÍÊı¾İ´æÖüÆ÷Éè¼ÆÀàÍ¬Ç¶Èërom¡¢SRAM, SRAMÒ²¿ÉÑ¡ÓÃÍâ²¿SRAM.
//         ÆäÂß¼­ÃèÊö¿ÉÔÚ±¾ÎÄ,Ò²¿ÉÔÚCPU_CoreµÄÊµÀıÖĞ,Ò²¿É½»²æ·ÅÖÃ¡£
//         ÊµÀı´úÈë¶Ë¿ÚÓë²ÎÊı¡¢ËùĞèµÄ¸ú×Ù»ØÊÕ¡¢Ïà¹Ø´¦Àí£¬¾İCPU_CoreµÄÊµÀıÉè¼Æ¡¢²Î¿¼±¾ÎÄÀàËÆÇé¿ö½øĞĞ¡£
//   H Ê¹ÓÃ SRAM ×÷Ö÷´æÊ±,¶ÁÖ÷´æ(Íâ²¿)²é¿´ÔËĞĞ½á¹û·½·¨ÒÑ²»¿ÉÓÃ,±ØĞë:
//     a ¶Ô²âÊÔ³ÌĞò*.bin,ÒªÔÚ×ÔÉíÑ­»·½áÊø³ÌĞòÇ°°Ñ½á¹û(Èç¹ûÓĞ¼Ä´æÆ÷×é)»ò½á¹ûÀÛ¼Óµ½ÀÛ¼ÓÆ÷¿´¸ú×Ù»ØÊÕĞÅÏ¢.
//     b Èç½ûÖ¹Íâ²¿Ö÷´æÆ¬Ñ¡(¸Ä½Ó¿ÚEPM7256Âß¼­),RC¸ÄÎªÊäÈë,RUN=0Ê±Debug¿É¶ÁSRAM,µ«±È½ÏÂé·³.

//5) ²»ÓÃµÄ¸ßÎ»µØÖ·o_a ºÍ pc ´¦Àí£¨Èç4ÌõÖ¸ÁîµÄCPU£©£º´ò¿ªÏÂÃæÁ½Óï¾ä
     //assign o_a[12:0]=5'b00000;
     //assign pc[11:0]=4'b0000;

//6) ²»ÓÃµÄµÍ×Ö½ÚÖ¸Áî¼Ä´æÆ÷ i_reg ´¦Àí £¨Èç4ÌõÖ¸ÁîµÄCPU£©£º´ò¿ªÏÂÃæÓï¾ä
     //assign i_reg[7:0] = 8'h00;

//7) ¸ú×Ù»ØÊÕĞÅÏ¢ÕıºÃÊÇÄ£°å·ÂÕæÊ±µÄÈë³öĞÅÏ¢£¬ÌØ±ğÊÇÎª¹Û²ìÄÚ²¿ĞÅÏ¢¶øÊ¹ÆäÊä³ö¡£
//   ĞÂÔöµÄ¸ú×Ù»ØÊÕĞÅÏ¢ÔÚºóÃæ Ê®¶Î <ĞÅÏ¢¸ú×Ù»ØÊÕ>¶ÎÌí¼ÓÊä³ö£º
//       ¿ÉÓÃÉĞÎ´ÓÃµÄµØÖ·µ¥Ôª£¬
//       »òÕßÓÃµ±Ç°ÒÑ²»ÓÃµÄµØÖ·µ¥Ôª¡£
//×¢:PCÊÇÊä³öÊ±,¸ú×ÙÔÚÍâ²¿½øĞĞ,
//   PCÊäÈëÊ±,Debug´°¿Ú³ÌĞò¼ÆÊıÆ÷ÏÔÊ¾µÄÄÚÈİÊµ¼Ê²»ÊÇCPU_PC,ËùÒÔ±ØĞëÔÚ<ĞÅÏ¢¸ú×Ù»ØÊÕ>¶ÎÌí¼Ó»ØÊÕ

//8) Ê¹ÓÃÎ¢³ÌĞò¿ØÖÆµÄÎ¢´æ: 
//   a Çë´ò¿ªÎ¢³ÌĞòÓÃµÄÖĞ¼ä±äÁ¿ÉùÃ÷ºÍ´úÈë¶Ë¿Ú,ÈçÊÇ×ÔÊ±Ğò(·ÇÍâ²¿),Ôò.uclk()ºÍ.ucp()²»´ò¿ª.
//     ÈôÎ¢´æÉè¼ÆÔÚCPU_CoreµÄÊµÀıÖĞ,Ôò¸ú×Ù»ØÊÕÒËÓÃupc,uir
//   b ¼ûÊ®Ò» micro_PROGRAM_Ctrl¶Î,°´ÒªÇó×÷´ò¿ª»ò×¢ÏúÏàÓ¦µÄÂß¼­ÃèÊöÓï¾ä¶Î
 
//9) Èç¹ûÖªµÀ²âÊÔ³ÌĞòÆô¶¯Ê×µØÖ·£¬¿ÉÔÚcpu_coreÄÚÓÃÒì²½¸´Î»ÉèÖÃµ½pc£ºpc_o <= 12'h00e;
//       ²¢×¢Ïú.run(RUN),.cp(CP),.oa(MA), 
//   ·ñÔò ÔÚcpu_coreÄÚÔö¼ÓÉèÖÃÓï¾ä£ºpc_o <= {2'b00,oa[9:0];    ¾ù¼ûÏÂ 
/*
  wire _ck = ck | cp£»  //cp ÊÇÏÂ½µµÄºóÑØÓĞĞ,ËùÒÔÏÂÃæ±ØĞëÊÇ negedge _ck 
  always @(negedge _ck or posedge reset ) 
   begin
      if ( reset)
        pc_o <= 12'h000; 
        //pc_o <= 12'h00e; //ÖªµÀ²âÊÔ³ÌĞòÆô¶¯Ê×µØÖ·=00e H   
      else if (run==0)     //CPU²»ÔËĞĞÊ±, ½Ó¿Ú·¢Æô¶¯Ê×µØÖ·£¬ÔÚCPÏÂ´òÈëPC
        pc_o <= {2'b00,oa[9:0]; //Æ½Ì¨JP4µÄ1-2Á¬½öÓÃµÍ10Î»
      else
      casex ({irh[7:5],t,cy_reg})
        ¡­¡­¡­¡­¡­¡­
*/

//10£©Èç¹ûCPUÊ¹ÓÃÍâ²¿¼Ä´æÆ÷×é----¼ûÆß¶Î
//    ³ÌĞò¶ÏµãÉèÖÃÓëËùÔÚÎ»ÖÃ(ÔÚCPU_core»ò±¾Ä£°å»òÍâ²¿)----¼û°Ë¶Î
//    Í£»ú´¦Àí----¼û¾Å¶Î 

 
//Îå timer ÄÚ²¿»òÍâ²¿µÄ¿ØÖÆ ******************************************************************
//if CPU is inside timer,then mode_t=0,else =1; 
   wire mode_t=0;  //same with t_mode, =0, because cpu8tv is inside timer
   assign t_mode = mode_t; 

//FUNCTION TRI (in, oe)
//   RETURNS (out);
\tri _t0(.in(t[0]),.oe(!mode_t),.out(T[0]));
\tri _t1(.in(t[1]),.oe(!mode_t),.out(T[1]));
\tri _t2(.in(t[2]),.oe(!mode_t),.out(T[2]));
\tri _t3(.in(t[3]),.oe(!mode_t),.out(T[3]));
 
//Áù  µØÖ·MA±ØĞë×÷3Ì¬Ë«Ïò´¦Àí£¬¿ÉÑ¡Ôñ 1) »ò 2) ***************************************************
//    ÕâÊÇÒò´æÖüÆ÷¹²ÏíºÍÉèÖÃ³ÌĞòÆô¶¯Ê×µØÖ·ĞèÒª
// 1) ÓÃ74465
//\74465 MA_busl(.gn({~RUN,1'b0}),.a(o_a[7:0]),.y(MA[7:0]));    //ÈôĞè½ûÖ¹´ò¿ª3Ì¬ÃÅ,Ôò1'b0 => 1'b1
//\74465 MA_bush(.gn({~RUN,1'b0}),.a(o_a[12:8]),.y(MA[12:8]));  //  ..
// 2) ÓÃassign
assign MA = RUN?(o_a):13'bz_zzzz_zzzz_zzzz;          //only 10k30 ÈôĞèÊä³ö¸ß×è,Ôò RUN  => 1'b0

//Æß  Íâ²¿¼Ä´æÆ÷×é¿ØÖÆ **************************************************************************
//Èç¹ûµ±Ç°Ê¹ÓÃÍâ²¿¼Ä´æÆ÷×é£¬ÔÚµ÷Èëcpu_coreµÄ¶Ë¿ÚÖĞ,
//    ÈçEN_W,EN_R,R_A,RD½«×÷Êµ²Î´úÈë,Çë×¢ÏúÏÂÃæ 4¾ä:
//Èç¹ûµ±Ç°²»Ê¹ÓÃÍâ²¿¼Ä´æÆ÷×é,ÓÃÒÔÏÂ 4¾ä ×÷ÎŞĞ´¦Àí:
assign EN_W=1;
assign EN_R=1;
assign R_A=2'b00;
// ¼Ä´æÆ÷Êı¾İRDµÄ3Ì¬´¦Àí ¿ÉÑ¡Ôñ 1 »ò 2 »ò 3
//assign RD = 1'b0 ? 8'h00:8'hzz;                     //1 for chip_EPM7256 and chip_10K30,have warning  
//\74465 RD_bus(.gn({1'b1,1'b0}),.a(8'hFF),.y(RD));   //2 for chip_EPM7256 and chip_10K30,have warning
assign RD = 8'hzz;                                    //3 for chip_10K30 only, no warning    


//°Ë  brekpoint logic ´¦Àí*************************************************************************

//1) Èç¹û brekpoint logic ÔÚÍâ²¿,´ò¿ª assign PC=pc;----ÍÆ¼ö 
//       Í¬Ê± moduleµÄPCÊôĞÔÉùÃ÷Òª ´ò¿ª 1),×¢Ïú 2)
//          ×¢Ïú brekpoint logic ÃèÊö¶Î
//2) Èç¹û brekpoint logic ÔÚ±¾Ä£°å,PC[10:0]ÊÇÊäÈë,Òª×¢Ïú assign PC=pc; 
//       Í¬Ê± module()ÄÚÔö¼ÓPC_BP,Ç°ÃæµÄPCÊôĞÔÉùÃ÷Òª ×¢Ïú 1),´ò¿ª 2)
//          ´ò¿ª brekpoint logic ÃèÊö¶Î 1) »ò 2) 
//       ×¢Òâ£ºbrekpoint logic ÔÚÄÚ²¿¼´2)Óë3)--²»ÍÆ¼öÊ¹ÓÃ
//3) Èç¹û ¶ÏµãÂß¼­Éè¼ÆÔÚCPU_core, module()ÄÚÔö¼ÓPC_BP,Ç°ÃæµÄPCÊôĞÔÉùÃ÷Òª ×¢Ïú 1),´ò¿ª 2) 
//       PC[10:0]°´ĞÂ¶¨ÒåÒªÊäÈëµ½CPU_core,PC_BP´ÓCPU_coreÊä³ö,Òª×¢Ïú assign PC=pc
//       ÔÚµ÷Èëcpu_coreÖĞÒªÔö¼ÓÏàÓ¦µÄ¶Ë¿ÚÓë²ÎÊı:       
//           .aa(AA),._d(PC[7:0]),..wr(PC[8]),.cs(PC[10]),.pc_bt(PC_BP)     
//   ×¢Òâ: Îª±£Ö¤PC[10:0],PC_BP·ûºÏ¶ÏµãÔÚÄÚ²¿¼´2)Óë3)µÄ¶¨ÒåÓë¹¦ÄÜ.
//         cpu_chip¼´EPF10K30±à³Ì(ÉÕĞ´)Ç°,ÏÈÓÃfaceN_usbÎÄ¼ş¼ĞµÄface_b.pof±à³Ì½Ó¿ÚÓÃEPM7256    
  
     assign PC=pc;

//brekpoint logic in cpu_chip  µÄÃèÊö======================================== 
//brekpoint registers of USB_8051 ctrl_address a9=1
//±¾Ä£°åĞÅºÅ ¶¨Òå     CPU_coreµÄĞÅºÅÓëÉùÃ÷
// AA[4:0]--address----input  aa[4:0];
// PC[7:0]--data-------input  _d[7:0];
// PC[8]----write------input  wr; 
// PC[10]---Æ¬Ñ¡-------input  cs; 
// PC_BP----¶Ïµã-------output pc_bP;

// ¿ÉÑ¡Ôñ 1) »ò 2) Á½ÖÖ·½Ê½ 

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

// 2) use instance--²»ÍÆ¼ö  2222222222222222222222
  /*
  \bkpt bp(.reset(Reset),
           .AA0(AA[0]),
           .PC_BP(PC_BP),
           .chip_PC(PC[10:0]),
           .cpu_pc(pc),
           );
  */

  //¾Å  Í£»ú´¦Àí ****************************************************************************
  //When online test of cpu run in cpu experiment system  need
  assign STOP  = 1'b0;  // When no STOP instruction else = OP_code of STOP instruction

   
  //Ê® ĞÅÏ¢¸ú×Ù»ØÊÕ£ºfeedback cpu'S inside information  from CPU core************************
  //       ¿É¸ù¾İĞèÒª,×Ô¶¨Òå¸ú×Ù»ØÊÕµÄĞÅÏ¢
  //       ¿ÉÑ¡Ôñ 1) »ò 2) Á½ÖÖ·½Ê½
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
          //qq <= 0;                     //REG0  ¿ÉÓÃ×÷ ud/uir[7:0]  
        //5'b00111:
          //qq <= 0;                     //REG1  ¿ÉÓÃ×÷ ud/uir[15:8]
        //5'b01000:
          //qq <= 0;                     //REG2  ¿ÉÓÃ×÷ ud/uir[23:16]    
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
          //qq <=8'b00000000;       //CTRL and enable signal 1, ¿ÉÓÃ×÷ ua/upc
        //5'b11111:
          //qq <= 8'b00000000;      //CTRL and enable signal 2, ¿ÉÓÃ×÷ ua/upc 
        default: 
          qq <= 8'b00000000;
      endcase
    end

  SOFT soft1(qq[0],CBD[0]);  //¼Ó»º³åÒÔ±ãÓÚÆ÷¼şÄÚ²¿×ÊÔ´·ÖÅä
  SOFT soft2(qq[1],CBD[1]);
  SOFT soft3(qq[2],CBD[2]);
  SOFT soft4(qq[3],CBD[3]);
  SOFT soft5(qq[4],CBD[4]);
  SOFT soft6(qq[5],CBD[5]);
  SOFT soft7(qq[6],CBD[6]);
  SOFT soft8(qq[7],CBD[7]);
  
//2) use instance--²»ÍÆ¼ö 2222222222222222222222222222  
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
//Ê®Ò» micro_PROGRAM_Ctrl  ****************************************************************
  //A ·ÇÎ¢³ÌĞò¿ØÖÆ »ò ÓÃÄÚ²¿ROM×÷Î¢³ÌĞò¿ØÖÆ´æÖüÆ÷Ê±,´ò¿ªÏÂ¾ä,·ñÔòÒª×¢Ïú,
  assign uA=0;
  //B Î¢³ÌĞò¿ØÖÆ´æÖüÆ÷ÔÚÍâ²¿Ê±,´ò¿ªuDºÍuA, ·ñÔò±£³Ö×¢Ïú
    //assign uD=ud; 
    //  ÒòÎ¢´æ¹²Ïí(Ö÷»úĞ´¶ÁÎ¢´æ),µØÖ·±ØĞë×÷3Ì¬´¦Àí(²»ÓÃµÄ¸ßÎ»µØÖ·=0)£¬¿ÉÑ¡Ôñ 1) »ò 2) ĞÎÊ½
    // 1) ÓÃ assign  
    //assign uA = RUN?(ua):11'bzzz_zzzz_zzzz; 
    // 2) ÓÃ74465  
    //\74465 uA_busl(.gn({~RUN,1'b0}),.a(ua[7:0]),.y(uA[7:0]));
    //\74465 uA_bush(.gn({~RUN,1'b0}),.a(ua[10:8]),.y(uA[10:8]));

  //c Î¢³ÌĞò¿ØÖÆ´æÖüÆ÷Éè¼ÆÔÚCPU_CORE »ò Î¢³ÌĞò¿ØÖÆ´æÖüÆ÷ÔÚÍâ²¿Ê±,È«×¢ÏúÏÂ¶ÎÃèÊö============  
    // ·ñÔò,Ç¶Èë ROM ×÷ Î¢³ÌĞò¿ØÖÆ´æÖüÆ÷,¿ÉÑ¡Ôñ´ò¿ª 1) »ò 2) ·½Ê½
    // asynchronism_ROM memory 
    //lpm_rom ¿â¹¦ÄÜ: 
    //FUNCTION lpm_rom (address[LPM_WIDTHAD-1..0], 
    //                  inclock, outclock, memenab)
    //	WITH (LPM_WIDTH, LPM_WIDTHAD, LPM_NUMWORDS, 
    //        LPM_FILE, LPM_ADDRESS_CONTROL, LPM_OUTDATA)
    //	RETURNS (q[LPM_WIDTH-1..0]);

// 1) Ö±½ÓÃèÊö   111111111111111111111111111 
/* 
\lpm_rom um (.address(ua),.q(ud));
  defparam
		um.LPM_WIDTH = 16,     //Êı¾İÎ»Êı,È¡¾öËùĞèÎ¢ÂëÎ»Êı
		um.LPM_WIDTHAD = 5,    //µØÖ·Î»Êı,È¡¾öÎ¢³ÌĞò×ÜÌõÊı               
		um.LPM_ADDRESS_CONTROL = "UNREGISTERED",  //Òì²½
		um.LPM_OUTDATA = "UNREGISTERED",          // ..
		um.LPM_FILE = "cpu8u_um.mif";  //Î¢³ÌĞòÂë£¨HEX£©ÎÄ¼ş£¬ÔÚÍ¬Ä¿Â¼²»ÒªÂ·¾¶
*/

// 2) µ÷ÓÃÊµÀı--²»ÍÆ¼ö 2222222222222222222222
/*
\cpu_um_rom um(
               .address(ua),
	           .q(ud)
               );
*/

//===================================================================================
//===================================================================================
//Ê®¶ş  Ç¶ÈëSRAM ×÷Ö÷´æ--²»ÍÆ¼ö******************************************************
   //Ê¹ÓÃÇ¶ÈëSRAM ×÷Ö÷´æ,ÇëÊ×ÏÈ´ò¿ªÏÂ¾ä,ÒÔ²úÉúĞ´Âö³å we,
   //    Ö±½ÓÓÃĞ´ÃüÁî(ÔÊĞí»òÑ¡Í¨),½«»á´íÎóµÄĞ´

   //wire we = wc & CK;

// A) Òì²½¡¢Êı¾İË«ÏòIOµÄSRAM(¿â)--ÏÖ²»¿ÉÓÃ ##########################################
//   ×¢Òâ: ÒòĞ¾Æ¬ÄÚ²¿²»ÄÜÃèÊö3Ì¬(½öÄÜÔÚIOÈë³ö½ÅÃèÊö),
//         ËùÒÔÔÚ*.vÎÄ¼şÄÚ,Ç¶ÈëSRAM²»ÄÜÓÃÒì²½¡¢Êı¾İË«ÏòIO·½Ê½,
//         ·ñÔò±àÒë²»ÊÇ3Ì¬Çı¶¯´íÎó,¾ÍÊÇ¶ÔÊı¾İÁ½´Î¸³Öµ¡£
//         µ«ÔÚÍ¼ĞÎ±à¼­Æ÷¿ÉÓÃ----±àÒë×Ô¶¯½«Ë«Ïò·Ö³ÉÊäÈë¡¢Êä³öÁ½¸öÄÚ²¿±äÁ¿
//lpm_ram_io ¿â¹¦ÄÜ:  
//FUNCTION lpm_ram_io (address[LPM_WIDTHAD-1..0], we, 
//                     inclock, outclock, outenab, memenab)
//	WITH (LPM_WIDTH, LPM_WIDTHAD, LPM_NUMWORDS, 
//        LPM_FILE, LPM_INDATA, LPM_ADDRESS_CONTROL, LPM_OUTDATA)
//	RETURNS (dio[LPM_WIDTH-1..0]);
//    we--Ğ´Âö³å,outenab--¶ÁÑ¡Í¨,memenab--´æÖüÆ÷Æ¬Ñ¡¿ÉÊ¡È±,¾ù=1ÓĞĞ
 
// ¿ÉÑ¡Ôñ´ò¿ª 1 »ò 2 ·½Ê½ 
// 1) Ö±½ÓÃèÊö  111111111111111111111111111111 
/*
\lpm_ram_io mm (.address(o_a),.we(we),.outenab(rc),.dio(o_d));
    defparam
		mm.LPM_WIDTH   = 8,                      //Êı¾İ¿í¶È
		mm.LPM_WIDTHAD = 8,                      //µØÖ·¿í¶È
		//mm.LPM_NUMWORD =256,                     //´æÖüÆ÷µ¥ÔªÊı
        mm.LPM_INDATA = "UNREGISTERED",          //Êı¾İÊäÈë²»¼Ä´æ£¬²»Òªinclock
		mm.LPM_ADDRESS_CONTROL = "UNREGISTERED", //µØÖ·ÊäÈë²»¼Ä´æ£¬²»Òªinclock
		mm.LPM_OUTDATA = "UNREGISTERED",         //Êä³öÊı¾İ²»¼Ä´æ£¬²»Òªoutclock
		mm.LPM_FILE = "cpu8u_mm.mif",             //ÔËĞĞµÄÄ¿±ê£¨HEX£©ÎÄ¼ş£¬ÔÚÍ¬Ä¿Â¼²»ÒªÂ·¾¶
		mm.LPM_HINT = "UNUSED",                  //for VHDL 
        //mm.LPM_TYPE = "LPM_RAM_IO",              //ÀàĞÍ£ºË«Ïò
        mm.USE_EAB	= "ON";                      //FPGAÒş²Ø¿éÊ¹ÓÃ
 */

//  2) µ÷ÓÃÊµÀı--²»ÍÆ¼ö  2222222222222222222222
 /* 
 \cpu_mm_io mm_io(.address(ma),
	              .we(we),
	              .outenab(rc),
	              .dio(MA)
                  );

 */


// B) Òì²½¡¢Êı¾İµÄÊäÈëdÓëÊä³öq·Ö¿ªµÄSRAM(¿â)  ############################################
//   ×¢Òâ£º¸Ã·½Ê½¶ÔCPU_CoreµÄÊµÀıÉè¼ÆÒªÇóµÄĞŞ¸Ä£º         
//         1)Ğ´µ½´æÖüÆ÷µÄÊı¾İ£¨d£©ºÍ´Ó´æÖüÆ÷¶ÁµÄÊı¾İ(q)Òª·Ö¿ª,
//           ·ñÔòÈÔ»á±àÒë²»ÊÇ3Ì¬Çı¶¯´íÎó,¾ÍÊÇ¶ÔÊı¾İÁ½´Î¸³Öµ¡£
//         2)Êı¾İ×ÜÏß o_d ÊôĞÔÉùÃ÷¸Ä inout Îª input,¼´o_d=md=q
//           Ğ´Êä³öÊı¾İÖ±½ÓÓÉ½á¹û¼Ä´æÆ÷ÈçÀÛ¼ÓÆ÷µÈÊä³ö
//               ±¾ÊµÀı¸Äºód(data)=ac=acc.
//         3)×¢ÏúÔ­Êı¾İÊä³öÓÃ3Ì¬»º³å74465Óï¾ä
     
//lpm_ram_dq ¿â¹¦ÄÜ: 
//FUNCTION lpm_ram_dq (data[LPM_WIDTH-1..0], address[LPM_WIDTHAD-1..0], 
//                     inclock, outclock, we)
//	WITH (LPM_WIDTH, LPM_WIDTHAD, LPM_NUMWORDS, LPM_FILE, LPM_INDATA,
//        LPM_ADDRESS_CONTROL, LPM_OUTDATA)
//	RETURNS (q[LPM_WIDTH-1..0]);

// ¿ÉÑ¡Ôñ´ò¿ª 1 »ò 2 ·½Ê½ 
// 1) Ö±½ÓÃèÊö  111111111111111111111111111111
/*
\lpm_ram_dq mm(.data(acc),
              .address(ma), 
              .we(we),
              //.inclock(_ck), //µØÖ·ºÍweÊäÈë¼Ä´æclock£¬ÓëLPM_ADDRESS_CONTROL¶ÔÓ¦
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

// 2) µ÷ÓÃÊµÀı--²»ÍÆ¼ö 2222222222222222222222222
  /*   
   \cpu_mm_dq mm_dq(.address(ma),
	                .we(we),
	                .data(acc),
	                .q(md)
                   );
  */




endmodule

