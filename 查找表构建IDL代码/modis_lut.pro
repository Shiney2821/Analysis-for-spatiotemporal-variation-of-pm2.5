 ;;===============================================================================================
 ;;;  �ó�����ͨ��6s����У��ģ�����ɲ��ұ��Ա�������ܽ�����
 ;    �ó���������ý�Ϊ�򵥣����Ҫ��ϸ�Ĳ���������������
 ;    �Ľ�������1����ȡÿһ��Ӱ��ĽǶ���Ϣ�������ұ��������ȸ���
 ;             2������IDLֱ�ӵ���Fortran���Ե�6SԴ���򣬲������ɲ��ұ��ٶ����20������
 ;             3�������в��������úã���С����������һ���Ӵ�Ĳ��ұ����������磬һ������
 ;;;==============================================================================================
 PRO MODIS_LUT;,month,day,iwave,idatm,iaer,lutpath,lutname
   igeom=0;�Զ��弸������
   phi0=0;���Ƿ�λ��++++
   month=5;���·�
   day=17;������
   idatm=2;������ģʽ��γ���ļ�
   iaer=1;�����ܽ�ģʽ��½��
   v=0;���ܼ���
   xps=0;��Ŀ����߶�
   xpp=-1000;���ǲ�
   iwave=42;���Զ���1���벨�η�Χ�ͷ����ຯ��42Ϊmodis��red
   inhomo=0;���ر����ʾ�һ�ر�
   idirect=0;���޷���ЧӦ
   igroun=1;����ɫֲ��
   rapp=-2;���޴���У��
   tao=[0.0001,0.25,0.5,1.0,1.5,1.95];��550nm���ܽ���ѧ���
   asol=[0,12,24,36,48,60];��̫���춥��
   avis=[0,12,24,36,48,60];�������춥��
   phiv=[0,24,48,72,96,120,144,168,180];��̫����λ��(���Ƿ�λ��Ϊ0������Է�λ��ΪO��180)
   ; CD,lutpath
   cd,'C:\Users\Administrator\Desktop\6s_lut';�Լ�����6s.exe���ڵ��ļ���·��
   lutname='modis_lut.txt'
   OPENW,lutlun,lutname,/get_lun
   ;����ѭ������
   ;for a=0,2 do begin;��������ͨ��
   FOR b=0,5 DO BEGIN;550nm���ܽ���ѧ���
     FOR c=0,5 DO BEGIN;̫���춥��
       FOR d=0,5 DO BEGIN;�������춥��
         FOR e=0,8 DO BEGIN;��̫����λ��(���Ƿ�λ��Ϊ0������Է�λ��ΪO��180)
           txtname='in.txt'
           OPENW,lun,txtname,/get_lun
           PRINTF,lun,igeom
           PRINTF,lun,asol[c],phiv[e],avis[d],phi0,month,day
           PRINTF,lun,idatm
           PRINTF,lun,iaer
           PRINTF,lun,v
           PRINTF,lun,tao[b]
           PRINTF,lun,xps
           PRINTF,lun,xpp
           PRINTF,lun,iwave
           PRINTF,lun,inhomo
           PRINTF,lun,idirect
           PRINTF,lun,igroun
           PRINTF,lun,rapp
           FREE_LUN,lun
           SPAWN,'6s.exe<in.txt>out.txt',/hide ;����6s <>����Ϊdosϵͳ�µ��ض������     <���ļ���ȡ��������>��������д���ļ�
           txtname='out.txt'
           OPENR,lun,txtname,/get_lun
           temp=STRARR(1,120)
           READF,lun,temp
           tt=STRMID(temp[0,105],61,8)
           sA=STRMID(temp[0,111],61,8)
           rou=STRMID(temp[0,114],61,8)
           FREE_LUN,lun
           ;����Ϊ���䷽���е�P T S������̫���춥�ǣ������춥�ǣ���Է�λ�ǡ����ܽ���ѧ���
           PRINTF,lutlun,sA,tt,rou,asol[c],avis[d],phiv[e],tao[b]
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   ;  endfor
   FREE_LUN,lutlun
 END
 
 
 
 
