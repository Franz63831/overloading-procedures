       // --------------------------------------------------------------------------
       // Beispiel für overlaod von Funktionen 
       // entnommen von Scott Klement: https://www.scottklement.com/presentations/#OVERLOAD
       // --------------------------------------------------------------------------

       CTL-OPT DFTACTGRP(*NO) option(*srcstmt);


       DCL-PR format_date        VARCHAR(100);
          dateParm               DATE CONST;
       END-PR;

       DCL-PR format_time        VARCHAR(100);
          timeParm               TIME CONST;
       END-PR;

       dcl-pr format_dateUSA     varchar(100);
          dateParm               DATE const;
       end-pr;

       DCL-PR format_message     VARCHAR(100);
          msgid                  CHAR(7)      CONST;
          replacement_text       VARCHAR(100) CONST OPTIONS(*NOPASS);
          message_file           char(20)     CONST OPTIONS(*NOPASS);
       END-PR;

       DCL-PR format             VARCHAR(100)
              OVERLOAD( format_time
                      : format_date
                      : format_message);


       DCL-S result              varchar(50);


       // --------------------------------------------------------------------------
       // OVERLOAD DETAIL
       // --------------------------------------------------------------------------

       result = format(%date());      // 1
       result = 'Datum: ' + result;
       dsply result;
       result = format(%time());      // 2
       result = 'Time : ' + result;
       dsply result;
       result = format('CPF2105' : 'PRDMAST   QUSRSYS   FILE   '); // 3
       dsply result;
       result = format_dateUSA(%date());
       result = 'US-Date: ' + result;
       dsply result;


       *inlr = *on;

       // --------------------------------------------------------------------------

       dcl-proc format_date;
         dcl-pi *n varchar(100);
           dateParm DATE CONST;
         end-pi;
         return %char(dateParm:*ISO);
       end-proc;
       // --------------------------------------------------------------------------

       dcl-proc format_time;
         dcl-pi *n varchar(100);
           timeParm TIME const;
         end-pi;
         return %char(timeParm:*HMS:);
       end-proc;

       // --------------------------------------------------------------------------

       dcl-proc format_dateUSA;
         dcl-pi *n varchar(100);
           dateParm DATE const;
         end-pi;
         return %char(dateParm:*USA);
       end-proc;

       // --------------------------------------------------------------------------

       dcl-proc format_message;

         dcl-pi *n VARCHAR(100);
          msgid            CHAR(7)      CONST;
          replacement_text VARCHAR(100) CONST OPTIONS(*NOPASS);
          message_file     char(20)     CONST OPTIONS(*NOPASS);
         end-pi;

         dcl-pr QMHRTVM extpgm('QSYS/QMHRTVM');
           msginfo     char(65535) options(*varsize);
           msginfolen  int(10)     const;
           format      char(8)     const;
           msgid       char(7)     const;
           msgfile     char(20)    const;
           rplData     char(32767) options(*varsize) const;
           rplDataLen  int(10)     const;
           rplSubst    char(10)    const;
           rtnFmtCtl   char(10)    const;
           errorCode   char(32767) options(*varsize);
         end-pr;

         dcl-ds RTVM0100 qualified;
           bytesRtn    int(10);
           bytesAvail  int(10);
           msgLen      int(10);
           msgAvail    int(10);
           msgHlpLen   int(10);
           msgHlpAvail int(10);
           msgbuf      char(65500);
         end-ds;

         dcl-ds errorCode qualified;
           bytesProv  int(10) inz(%size(errorCode));
           bytesAvail int(10) inz(0);
         end-ds;

         dcl-s p_msg    pointer;
         dcl-s msg      char(32767) based(p_msg);
         dcl-s rtnVal   varchar(100);
         dcl-s rplText  varchar(100);
         dcl-s rplSubst char(10)    inz('*NO');
         dcl-s msgFile  char(20)    inz('QCPFMSG   *LIBL');

         if %parms >= 2;
           rplText = replacement_text;
           rplSubst = '*YES';
         endif;
         if %parms >= 3;
           msgFile = message_file;
         endif;

         QMHRTVM( RTVM0100
                : %size(RTVM0100)
                : 'RTVM0100'
                : msgid
                : msgFile
                : rplText
                : %len(rplText)
                : rplSubst
                : '*NO'
                : errorCode );

         if errorCode.bytesAvail > 0 or RTVM0100.msgLen < 1;
           rtnVal = '';
         else;
           p_msg = %addr(RTVM0100.msgbuf);
           rtnVal = %subst(msg:1:RTVM0100.msgLen);
         endif;

         return rtnVal;
       end-proc;
       // --------------------------------------------------------------------------

