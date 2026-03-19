********************************************************************

report  zmmy_po_history.

************************************************************************
* Tables
************************************************************************
tables : eket .

************************************************************************
* Types
************************************************************************
type-pools: slis.

************************************************************************
* selection screen
************************************************************************

data:
p_ekorg type ekko-ekorg,  " Organizacion compras
p_bukrs type ekko-bukrs,  " Sociedad
p_ekgrp type ekko-ekgrp,  " Grupo compras
p_bedat type ekko-bedat,  " Fecha Documento Compras
p_bsart type ekko-bsart,  " Clase Documento
p_ebeln type ekko-ebeln,  " Numero Documento Compras
p_procstat type ekko-procstat.  " Status tratamiento documento compras

selection-screen begin of block b1 with frame title text-001.

* Descripciones de los campos de seleccion
*S_BEDAT  Fecha documento
*S_BSART  Cl.documento compras
*S_BUKRS  Sociedad
*S_EBELN  Documento compras
*S_EKGRP  Grupo de compras
*S_EKORG  Organización compras
*S_PROC	Status tratamiento doc.
* Fin descripciones

select-options:
s_ekorg for p_ekorg,  " Organizacion compras
s_bukrs for p_bukrs,  " Sociedad
s_ekgrp for p_ekgrp,  " Grupo compras
s_bsart for p_bsart,  " Clase Documento
s_bedat for p_bedat,  " Fecha Documento Compras
s_ebeln for p_ebeln,  " PNumero Documento Compras
s_proc for p_procstat.  " Status tratamiento documento compras

selection-screen end of block b1.



************************************************************************
* Estructuras y tablas internas
************************************************************************
*CREAR LA ESTRUCTURA EN LA SE11 ANTES DE USAR EL PROGRAMA
*data: begin of zmmy_purchasemodif,
*
*BUKRS type BUKRS,
*       EBELN  type EBELN,
*AEDAT type   AEDAT,
*ERNAM  type ERNAM,
*NAME_LAST  type NAME_LAST,
*EKGRP  type EKGRP,
*EKNAM  type EKNAM,
*BEDAT  type BEDAT,
*FRGSX  type FRGSX,
*FRGKE  type FRGKE,
*FRGET  type FRGET,
*PROCSTAT  type MEPROCSTATE,
*DDTEXT  type DDTEXT,
*CHANGENR  type CDCHANGENR,
*UDATE  type UDATE,
*UTIME  type UTIME,
*USERNAME  type USERNAME,
*NAME_LAST2  type NAME_LAST,
*RLWRT  type RLWRT,
*BANFN  type BANFN.
*data: end of zmmy_purchasemodif.


data: it_table_po like zmmy_purchasemodif occurs 0 with header line,
it_table_po_temp like zmmy_purchasemodif occurs 0 with header line,
     it_fieldcat type slis_t_fieldcat_alv,
     st_fieldcat type slis_fieldcat_alv,
     st_print type slis_print_alv,
     w_repid like sy-repid,
     it_sort type slis_t_sortinfo_alv,
     st_sort like line of it_sort,
     it_filter type slis_t_filter_alv,
     st_filter like line of it_filter,
     it_events           type slis_t_event,
     st_layout type slis_layout_alv.

data: struct_ekko like ekko,
struct_cdhdr like cdhdr,
struct_cdpos like cdpos,
struct_ekpo like ekpo,
it_table_cdhdr like cdhdr occurs 0 with header line,
it_table_ekko like ekko occurs 0 with header line,
it_table_cdpos like cdpos occurs 0 with header line,
it_table_ekpo like ekpo occurs 0 with header line,
struct_resultat like zmmy_purchasemodif.

data:
username_desc type name_last,
username_desc2 type name_last,
pgr_desc type eknam,
rel_indic type frget,
pur_proc_stat_text type ddtext,
my_value like dd07l-domvalue_l,
my_wa like dd07v,
my_sum type rlwrt,
my_last_frgsx like ekko-frgsx,
my_last_frgke like ekko-frgke,
my_last_procstat like ekko-procstat,
my_last_rlwrt like ekko-rlwrt,
all_deleted type char1.

constants : my_domname type dd07l-domname value 'MEPROCSTATE'.



************************************************************************
* start of selection
************************************************************************

start-of-selection.

* Selección de datos de la tabla de pedidos y del historial de modif
  perform f1000_prepare_selection.

* Preparacion del ALV para mostrar los resultados
  perform f2000_prepare_alv.

* Visualización del ALV
  perform f3000_call_alv.


*&---------------------------------------------------------------------*
*&      Form  f1000_prepare_selection
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f1000_prepare_selection .

* Recuperacion del nombre de programa
  move sy-repid to w_repid.

  refresh it_table_po.
  clear it_table_po.


*  Seleccion de datos, leyendo los pedidos según los criterios de selección

  select distinct e~ebeln e~bukrs e~aedat e~ernam e~ekgrp e~bedat
  e~frgsx e~frgke e~procstat e~rlwrt
  from ekko as e
  into corresponding fields of table it_table_ekko
  where e~ebeln in s_ebeln
                  and e~bukrs in s_bukrs
                  and e~bstyp = 'F'
                  and e~bsart in s_bsart
                  and e~bedat in s_bedat
                  and e~ekorg in s_ekorg
                  and e~ekgrp in s_ekgrp
                  and e~procstat in s_proc.

*On remplit ensuite les données relatives à la table CDHDR

  loop at it_table_ekko into struct_ekko.

    refresh it_table_cdhdr.
    clear it_table_cdhdr.
    refresh it_table_ekpo.
    clear it_table_ekpo.
    move 'Y' to all_deleted.

** Eliminar pedidos con las posiciones borradas (todas).

    select * from ekpo into corresponding fields of table it_table_ekpo
    where ebeln = struct_ekko-ebeln.

    loop at it_table_ekpo into struct_ekpo.
      if struct_ekpo-loekz ne 'L'.
        move 'N' to all_deleted.
        continue.
      endif.
    endloop.

    if all_deleted eq 'Y'.
      delete it_table_ekko.
      continue.
    endif.

** Lectura de las modificaciones del pedido

    select * from cdhdr into corresponding fields of table it_table_cdhdr
       where objectclas = 'EINKBELEG'
       and objectid = struct_ekko-ebeln
       and tcode in ('ME29N', 'ME28', 'ME22N')
       and change_ind = 'U'.

    if sy-subrc = 0.


      select * from cdhdr into corresponding fields of table it_table_cdhdr
        where objectclas = 'EINKBELEG'
        and objectid = struct_ekko-ebeln
*     AND tcode IN ('ME29N', 'ME28', 'ZME28', 'ME22N')
        and change_ind = 'U'.

*** Ordenamos las modificaciones para que las ultimas realizadas aparezcan
* en primer lugar.

      sort it_table_cdhdr by udate descending utime descending.

      clear struct_cdhdr.
      clear my_last_frgsx.
      clear my_last_frgke.
      clear my_last_procstat.
      clear my_last_rlwrt.

      move struct_ekko-frgsx to my_last_frgsx.
      move struct_ekko-frgke to my_last_frgke.
      move struct_ekko-procstat to my_last_procstat.
      move struct_ekko-rlwrt to my_last_rlwrt.

      loop at it_table_cdhdr into struct_cdhdr.

        clear struct_resultat.

*        Añadimos los datos de EKKO
        move-corresponding struct_ekko to struct_resultat.

*        Añadimos los datos de CDHDR
        move-corresponding struct_cdhdr to struct_resultat.


*        Recuperamos todos los valores modificados de la tabla CDPOS

        select * from cdpos into corresponding fields of table it_table_cdpos
             where objectclas = 'EINKBELEG'
             and objectid = struct_ekko-ebeln
             and changenr = struct_cdhdr-changenr
             and tabname = 'EKKO'.

        clear struct_cdpos.

        move my_last_frgsx to struct_resultat-frgsx.
        move my_last_frgke to struct_resultat-frgke.
        move my_last_procstat to struct_resultat-procstat.
        move my_last_rlwrt to struct_resultat-rlwrt.

        loop at it_table_cdpos into struct_cdpos.

* Solo me quedo con modificaciones en campos relacionados con las estrategias liberacion
          case struct_cdpos-fname.
            when 'FRGSX'.
              move struct_cdpos-value_new to struct_resultat-frgsx.
              move struct_cdpos-value_old to my_last_frgsx.
            when 'FRGKE'.
              move struct_cdpos-value_new to struct_resultat-frgke.
              move struct_cdpos-value_old to my_last_frgke.
            when 'PROCSTAT'.
              move struct_cdpos-value_new to struct_resultat-procstat.
              move struct_cdpos-value_old to my_last_procstat.
            when 'RLWRT'.
              move struct_cdpos-value_new to struct_resultat-rlwrt.
              move struct_cdpos-value_old to my_last_rlwrt.
          endcase.

        endloop.


* Solo nos quedamos los resultados si los cambios tienen que ver con transacciones
* relevantes para la liberacion de pedidos.
        if struct_cdhdr-tcode eq 'ME29N' or struct_cdhdr-tcode eq 'ME28'
            or struct_cdhdr-tcode eq 'ME22N'.
          append struct_resultat to it_table_po.
        endif.

      endloop.

    else.
      clear struct_resultat.
      move-corresponding struct_ekko to struct_resultat.
      move '' to struct_resultat-utime.
      append struct_resultat to it_table_po.
    endif.

    my_sum = my_sum + struct_ekko-rlwrt.

  endloop.


  clear struct_resultat.
  loop at it_table_po into struct_resultat.

*Limpiamos variables de descripciones

    clear username_desc.
    clear username_desc2.
    clear pgr_desc.
    clear rel_indic.
    clear my_value.
    clear my_wa.


* Lectura del nombre de usuario (tablas USR21, ADRP)

    select single name_last
    into username_desc
    from adrp as a
    inner join usr21 as u
        on u~persnumber = a~persnumber
    where u~bname = struct_resultat-ernam.

    move username_desc to struct_resultat-name_last.

* Lectura del nombre de usuario que ha realizado los cambios,
* segun la tabla CDHDR (tablas USR21, ADRP)

    select single name_last
    into username_desc2
    from adrp as a
    inner join usr21 as u
        on u~persnumber = a~persnumber
    where u~bname = struct_resultat-username.

    move username_desc2 to struct_resultat-name_last2.


*  Recuperamos la descripcion del grupo de compras (tabla T024)
    select single eknam into pgr_desc
    from t024
    where ekgrp = struct_resultat-ekgrp.

    move pgr_desc to struct_resultat-eknam.


* Recuperamos la descripcion del Indicador de liberación (tabla T16FE)

    select single frget into rel_indic
    from t16fe
    where spras = sy-langu
    and frgke = struct_resultat-frgke.


    move rel_indic to struct_resultat-frget.


    my_value = struct_resultat-procstat.

* Recuperamos la solicitud de pedido

    clear eket .
    select * from eket up to 1 rows
    where ebeln  = struct_resultat-ebeln .
    endselect .


    move eket-banfn to struct_resultat-banfn.


    my_value = struct_resultat-procstat.

* Recuperamos la descripcion del Status de tratamiento del pedido

    call function 'DD_DOMVALUE_TEXT_GET'
      exporting
        domname             = my_domname
        value               = my_value
*   LANGU               = ' '
*   BYPASS_BUFFER       = ' '
  importing
   dd07v_wa            = my_wa
*   RC                  =
              .
    move my_wa-ddtext to struct_resultat-ddtext.

    modify it_table_po from struct_resultat
    transporting name_last name_last2 eknam frget ddtext banfn .

  endloop.

  clear struct_resultat.
  move '' to struct_resultat-utime.
  move my_sum to struct_resultat-rlwrt.

  append struct_resultat to it_table_po.

endform.    " f1000_prepare_selection


*&---------------------------------------------------------------------*
*&      Form  f2000_prepare_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f2000_prepare_alv .

* Prearacion del catalogo
  perform f2100_prepare_fieldcat.
*  IF p_excel <> 'X'.
  perform f2200_prepare_sortcat.
* Creacion de filtro
*  PERFORM f2300_prepare_filtercat.
* Visualizacion del ALV
  perform f2400_prepare_layout.

endform.                    " f2000_prepare_alv


*&---------------------------------------------------------------------*
*&      Form  f2100_prepare_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f2100_prepare_fieldcat .

* Creamos el catalogo de campos a partir de la estructura
  perform f2100_merge_fieldcat.
* Modificamos el catalogo para poner las descripciones
  perform f2100_change_fieldcat.

endform.                    " f2100_prepare_fieldcat


*&---------------------------------------------------------------------*
*&      Form  f2100_MERGE_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f2100_merge_fieldcat.

  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
   exporting
    i_program_name               = w_repid
*   i_internal_tabname           = it_table
    i_structure_name             = 'ZMMY_PURCHASEMODIF'
*   I_CLIENT_NEVER_DISPLAY       = 'X'
*   I_INCLNAME                   =
*   I_BYPASSING_BUFFER           =
*   I_BUFFER_ACTIVE              =
    changing
      ct_fieldcat                  = it_fieldcat
 EXCEPTIONS
   INCONSISTENT_INTERFACE       = 1
   PROGRAM_ERROR                = 2
   OTHERS                       = 3 .
  if sy-subrc <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

endform.                    " f2100_MERGE_fieldcat


*&---------------------------------------------------------------------*
*&      Form  f2100_CHANGE_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f2100_change_fieldcat.

* Simbolos de texto. Valores
*001  Parámetros de selecciónone
*003  Sociedad
*004  Documento
*005  Fecha pedido
*006  Código usuario
*007  Gr. de compras
*008  Fecha de pedido
*009  Estrategia
*010  Ind.liberación
*011  Status tratamiento
*012  Número del doc.
*013  Fecha
*014  Hora
*015  Código usuario
*016  Valor total en liberación
*017  LISTADO DE VALIDADORES DE PEDIDOS
*018  Nombre de usuario
*019  Denom. del grupo
*020  Denominación del indicador de liberación
*021  Denominación del status tratamiento
*022  Nombre de usuario
* Simbolos de texto. Valores

  loop at it_fieldcat into st_fieldcat.
    case st_fieldcat-fieldname.
      when 'BUKRS'.
        st_fieldcat-reptext_ddic = text-003.
        st_fieldcat-seltext_l = text-003.
        st_fieldcat-seltext_m = text-003.
        st_fieldcat-seltext_s = text-003.
        st_fieldcat-outputlen = 4.
      when 'EBELN'.
        st_fieldcat-reptext_ddic = text-004.
        st_fieldcat-seltext_l = text-004.
        st_fieldcat-seltext_m = text-004.
        st_fieldcat-seltext_s = text-004.
        st_fieldcat-outputlen = 10.
      when 'AEDAT'.
        st_fieldcat-reptext_ddic = text-005.
        st_fieldcat-seltext_l = text-005.
        st_fieldcat-seltext_m = text-005.
        st_fieldcat-seltext_s = text-005.
        st_fieldcat-outputlen = 10.
      when 'ERNAM'.
        st_fieldcat-reptext_ddic = text-006.
        st_fieldcat-seltext_l = text-006.
        st_fieldcat-seltext_m = text-006.
        st_fieldcat-seltext_s = text-006.
        st_fieldcat-outputlen = 10.
      when 'NAME_LAST'.
        st_fieldcat-reptext_ddic = text-018.
        st_fieldcat-seltext_l = text-018.
        st_fieldcat-seltext_m = text-018.
        st_fieldcat-seltext_s = text-018.
        st_fieldcat-outputlen = 14.
      when 'EKGRP'.
        st_fieldcat-reptext_ddic = text-007.
        st_fieldcat-seltext_l = text-007.
        st_fieldcat-seltext_m = text-007.
        st_fieldcat-seltext_s = text-007.
        st_fieldcat-outputlen = 3.
      when 'EKNAM'.
        st_fieldcat-reptext_ddic = text-019.
        st_fieldcat-seltext_l = text-019.
        st_fieldcat-seltext_m = text-019.
        st_fieldcat-seltext_s = text-019.
        st_fieldcat-outputlen = 9.
      when 'BEDAT'.
        st_fieldcat-reptext_ddic = text-008.
        st_fieldcat-seltext_l = text-008.
        st_fieldcat-seltext_m = text-008.
        st_fieldcat-seltext_s = text-008.
        st_fieldcat-outputlen = 9.
      when 'FRGSX'.
        st_fieldcat-reptext_ddic = text-009.
        st_fieldcat-seltext_l = text-009.
        st_fieldcat-seltext_m = text-009.
        st_fieldcat-seltext_s = text-009.
        st_fieldcat-outputlen = 5.
      when 'FRGKE'.
        st_fieldcat-reptext_ddic = text-010.
        st_fieldcat-seltext_l = text-010.
        st_fieldcat-seltext_m = text-010.
        st_fieldcat-seltext_s = text-010.
        st_fieldcat-outputlen = 3.
      when 'FRGET'.
        st_fieldcat-reptext_ddic = text-020.
        st_fieldcat-seltext_l = text-020.
        st_fieldcat-seltext_m = text-020.
        st_fieldcat-seltext_s = text-020.
        st_fieldcat-outputlen = 23.
      when 'PROCSTAT'.
        st_fieldcat-reptext_ddic = text-011.
        st_fieldcat-seltext_l = text-011.
        st_fieldcat-seltext_m = text-011.
        st_fieldcat-seltext_s = text-011.
        st_fieldcat-outputlen = 32.
      when 'DDTEXT'.
        st_fieldcat-reptext_ddic = text-021.
        st_fieldcat-seltext_l = text-021.
        st_fieldcat-seltext_m = text-021.
        st_fieldcat-seltext_s = text-021.
        st_fieldcat-outputlen = 32.
      when 'CHANGENR'.
        st_fieldcat-reptext_ddic = text-012.
        st_fieldcat-seltext_l = text-012.
        st_fieldcat-seltext_m = text-012.
        st_fieldcat-seltext_s = text-012.
        st_fieldcat-outputlen = 8.
      when 'UDATE'.
        st_fieldcat-reptext_ddic = text-013.
        st_fieldcat-seltext_l = text-013.
        st_fieldcat-seltext_m = text-013.
        st_fieldcat-seltext_s = text-013.
        st_fieldcat-outputlen = 4.
      when 'UTIME'.
        st_fieldcat-reptext_ddic = text-014.
        st_fieldcat-seltext_l = text-014.
        st_fieldcat-seltext_m = text-014.
        st_fieldcat-seltext_s = text-014.
        st_fieldcat-outputlen = 4.
      when 'USERNAME'.
        st_fieldcat-reptext_ddic = text-015.
        st_fieldcat-seltext_l = text-015.
        st_fieldcat-seltext_m = text-015.
        st_fieldcat-seltext_s = text-015.
        st_fieldcat-outputlen = 4.
      when 'NAME_LAST2'.
        st_fieldcat-reptext_ddic = text-022.
        st_fieldcat-seltext_l = text-022.
        st_fieldcat-seltext_m = text-022.
        st_fieldcat-seltext_s = text-022.
        st_fieldcat-outputlen = 10.
      when 'RLWRT'.
*        st_fieldcat-do_sum = 'X'.
        st_fieldcat-reptext_ddic = text-016.
        st_fieldcat-seltext_l = text-016.
        st_fieldcat-seltext_m = text-016.
        st_fieldcat-seltext_s = text-016.
        st_fieldcat-outputlen = 23.

    endcase.
    modify it_fieldcat from st_fieldcat.
  endloop.
endform.                    " f2100_CHANGE_fieldcat


*&---------------------------------------------------------------------*
*&      Form  f2200_prepare_sortcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f2200_prepare_sortcat.

*  st_sort-spos = '1'.
*  st_sort-fieldname = 'BUKRS'.
*  st_sort-up = 'X'.
*  st_sort-down = space.
*  st_sort-subtot = 'X'.
*  st_sort-group = '*'.
*  APPEND st_sort TO it_sort.

*  IF p_pilote = 'X'.
*
*  CLEAR st_sort.
*  st_sort-spos = '1'.
*  st_sort-fieldname = 'SOLD_TO_NR'.
*  st_sort-up = 'X'.
*  st_sort-down = space.
*  st_sort-subtot = 'X'.
*  st_sort-group = '*'.
*  APPEND st_sort TO it_sort.


*
*
*  ELSEIF p_gestio = 'X'.
*
*    CLEAR st_sort.
*    st_sort-spos = '1'.
*    st_sort-fieldname = 'BUKRS'.
*    st_sort-up = 'X'.
*    st_sort-down = space.
*    st_sort-subtot = 'X'.
*    st_sort-group = '*'.
*    APPEND st_sort TO it_sort.

*
*  ENDIF.

endform.                    " f2200_prepare_sortcat


*&---------------------------------------------------------------------*
*&      Form  f2300_prepare_filtercat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f2300_prepare_filtercat.

endform.                    " f2300_prepare_filtercat


*&---------------------------------------------------------------------*
*&      Form  f2400_prepare_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f2400_prepare_layout.
* Optimizacion del ancho de columnas
  st_layout-colwidth_optimize = 'X'.
  st_layout-no_colhead = space.
  st_layout-zebra = 'X'.
  st_layout-no_min_linesize = ''.
  st_layout-min_linesize = '275'.
*  st_layout-no_sumchoice = 'X'.
*  st_layout-no_subchoice = 'X'.

endform.                    " f2300_prepare_layout



*&---------------------------------------------------------------------*
*&      Form  f3000_call_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f3000_call_alv.

  call function 'REUSE_ALV_GRID_DISPLAY'
   exporting
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                =
*   I_BUFFER_ACTIVE                   = ' '
    i_callback_program                = w_repid
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   i_callback_user_command           = 'USER_COMMAND'
*   I_CALLBACK_TOP_OF_PAGE            = ' '
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
    i_grid_title     = text-017
*   I_GRID_SETTINGS                   =
    is_layout                         = st_layout
    it_fieldcat                       = it_fieldcat
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
    it_sort                           = it_sort
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*    it_events                         = it_events
*   IT_EVENT_EXIT                     =
*    is_print                          = st_print
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_ADD_FIELDCAT                   =
*   IT_HYPERLINK                      =
*   I_HTML_HEIGHT_TOP                 =
*   I_HTML_HEIGHT_END                 =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
    tables
      t_outtab                          = it_table_po
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
            .
  if sy-subrc <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.
endform.                    " f3000_call_alv
