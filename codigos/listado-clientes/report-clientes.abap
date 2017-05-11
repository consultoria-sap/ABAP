*&---------------------------------------------------------------------*
*& http://foros.consultoria-sap.com/t/creacion-de-un-listado-de-clientes/13891/53
*&
*&---------------------------------------------------------------------*


report AQA0SYSTQV000020ZCLIENTES=====
   line-size 252 no standard page heading line-count 000(001).

include <symbol>.
include <icon>.
selection-screen: begin of block prog
                           with frame title text-f58.

tables KNVV.
tables KNVP.
tables KNA1.
data %count-KNA1(4) type x.
data %linr-KNA1(2).

data: begin of %joinwa,
        KNA1 like KNA1,
        KNVP like KNVP,
        KNVV like KNVV,
      end of %joinwa.
tables aqldb.

include rsaqexcd.

data: begin of %st_liste occurs 100,
          head(1),
          tab(3),
          line(6) type n,
          cont(1) type n,
          fint(1),
          finv(1),
          fcol(1) type n,
          text(0252),
      end of %st_liste.

data %data_selected(1).
data %glframe(1)  value 'X' .
data %uflag(1).
data %ustflag(1).
data %grst_text(255).
data %glline type i.
data %tabix like sy-tabix.
data %prflag(1) type x value '02'.

data: %textpool_read(1),
      %textpool_langu type textpool occurs 0,
      %textpool_langu_line type textpool.
data: %txt1        type textpool-entry,
       %txt2        type textpool-entry,
       %txt3        type textpool-entry,
       %txtkey      type textpool-key,
       %txt_unknown type textpool-entry value 'UNKNOWN TEXT'.

data %perc(4) type p decimals 3.
data %p100(4) type p decimals 3 value '100.000'.
data %rangct type i.
data %rangcc(8).
select-options SP$00002 for KNVV-KUNNR memory id KUN.
select-options SP$00003 for KNVP-PARVW memory id PAR.
select-options SP$00004 for KNVP-SPART memory id SPA.
selection-screen skip 1.
selection-screen: begin of block direct
                  with frame title text-f59.
selection-screen: begin of line.
*selection-screen: comment 1(12) text-f57.
selection-screen: pushbutton 75(18) pb%exco user-command expcol
                                   modif id new.
selection-screen: end of line.
selection-screen: begin of line.
parameters:       %alv radiobutton group func user-command outbut
                                modif id new .
selection-screen: comment 4(26) text-f72 for field %alv
                                modif id new.
parameters:       %alvl type slis_vari modif id new.
selection-screen: end of line.
selection-screen: begin of line.
parameters:       %nofunc radiobutton group func modif id old
                         default 'X' .
selection-screen: comment 4(26) text-f66 for field %nofunc
                                         modif id old.
parameters:       %tview radiobutton group func modif id old.
selection-screen: comment 34(26) text-f68 for field %tview
                                          modif id old,
                  end of line.
selection-screen: begin of line.
parameters:       %graph radiobutton group func modif id old.
selection-screen: comment 4(26) text-f61 for field %graph
                                         modif id old.
parameters:       %text radiobutton group func modif id old.
selection-screen: comment 34(26) text-f69 for field %text
                                          modif id old,
                  end of line.
selection-screen: begin of line.
parameters:       %abc radiobutton group func modif id old.
selection-screen: comment 4(26) text-f70 for field %abc
                                         modif id old.
parameters:       %excel radiobutton group func modif id old.
selection-screen: comment 34(26) text-f60 for field %excel
                                         modif id old,
                  end of line.
selection-screen: begin of line.
parameters:       %eis radiobutton group func modif id old.
selection-screen: comment 4(26) text-f63 for field %eis
                                         modif id old.
selection-screen: end of line.
selection-screen: begin of line.
parameters:       %xint radiobutton group func modif id xin.
selection-screen: comment 4(26) text-f73 for field %xint
                                         modif id xin.
parameters:       %xintk like AQXINT-XIKEY lower case modif id xin.
selection-screen: end of line.
selection-screen: begin of line.
parameters:       %down radiobutton group func modif id old.
selection-screen: comment 4(26) text-f64 for field %down
                                         modif id old.
parameters:       %path type AQ_FILENAME lower case modif id old.
selection-screen: end of line.
selection-screen: begin of line.
parameters:       %save radiobutton group func modif id lis.
selection-screen: comment 4(26) text-f62 for field %save
                                         modif id lis.
parameters:       %listid like AQCAQL-TEXT visible length 40
                  lower case modif id lis.
selection-screen: end of line.
selection-screen: end of block direct.
selection-screen: end of block prog.

data: begin of %g00 occurs 100,
            KNVV-KUNNR like KNVV-KUNNR,
            KNA1-NAME1 like KNA1-NAME1,
            KNA1-ORT01 like KNA1-ORT01,
            KNA1-STCD1 like KNA1-STCD1,
            KNVV-PLTYP like KNVV-PLTYP,
            KNVV-VKGRP like KNVV-VKGRP,
            KNVV-VKBUR like KNVV-VKBUR,
            KNVP-PERNR like KNVP-PERNR,
            KNVP-PARVW like KNVP-PARVW,
            KNVP-SPART like KNVP-SPART,
      end of %g00.
data: begin of %%g00,
            KNVV-KUNNR(010),
            KNA1-NAME1(035),
            KNA1-ORT01(035),
            KNA1-STCD1(016),
            KNVV-PLTYP(002),
            KNVV-VKGRP(003),
            KNVV-VKBUR(004),
            KNVP-PERNR(008),
            KNVP-PARVW(002),
            KNVP-SPART(002),
      end of %%g00.
data %znr type i.
data %lznr type i value 99999.
field-groups header.
field-groups %fg01.
data %any-01.

controls tview100 type tableview using screen 100.

AT SELECTION-SCREEN.
perform alvl_check(rsaqexce) using %alvl 'G00'.
perform testmode(rsaqexce).
perform check_expcol(rsaqexce) using %alv.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR %ALVL.
perform alvl_value_request(rsaqexce) using %alvl 'G00'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR %XINTK.
perform xint_value_request(rsaqexce).

AT SELECTION-SCREEN OUTPUT.

perform save_initial_sscr(rsaqexce).
perform rinit(rsaqbrst).
perform set_expcol(rsaqexce) using %alv pb%exco.
perform alvl_set_invisible(rsaqexce).
perform set_xint_params(rsaqexce).

INITIALIZATION.
perform init_xint(rsaqexce).
perform set_www_flags(rsaqexce).
perform init_print_params(rsaqexce).

if %textpool_read is initial.
  read textpool sy-repid into %textpool_langu language sy-langu.
  %textpool_read = 'X'.
endif.

START-OF-SELECTION.
insert %count-KNA1 into header.
insert %linr-KNA1 into header.
insert KNVV-KUNNR into %fg01.
insert KNA1-NAME1 into %fg01.
insert KNA1-ORT01 into %fg01.
insert KNA1-STCD1 into %fg01.
insert KNVV-PLTYP into %fg01.
insert KNVV-VKGRP into %fg01.
insert KNVV-VKBUR into %fg01.
insert KNVP-PERNR into %fg01.
insert KNVP-PARVW into %fg01.
insert KNVP-SPART into %fg01.
perform init_texthandling(rsaqexce) using 'CL_TEXT_IDENTIFIER' ' ' 'SYSTQV000000000000000156'.
"webgui
data: %ret type i.
  if sy-batch is initial and %excel is not initial.
    perform check_wingui(rsaqsyst) using %ret.
    if %ret <> 0.
      message e842(aq).
    endif.
  endif.
"webgui
perform authority_begin(rsaqexce) using 'CL_QUERY_TAB_ACCESS_AUTHORITY'.
perform authority(rsaqexce) using 'KNA1' 'CL_QUERY_TAB_ACCESS_AUTHORITY'.
perform authority(rsaqexce) using 'KNVP' 'CL_QUERY_TAB_ACCESS_AUTHORITY'.
perform authority(rsaqexce) using 'KNVV' 'CL_QUERY_TAB_ACCESS_AUTHORITY'.
perform authority_end(rsaqexce) using 'CL_QUERY_TAB_ACCESS_AUTHORITY'.
perform %comp_ldesc.
select KNA1~KUNNR KNA1~NAME1 KNA1~ORT01 KNA1~STCD1 KNVP~KUNN2 KNVP~KUNNR KNVP~PARVW KNVP~PERNR KNVP~SPART KNVP~VKORG KNVP~VTWEG
       KNVV~KUNNR KNVV~PLTYP KNVV~SPART KNVV~VKBUR KNVV~VKGRP KNVV~VKORG KNVV~VTWEG
into (KNA1-KUNNR , KNA1-NAME1 , KNA1-ORT01 , KNA1-STCD1 , KNVP-KUNN2 , KNVP-KUNNR , KNVP-PARVW , KNVP-PERNR , KNVP-SPART
     , KNVP-VKORG , KNVP-VTWEG , KNVV-KUNNR , KNVV-PLTYP , KNVV-SPART , KNVV-VKBUR , KNVV-VKGRP , KNVV-VKORG , KNVV-VTWEG )
from ( KNA1
       inner join KNVP
       on KNVP~KUNN2 = KNA1~KUNNR
       inner join KNVV
       on KNVV~KUNNR = KNVP~KUNNR
       and KNVV~SPART = KNVP~SPART
       and KNVV~VKORG = KNVP~VKORG
       and KNVV~VTWEG = KNVP~VTWEG )
       where KNVP~PARVW in SP$00003
         and KNVP~SPART in SP$00004
         and KNVV~KUNNR in SP$00002.
  %dbacc = %dbacc - 1.
  if %dbacc = 0.
    stop.
  endif.
  check SP$00003.
  check SP$00004.
  check SP$00002.
  add 1 to %count-KNA1.
  %linr-KNA1 = '01'.
  extract %fg01.
endselect.

END-OF-SELECTION.
sort as text.
%diact = space.
%printon = space.
%batch = sy-batch.
if %batch <> space.
  if %eis <> space.
    %diact = 'E'.
    %printon = 'X'.
    if %eisprotocol = space.
      new-page print on destination 'NULL' no dialog
               line-size 0252 line-count 0065.
    else.
      new-page print on no dialog
               parameters %init_pri_params.
    endif.
  endif.
  if %alv <> space.
    %diact = 'V'.
    %printon = 'X'.
    %alv_layout = %alvl.
    new-page print on destination 'NULL' no dialog
             line-size 0252 line-count 0065.
  endif.
  if %save <> space.
    %diact = 'S'.
    %printon = 'X'.
    new-page print on destination 'NULL' no dialog
             line-size 0252 line-count 0065.
  endif.
elseif %called_by_www <> space.
  %diact = space.
elseif %called_by_www_alv <> space.
  %diact = 'V'.
else.
  perform init_print_params(rsaqexce).
  if %save  <> space. %diact = 'S'. endif.
  if %xint  <> space. %diact = 'I'. endif.
  if %tview <> space. %diact = 'T'. endif.
  if %alv   <> space. %diact = 'V'. endif.
  if %down  <> space. %diact = 'D'. endif.
  if %eis   <> space. %diact = 'E'. endif.
  if %graph <> space. %diact = 'G'. endif.
  if %excel <> space. %diact = 'X'. endif.
  if %text  <> space. %diact = 'W'. endif.
  if %abc   <> space. %diact = 'A'. endif.
  if %diact <> space and %diact <> 'S' and %diact <> 'W'.
    %printon = 'X'.
    new-page print on destination 'NULL' no dialog
             line-size 0252 line-count 0065.
  endif.
  %pathname = %path.
  if %diact = 'I'.
    %functionkey = %xintk.
  endif.
  if %diact = 'V'.
    %alv_layout = %alvl.
  endif.
endif.
free memory id 'AQLISTDATA'.
if %memmode <> space.
  if %batch <> space and %printon = space.
    %printon = 'X'.
    new-page print on destination 'NULL' no dialog
             line-size 0252 line-count 0065.
  endif.
  %diact = '1'.
endif.
%titel = ' '.
if sy-subty o %prflag and %titel = space.
  new-page with-title.
endif.
%tvsize = 0200.
%pline = 1.
%pzgr  = 1.
%first = 'X'.
perform %output.
%first = space.
if %diact <> space and %diact <> 'S'.
  if %batch = space.
    new-page print off.
    if not ( %diact = 'V' and %ucomm = 'PRIN' ).
      new-page no-heading no-title.
      write space.
    endif.
  endif.
else.
  perform pf-status(rsaqexce) using 'XXX   '.
endif.
clear: %tab, %line, %cont.
if %data_selected = space.
  if %diact = '1'.
    export empty from %empty to memory id 'AQLISTDATA'.
    leave.
  else.
    if %batch = space and
       %called_by_www = space and
       %called_by_www_alv = space.
      message s260(aq).
      leave list-processing.
    else.
      if %called_by_www_alv = space.
        %diact = space.
      endif.
    endif.
  endif.
endif.
if %diact = 'S'.
  perform %save_list.
  leave list-processing.
endif.
if %diact = 'V' and %batch <> space.
  new-page print off.
  perform set_print_params(rsaqexce).
  perform %download using 'ALV'.
  leave.
endif.
if %diact = 'V' and %called_by_www_alv <> space.
  perform %download using 'ALV'.
  leave.
endif.
*if %diact = 'V' and ( %ucomm = 'PRIN' or sy-subty = '07' ).
data %is_submit_to_spool type c.
if %diact = 'V'.
  CALL FUNCTION 'IS_SUBMIT_TO_SPOOL'
    IMPORTING FLAG = %is_submit_to_spool.
  if ( %ucomm = 'PRIN' or %is_submit_to_spool = 'X' ).
    perform set_print_params(rsaqexce).
    perform %download using 'ALV'.
    set parameter id 'SPI' field sy-spono.
    leave list-processing.
  endif.
endif.
if %diact = 'P' and %batch <> space.
  perform %download using '+DAT'.
  leave list-processing.
endif.
if %diact = 'E' and %batch <> space.
  perform %download using 'EIS'.
  leave list-processing.
endif.
if %diact = '1'.
  perform %download using '+MEM'.
  leave.
endif.
if %diact = 'X'.
  set user-command 'XXL'.
elseif %diact = 'W'.
  set user-command 'TEXT'.
elseif %diact = 'V'.
  set user-command 'ALV'.
elseif %diact = 'T'.
  set user-command 'VIEW'.
elseif %diact = 'G'.
  set user-command 'GRAF'.
elseif %diact = 'A'.
  set user-command 'ABCA'.
elseif %diact = 'E'.
  set user-command 'EIS'.
elseif %diact = 'D'.
  set user-command 'DOWN'.
elseif %diact = 'I'.
  set user-command 'XINT'.
elseif %diact = 'P'.
  set user-command '+DAT'.
endif.

TOP-OF-PAGE.
perform %top-of-page.

END-OF-PAGE.
perform page_foot(rsaqexce).
perform %save_page.

TOP-OF-PAGE DURING LINE-SELECTION.
perform %top-of-page.

AT USER-COMMAND.
case sy-ucomm.
when 'EXIT'.
  leave program.
when 'RETN'.
  perform return(rsaqexce).
when 'CANC'.
  perform return(rsaqexce).
when 'WEIT'.
  perform return(rsaqexce).
when 'INHA'.
  perform catalogue(rsaqexce).
when 'AUSL'.
  perform pickup(rsaqexce).
when 'AUSW'.
  perform pickup(rsaqexce).
when 'RCAA'.
  perform rchain(rsaqbrst).
when 'RCAL'.
  perform rcall(rsaqbrst).
when 'VGLI'.
  perform change(rsaqexce).
when 'VGLE'.
  perform change(rsaqexce).
when 'TOTO'.
  perform change(rsaqexce).
when 'VSTA'.
  perform change(rsaqexce).
when 'VSTE'.
  perform return(rsaqexce).
when 'SAVL'.
  perform %save_list.
when 'ODRU'.
  perform print_list(rsaqexce).
when 'COPA'.
  perform print_cover_page(rsaqexce).
when 'TEXT'.
  perform %download using 'TEXT'.
when 'ALV'.
  perform %download using 'ALV'.
when 'VIEW'.
  perform %view.
when 'XXL'.
  perform %download using 'XXL'.
when 'GRAF'.
  perform %download using 'GRAF'.
when 'ABCA'.
  perform %download using 'ABCA'.
when 'EIS'.
  perform %download using 'EIS'.
when 'DOWN'.
  perform %download using 'DOWN'.
when 'XINT'.
  perform %download using 'XINT'.
endcase.
clear: %cline, %zgr.
clear: %tab, %line, %cont.
if %diact <> space.
  leave list-processing.
endif.


form %comp_ldesc.

*... textpool required (API calls %comp_ldesc directly)
  if %textpool_read is initial.
    read textpool sy-repid into %textpool_langu language sy-langu.
    %textpool_read = 'X'.
  endif.

  refresh %ldesc.
  refresh %gdesc.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A00'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B00'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00010000X010       00  98'
    %txt1 %txt2 %txt3 'KNVV-KUNNR' KNVV-KUNNR 'KNVV-KUNNR'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A01'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B01'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00020000X035       00  98'
    %txt1 %txt2 %txt3 'KNA1-NAME1' KNA1-NAME1 'KNA1-NAME1'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A02'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B02'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00030000X035       00  98'
    %txt1 %txt2 %txt3 'KNA1-ORT01' KNA1-ORT01 'KNA1-ORT01'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A03'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B03'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00040000X016       00  98'
    %txt1 %txt2 %txt3 'KNA1-STCD1' KNA1-STCD1 'KNA1-STCD1'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A04'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B04'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00050000X002       00  98'
    %txt1 %txt2 %txt3 'KNVV-PLTYP' KNVV-PLTYP 'KNVV-PLTYP'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A05'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B05'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00060000X003       00  98'
    %txt1 %txt2 %txt3 'KNVV-VKGRP' KNVV-VKGRP 'KNVV-VKGRP'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A06'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B06'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00070000X004       00  98'
    %txt1 %txt2 %txt3 'KNVV-VKBUR' KNVV-VKBUR 'KNVV-VKBUR'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A07'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B07'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00080000X008       00  98'
    %txt1 %txt2 %txt3 'KNVP-PERNR' KNVP-PERNR 'KNVP-PERNR'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A08'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B08'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00090000X002       00  98'
    %txt1 %txt2 %txt3 'KNVP-PARVW' KNVP-PARVW 'KNVP-PARVW'.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'A09'.
  if sy-subrc is initial. %txt1 = %textpool_langu_line-entry.
  else. %txt1 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'B09'.
  if sy-subrc is initial. %txt2 = %textpool_langu_line-entry.
  else. %txt2 = %txt_unknown.
  endif.
  read table %textpool_langu into %textpool_langu_line
                             with key key = 'H00'.
  if sy-subrc is initial. %txt3 = %textpool_langu_line-entry.
  else. %txt3 = %txt_unknown.
  endif.
  perform ldesc(rsaqexce) using 'G00100000X002       00  98'
    %txt1 %txt2 %txt3 'KNVP-SPART' KNVP-SPART 'KNVP-SPART'.
  perform gdesc(rsaqexce) using 'G00' 5 20 ' ' ' ' 'X'.
  perform complete_ldesc(rsaqexce) tables %ldesc.

endform.

form %read_ldesc using p_lid   type aql_lid
                       p_ldesc type rsaqtldesc.

  p_lid = 'G00'.
  perform %comp_ldesc.
  p_ldesc[] = %ldesc[].

endform.


form %output.

describe table %prlist lines %max_prlist.
%head = 'AAA'.
%keyempty = space.
new-page.
perform %output_gl.
perform complete_page(rsaqexce).
%head = 'ZZZ'.
perform last_ptab_entry(rsaqexce).
new-page.
if %keyempty <> space.
  message s894(aq).
endif.

endform.


form %top-of-page.

if sy-ucomm = 'INHA'. exit. endif.
if sy-ucomm = 'COPA'. exit. endif.
if %head    = space.  exit. endif.
if %head = 'DDD'.
  perform tviewpage(rsaqexce).
  exit.
endif.
if %head = 'GGG'.
  perform page(rsaqexce) using 'G00' text-grl 252 %glframe 001.
  set left scroll-boundary column 002.
  perform set_scroll_boundary(rsaqexce) using 002.
  if %toto <> space. exit. endif.
else.
  case %head.
  when others.
  endcase.
endif.

endform.


form %newline.

data: %llen type i.
  %llen = 252.
  %uflag = space.
  new-line.
  write: '|', 252 '|'.
  position 2.

endform.

form %skip using count.

  if sy-linno > 1.
    %uflag = space.
    do count times.
      new-line.
      format reset.
      write: '|', 252 '|'.
    enddo.
  endif.

endform.

form %uline.

  if %uflag = space.
    if sy-linno > 1.
      uline /1(252).
    endif.
    %uflag = 'X'.
  endif.

endform.

form %hide.

  if %batch <> space and %diact = 'S'.
    perform hide(rsaqexce).
  else.
    hide: %tab, %line, %cont.
  endif.

endform.

form %hide_color.

  if %batch <> space and %diact = 'S'.
    perform hide_color(rsaqexce).
  else.
    hide: %fint, %fcol.
  endif.

endform.

form %rcall using name value.

field-symbols <field>.

  assign (name) to <field>.
  if sy-subrc <> 0.
    value = space.
    exit.
  endif.
  read current line field value <field> into value.
  if value = space and %tab = 'G00' and %ldesc-fcur na 'FM'.
    read table %g00 index %line.
    if sy-subrc = 0.
      assign component %ldesc-fnameint of structure %g00
                                       to <field>.
      if sy-subrc = 0.
        write <field> to value(%ldesc-folen).
      endif.
    endif.
  endif.

endform.

form %save_page.

  if %batch <> space and %diact = 'S'.
    perform save_page(rsaqexce) tables %st_liste.
  endif.

endform.

form %replace_var using text.

field-symbols <var>.

  assign text+1(*) to <var>.

endform.

form %save_list.

data: %sflag,
      qreport like sy-repid.

  if %diact = 'S'. %sflag = 'X'. endif.
  qreport = sy-repid.
  perform save_list(rsaqexce) tables %st_liste
                              using qreport %sflag %listid.
  if %ql_id <> space.
    %dlflag = 'X'.
    %listsize = 0252.
    perform comp_selection_screen(rsaqexce).
    export %st_liste %ptab %ldesc %gdesc %dlflag %listsize
           %selections
           %g00
           to database aqldb(aq) id %ql_id.
  endif.

endform.

form %refresh.

  case %tab.
  when 'G00'.
    import %g00 from database aqldb(aq) id %ql_id.
  endcase.

endform.

form %download using code.

data: qreport like sy-repid.

  perform init_download(rsaqexce).
  qreport = sy-repid.
  case %tab.
  when 'G00'.
    perform download(rsaqexce)
            tables %g00 using code qreport text-grl.
  when others.
    message s860(aq).
  endcase.

endform.

form %set_data changing l_lines type i.

  import ldata to %g00 from memory id 'AQLISTDATA'.
  describe table %g00 lines l_lines.
  free memory id 'AQLISTDATA'.

endform.

form %get_data tables datatab structure %g00
               using  first type i
                      last  type i.

  append lines of %g00 from first to last to datatab.

endform.

form %get_ref_to_table using lid         like rsaqldesc-lid
                             ref_to_itab type ref to data
                             subrc       like sy-subrc.

  subrc = 0.
  case lid.
  when 'G00'.
    create data ref_to_itab like %g00[].
  when others.
    subrc = 4.
    message s860(aq).
  endcase.

endform.

form %view.

data: ret type i.

  perform check_wingui(rsaqsyst) using ret.
  if ret <> 0.
    message s841(aq).
    perform %download using 'ALV'.
    exit.
  endif.

data: anz type i,
      prog like sy-repid.

  prog = sy-repid.
  perform init_download(rsaqexce).
  case %tab.
  when 'G00'.
    perform generate_view_dynpro(rsaqexce)
            using prog text-grl.
    describe table %g00 lines anz.
    tview100-lines = anz.
    perform init_view(rsaqexce) tables %g00 using tview100.
    call screen 100.
    perform reset_view_dynpro(rsaqexce).
  when others.
    message s860(aq).
  endcase.

endform.

form %colhead_print changing lines like sy-linno
                             hflag type c.
data: l_text(255).
  if %textpool_read is initial.
    read textpool sy-cprog into %textpool_langu language sy-langu.
    %textpool_read = 'X'.
  endif.
  lines = lines +  1.
  if  1 = 0. clear hflag. else. hflag = 'X'. endif.
  write at (1) '|' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B001'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 002(010) l_text(010)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B011'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 013(035) l_text(035)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B021'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 049(035) l_text(035)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B031'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 085(016) l_text(016)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B041'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 102(002) l_text(002)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B051'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 105(003) l_text(003)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B061'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 109(004) l_text(004)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B071'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 114(008) l_text(008)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B081'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 123(002) l_text(002)  no-gap.
  write at (1) ' ' no-gap.
  read table %textpool_langu into %textpool_langu_line
                             with key ID = 'I' key = 'B091'.
  if sy-subrc is initial.
    l_text = %textpool_langu_line-entry.
  else.
    clear l_text.
  endif.
  perform replace_vars(rsaqexce) using l_text 'X'.
  write at 126(002) l_text(002)  no-gap.
  write at (1) ' ' no-gap.
  write at 252(1) '|' no-gap.
  new-line.
endform.


form %output_gl.

if %max_prlist <> 0.
  read table %prlist with key tab = 'GGG'.
  if sy-subrc <> 0.
    exit.
  endif.
endif.
set margin 00.
perform complete_page(rsaqexce).
%nochange = space.
new-page.
%glline   = 0.
%tab      = 'G00'.
%line     = 0.
%cont     = '0'.
%fint     = space.
%fcol     = '0'.
%head     = 'GGG'.
%cline    = 0.
%outflag  = space.
%outcomp  = space.
%outtotal = space.
%rflag    = 'AA'.
if %diact <> space and %diact na 'SWE'. write space. endif.
format reset.
loop.
  %data_selected = 'X'.
  at %fg01.
    %znr = '01'.
    %zgr = '01'.
    %cline = %cline + 1.
    %g00-KNVV-KUNNR = KNVV-KUNNR.
    %g00-KNA1-NAME1 = KNA1-NAME1.
    %g00-KNA1-ORT01 = KNA1-ORT01.
    %g00-KNA1-STCD1 = KNA1-STCD1.
    %g00-KNVV-PLTYP = KNVV-PLTYP.
    %g00-KNVV-VKGRP = KNVV-VKGRP.
    %g00-KNVV-VKBUR = KNVV-VKBUR.
    %g00-KNVP-PERNR = KNVP-PERNR.
    %g00-KNVP-PARVW = KNVP-PARVW.
    %g00-KNVP-SPART = KNVP-SPART.
    if %first <> space. append %g00. endif.
    %glline = %glline + 1.
    %lznr = %znr.
    if %diact <> space and %diact na 'SWE'. continue. endif.
    perform check(rsaqexce) using ' '.
    if %rflag = 'E'. exit. endif.
    if %rflag(1) = 'A'.
    format reset.
    %fint = 'F'. %fcol = '0'.
    format color 2. %fcol = '2'.
    perform %newline.
    write 002(010) KNVV-KUNNR.
    %line = %glline.
    perform %hide.
    %line = 0.
    perform %hide_color.
    write 013(035) KNA1-NAME1.
    write 049(035) KNA1-ORT01.
    write 085(016) KNA1-STCD1.
    write 102(002) KNVV-PLTYP.
    write 105(003) KNVV-VKGRP.
    write 109(004) KNVV-VKBUR.
    write 114(008) KNVP-PERNR.
    write 123(002) KNVP-PARVW.
    write 126(002) KNVP-SPART.
    endif.
  endat.
endloop.
%rflag = 'AA'.
perform %uline.
clear: %cline, %zgr.

endform.



module %init_view output.

  case %tab.
  when 'G00'.
    perform init_pbo(rsaqexce) tables %g00 using tview100 'X'.
  when others.
    message s860(aq).
  endcase.

endmodule.

module %pbo_view output.

  case %tab.
  when 'G00'.
    perform loop_pbo(rsaqexce) tables %g00 using %%g00 tview100.
  endcase.

endmodule.

module %pai_view input.

  case %tab.
  when 'G00'.
    perform loop_pai(rsaqexce) tables %g00 using %%g00 tview100.
  endcase.

endmodule.

module %okcode_view input.

  case %tab.
  when 'G00'.
    perform okcode(rsaqexce) tables %g00 using tview100.
  endcase.

endmodule.
