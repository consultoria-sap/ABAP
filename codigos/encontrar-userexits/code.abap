*&———————————————————————*
*& Report ZUSER_EXIT
*&
*&———————————————————————*
*&
*&
*&———————————————————————*

REPORT  ZUSER_EXIT.
tables : tstc, tadir, modsapt, modact, trdir, tfdir, enlfdir.
tables : tstct.
data : jtab like tadir occurs 0 with header line.
data : field1(30).
data : v_devclass like tadir-devclass.
parameters : p_tcode like tstc-tcode obligatory.

select single * from tstc where tcode eq p_tcode.
if sy-subrc eq 0.
 select single * from tadir where pgmid = 'R3TR'
 and object = 'PROG'
 and obj_name = tstc-pgmna.
 move : tadir-devclass to v_devclass.
 if sy-subrc ne 0.
 select single * from trdir where name = tstc-pgmna.
 if trdir-subc eq 'F'.
 select single * from tfdir where pname = tstc-pgmna.
 select single * from enlfdir where funcname =
 tfdir-funcname.
 select single * from tadir where pgmid = 'R3TR'
 and object = 'FUGR'
 and obj_name eq enlfdir-area.

 move : tadir-devclass to v_devclass.
 endif.
 endif.
 select * from tadir into table jtab
 where pgmid = 'R3TR'
 and object = 'SMOD'
 and devclass = v_devclass.
 select single * from tstct where sprsl eq sy-langu and
 tcode eq p_tcode.
 format color col_positive intensified off.
 write:/(19) 'Transaction Code – ',
 20(20) p_tcode,
 45(50) tstct-ttext.
 skip.
 if not jtab[] is initial.
     write:/(95) sy-uline.
     format color col_heading intensified on.
     write:/1 sy-vline,
     2 'Exit Name',
     21 sy-vline ,
     22 'Description',
     95 sy-vline.
     write:/(95) sy-uline.
     loop at jtab.
     select single * from modsapt
     where sprsl = sy-langu and
     name = jtab-obj_name.
     format color col_normal intensified off.
     write:/1 sy-vline,
     2 jtab-obj_name, "hotspot on,
     21 sy-vline ,
     22 modsapt-modtext input on,
     95 sy-vline.
     hide: jtab-obj_name.
     endloop.
     write:/(95) sy-uline.
     describe table jtab.
     skip.
     format color col_total intensified on.
     write:/ 'No of Exits:' , sy-tfill.
 else.
     format color col_negative intensified on.
     write:/(95) 'No User Exit exists'.
 endif.
else.
 format color col_negative intensified on.
 write:/(95) 'Transaction Code Does Not Exist'.
endif.

at line-selection.
*  get cursor field field1.
*  check field1(4) eq 'JTAB'.
*  set parameter id 'MON' field sy-lisel+1(10).
*  call transaction 'SMOD' and skip first   screen.

 set parameter id 'MON' field jtab-obj_name.
 call transaction 'SMOD' and skip first   screen.
