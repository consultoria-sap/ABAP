*& Report ZFIRP_GENERALES
*-----------------------------------------------------------------
REPORT  zfirp_generales.

TABLES: zfitb_lglcstr,t882g, t001.

TYPES: BEGIN OF tpt_total_sald,
rtcur TYPE rtcur,
racct TYPE racct,
drcrk TYPE shkzg,
hslvt	TYPE hslvt12,
hsl01	TYPE hslxx12,
hsl02	TYPE hslxx12,
hsl03	TYPE hslxx12,
hsl04	TYPE hslxx12,
hsl05	TYPE hslxx12,
hsl06	TYPE hslxx12,
hsl07	TYPE hslxx12,
hsl08	TYPE hslxx12,
hsl09	TYPE hslxx12,
hsl10	TYPE hslxx12,
hsl11	TYPE hslxx12,
hsl12	TYPE hslxx12,
hsl13	TYPE hslxx12,
hsl14	TYPE hslxx12,
hsl15	TYPE hslxx12,
hsl16	TYPE hslxx12,
END OF tpt_total_sald.


TYPES: BEGIN OF tpt_total_det,
ryear	TYPE  gjahr,
docnr TYPE  belnr_d,
rldnr TYPE  fagl_rldnr,
rbukr TYPE  bukrs,
rtcur TYPE  rtcur,
racct TYPE  racct,
hsl   TYPE  vlcur12,
tsl   type   vlcur12,
drcrk TYPE  shkzg,
poper TYPE  poper,
gjahr TYPE  gjahr,
budat TYPE  budat,
belnr TYPE  belnr_d,
END OF tpt_total_det,

BEGIN OF ty_SKB1,
BUKRS type BUKRS,
SAKNR type saknr,
waers type WAERS_SKB1,
END OF ty_SKB1.

TYPES: tpt_grpcta TYPE TABLE OF zfies_clsfc,
tpt_grpdtl TYPE TABLE OF tpt_total_det,
doc_dtrans type table of tpt_total_det.
data:  ti_skb1    type table of ty_skb1, moneda like skb1-waers.



*------------------------------
DATA: obj_clstr TYPE REF TO cl_gui_custom_container,
      obj_alvgd TYPE REF TO cl_gui_custom_alv_grid.
*------------------------------
DATA: it_grpcta_gral TYPE tpt_grpcta,
      wa_grpcta_gral TYPE zfies_clsfc,
      it_grpdetail   TYPE tpt_grpdtl,
      wa_sort        TYPE lvc_s_sort,
      it_sort        TYPE lvc_t_sort,
      it_catalog     TYPE lvc_t_fcat,
      it_grpcta_alv  TYPE tpt_grpcta.

DATA: key         TYPE sychar28,
      num_level   TYPE numc2,
      num_levelc  TYPE numc2,
      wa_lglcstr  TYPE zfitb_lglcstr,
      it_fscrep   TYPE zfitt_repfisc,
      it_fsrpdet  TYPE ztb_libmay,
      wa_fsrpdet  TYPE zst_libmay,
      it_fsrpdet0 TYPE ztb_libmay0,
      wa_fsrpdet0 TYPE zst_libmay0,
      w1_fsrpdet  TYPE zst_libmay,
      name_strct  TYPE tabname,
      text_flxt   TYPE tabname,
      text_flxt_  TYPE tabname,
      text_flxte  TYPE tabname,
      okcode      TYPE sy-ucomm,
      wa_fscrep   TYPE zfies_repfisc,
      wa_detail   TYPE tpt_total_det,
      wa_flxttl   TYPE tpt_total_sald.
DATA: ti_bnkcon   TYPE zfitb_bnkcon,
      wa_bnkcon   TYPE zfies_bnkcon,
      ctanbr0     TYPE hkont,
      ctanbr1     TYPE hkont,
      ctanbr2     TYPE hkont.
DATA: poper	      TYPE poper.

DATA: it_flxttl TYPE TABLE OF tpt_total_sald.
DATA: it_bsis   TYPE TABLE OF bsis,
      wa_bsis   TYPE bsis.

FIELD-SYMBOLS: <fs_ttl>  TYPE ANY,
<fs_strc> TYPE ANY,
<fs_tab>  TYPE ANY TABLE.




SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-t01.
PARAMETERS: p_nmstr TYPE numc10  MATCHCODE OBJECT zfitb_lglcstr OBLIGATORY,
p_bukrs TYPE bukrs   OBLIGATORY,
p_gjahr TYPE gjahr   OBLIGATORY,
p_folio TYPE char6             .
SELECT-OPTIONS s_month FOR poper OBLIGATORY NO-EXTENSION.
PARAMETERS: btn_rsm TYPE flag RADIOBUTTON GROUP grp1,
btn_det TYPE flag RADIOBUTTON GROUP grp1.
PARAMETERS: p_arrst TYPE char1   AS CHECKBOX DEFAULT 'X',
p_prtab TYPE char1   AS CHECKBOX DEFAULT 'X'.
PARAMETERS: p_forms TYPE tdsfname MATCHCODE OBJECT SH_STXFADM.
SELECTION-SCREEN END OF BLOCK bl1.

LOAD-OF-PROGRAM.

  CREATE OBJECT obj_clstr
    EXPORTING
      container_name = 'CUSTM9000'
      repid          = sy-repid
      dynnr          = '9000'.
  CREATE OBJECT obj_alvgd
    EXPORTING
      i_parent = obj_clstr.

INITIALIZATION.
  CLEAR it_sort.
  wa_sort-group     = 'X'.
  wa_sort-subtot    = 'X'.
  wa_sort-fieldname = 'GROUP_01'.
  wa_sort-level     = wa_sort-spos = 1.
  APPEND wa_sort TO it_sort.
  wa_sort-fieldname = 'GROUP_02'.
  wa_sort-level     = wa_sort-spos = 2.
  APPEND wa_sort TO it_sort.
  wa_sort-fieldname = 'GROUP_03'.
  wa_sort-level     = wa_sort-spos = 3.
  APPEND wa_sort TO it_sort.
  wa_sort-fieldname = 'GROUP_04'.
  wa_sort-level     = wa_sort-spos = 4.
  APPEND wa_sort TO it_sort.
  wa_sort-fieldname = 'GROUP_05'.
  wa_sort-level     = wa_sort-spos = 5.
  APPEND wa_sort TO it_sort.
  wa_sort-fieldname = 'GROUP_06'.
  wa_sort-level     = wa_sort-spos = 6.
  APPEND wa_sort TO it_sort.


START-OF-SELECTION.

  SELECT SINGLE * FROM t001 WHERE bukrs EQ p_bukrs.
  SELECT SINGLE * FROM zfitb_lglcstr WHERE numstrct EQ p_nmstr.
  IF sy-subrc <> 0.
    MESSAGE 'No existen Datos para el criterio de selección ingresado' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CASE 'X'.
    WHEN btn_rsm.
      text_flxt  = 'WA_FSCREP-GROUP_'.
      text_flxt_ = 'WA_FSRPDET-GRPID_'.
    WHEN btn_det.
      text_flxt  = 'WA_FSRPDET-GROUP_'.
      text_flxt_ = 'WA_FSRPDET-GRPID_'.
  ENDCASE.

  key = zfitb_lglcstr-strf1.
  IMPORT struct TO it_grpcta_gral FROM DATABASE zfitb_lglcstr(st) TO wa_lglcstr ID key.

  SORT it_grpcta_gral BY id_grp id_relgrp.
  read table it_grpcta_gral into wa_grpcta_gral index 1.
  if sy-subrc eq 0.
    select single waers into moneda from skb1 where BUKRS eq  p_bukrs and SAKNR in wa_grpcta_gral-hkont.
  endif.


  LOOP AT it_grpcta_gral INTO wa_grpcta_gral.

    IF wa_grpcta_gral-id_grp+1(11) EQ '00000000000'.
      num_level = 5.
    ELSEIF wa_grpcta_gral-id_grp+3(9) EQ '000000000'.
      num_level = 4.
    ELSEIF wa_grpcta_gral-id_grp+5(7) EQ '0000000'.
      num_level = 3.
    ELSEIF wa_grpcta_gral-id_grp+7(5) EQ '00000'.
      num_level = 2.
    ELSEIF wa_grpcta_gral-id_grp+9(3) EQ '000'.
      num_level = 1.
    ELSE.
      num_level = 0.
    ENDIF.
    num_levelc = 6 - num_level.
    ADD 1 TO num_level.
    DO num_level TIMES.
      CLEAR text_flxte.
      CONCATENATE text_flxt num_levelc INTO text_flxte.
      ASSIGN (text_flxte) TO <fs_strc>.
      IF sy-index EQ 1.
        <fs_strc> = wa_grpcta_gral-name_grp.
      ELSE.
        CLEAR <fs_strc>.
      ENDIF.
      CLEAR text_flxte.
      CONCATENATE text_flxt_ num_levelc INTO text_flxte.
      ASSIGN (text_flxte) TO <fs_strc>.
      IF sy-index EQ 1.
        <fs_strc> = wa_grpcta_gral-id_grp.
      ELSE.
        CLEAR <fs_strc>.
      ENDIF.
      ADD 1 TO num_levelc.
    ENDDO.
    IF NOT wa_grpcta_gral-hkont IS INITIAL.
      select single waers into moneda from skb1 where BUKRS eq  p_bukrs and SAKNR in wa_grpcta_gral-hkont.
      CASE 'X'.
        WHEN btn_rsm.
          CLEAR: wa_fscrep-tsl_s, wa_fscrep-tsl_h,wa_fscrep-tslvt,wa_fscrep-tsl_t.
          PERFORM get_data_rsmn.
          wa_fscrep-waers = moneda."t001-waers.
          COLLECT wa_fscrep INTO it_fscrep.
        WHEN btn_det.
          PERFORM get_data_detl.
      ENDCASE.
    ENDIF.
  ENDLOOP.
  CASE 'X'.
    WHEN btn_rsm.
      ASSIGN it_fscrep TO <fs_tab>.
      name_strct = 'ZFIES_REPFISC'.
    WHEN btn_det.
      ASSIGN it_fsrpdet0 TO <fs_tab>.
      name_strct = 'ZST_LIBMAY0'.
  ENDCASE.

END-OF-SELECTION.
  DATA: t_ui_function TYPE ui_functions.

  APPEND cl_gui_alv_grid=>mc_fc_print TO t_ui_function.
  APPEND cl_gui_alv_grid=>mc_fc_print_back TO t_ui_function.
  APPEND cl_gui_alv_grid=>mc_fc_print_prev TO t_ui_function.

  obj_alvgd->set_table_for_first_display( EXPORTING i_structure_name = name_strct
    it_toolbar_excluding = t_ui_function
  CHANGING it_outtab        = <fs_tab> ).


  CALL SCREEN 9000.
*&--------------------------*
*&      Module  STATUS_9000  OUTPUT
*&--------------------------*
*       text
*----------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'MAIN'.
  SET TITLEBAR 'TITLE01'.

ENDMODULE.                 " STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " USER_COMMAND_9000  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_CMD_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_cmd_9000 INPUT.
  CASE okcode.
    WHEN 'ZPRN'.
      PERFORM print_alv.
  ENDCASE.
ENDMODULE.                 " USER_CMD_9000  INPUT


*&------------------------*
*&      Form  SET_CATALOG
*&-----------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_catalog .
  FIELD-SYMBOLS: <fs_catalog> TYPE lvc_s_fcat.

  obj_alvgd->get_frontend_fieldcatalog( IMPORTING et_fieldcatalog = it_catalog ).
  LOOP AT it_catalog ASSIGNING <fs_catalog>.
    <fs_catalog>-col_opt = 'X'.
    CHECK <fs_catalog>-fieldname CS 'TSL'.
    <fs_catalog>-do_sum = 'X'.
  ENDLOOP.
  obj_alvgd->set_frontend_fieldcatalog( it_fieldcatalog = it_catalog ).

  obj_alvgd->set_sort_criteria( it_sort  = it_sort ).

  obj_alvgd->refresh_table_display( ).
*    obj_alvgd->get_SORT_CRITERIA( EXPORTING i_structure_name = 'ZFIES_REPFISC'
*                                   CHANGING it_outtab        = it_fscrep
**                                                   it_sort          = it_sort
*                                                    ).
ENDFORM.                    " SET_CATALOG
*&---------------------------------------------------------------------*
*&      Module  ALV_CATALOG  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_catalog OUTPUT.
  PERFORM set_catalog.
ENDMODULE.                 " ALV_CATALOG  OUTPUT

*&      Form  GET_DATA_DETL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_detl .
  DATA: num_do    TYPE i,
        monat     TYPE monat,
        text_flxt TYPE tabname,
        tslvt	    TYPE tslvt12,
        fecant    TYPE budat,
        fecmax    TYPE budat,
        fecbsas   TYPE budat,
        w_t001    TYPE t001.
*


  IF p_arrst EQ 'X'.
    IF zfitb_lglcstr-tp_info EQ 'B'.

      CONCATENATE p_gjahr s_month-low+1(2) '01' INTO fecmax.

      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          DAY_IN            = fecmax
        IMPORTING
          LAST_DAY_OF_MONTH = fecbsas
        EXCEPTIONS
          DAY_IN_NO_DATE    = 1
          OTHERS            = 2.

      SELECT * FROM bsis INTO TABLE it_bsis WHERE xstov  EQ ''
      AND hkont  IN wa_grpcta_gral-hkont
      AND bukrs  EQ p_bukrs
      AND budat  LT fecmax.

      perform buscar_bsas tables it_bsis using fecbsas ''.

      LOOP AT it_bsis INTO wa_bsis.
        CLEAR: wa_fsrpdet-docdat , wa_fsrpdet-doctyp ,
        wa_fsrpdet-docnbr , wa_fsrpdet-ctanbr ,
        wa_fsrpdet-ctatxt , wa_fsrpdet-cmttxt ,
        wa_fsrpdet-waers  , wa_fsrpdet-tsl_abn,
        wa_fsrpdet-tsl_crg, wa_fsrpdet-tsl_sld.
        wa_fsrpdet-doctyp  = wa_bsis-blart.
        wa_fsrpdet-ctanbr  = wa_bsis-hkont.
        wa_fsrpdet-cmttxt  = 'Arrastre de Saldos'.
*       Tratamiento de Montos dependiendo del tipo de Moneda
*       que tiene asociado la cta a evaluar
        IF MONEDA EQ wa_bsis-waers.
          wa_fsrpdet-waers   = wa_bsis-waers.
          wa_fsrpdet-tsl_sld = wa_bsis-WRBTR.
        ELSE.
*         Busco la Moneda Local 1 del documento,
*         para esto viajo a la configuracion de lal sociedad y
*         me tarigo su moneda
          SELECT SINGLE waers into wa_fsrpdet-waers FROM t001
          WHERE bukrs EQ p_bukrs.
          wa_fsrpdet-tsl_sld = wa_bsis-dmbtr.
        ENDIF.

        IF wa_bsis-shkzg EQ 'H'.
          wa_fsrpdet-tsl_sld = -1 * wa_fsrpdet-tsl_sld.
        ENDIF.
        COLLECT wa_fsrpdet INTO it_fsrpdet.
        MOVE-CORRESPONDING wa_fsrpdet TO wa_fsrpdet0.
        COLLECT wa_fsrpdet0 INTO it_fsrpdet0.
      ENDLOOP.

    ELSE.
*     Libro mayor: Totales
      SELECT rtcur racct drcrk hslvt hsl01 hsl02 hsl03 hsl04
      hsl05 hsl06 hsl07 hsl08 hsl09 hsl10
      hsl11 hsl12 hsl13 hsl14 hsl15 hsl16 INTO TABLE it_flxttl FROM faglflext WHERE ryear  EQ p_gjahr
      AND rldnr  EQ wa_lglcstr-rldnr
      AND racct  IN wa_grpcta_gral-hkont
      AND rbukrs EQ p_bukrs.
      LOOP AT it_flxttl INTO wa_flxttl.
        CLEAR tslvt.
        monat = 1.
        DO 12 TIMES.
          CLEAR text_flxt.
          CONCATENATE 'WA_FLXTTL-HSL' monat INTO text_flxt.
          ASSIGN (text_flxt) TO <fs_ttl>.
          CASE wa_flxttl-drcrk.
            WHEN 'S'.
              ADD <fs_ttl> TO tslvt.
            WHEN 'H'.
              ADD <fs_ttl> TO tslvt.
          ENDCASE.
          ADD 1 TO monat.
          IF monat EQ s_month-low.
            EXIT.
          ENDIF.
        ENDDO.
        tslvt = tslvt + wa_flxttl-hslvt.
        CLEAR: wa_fsrpdet-docdat , wa_fsrpdet-doctyp ,
        wa_fsrpdet-docnbr , wa_fsrpdet-ctanbr ,
        wa_fsrpdet-ctatxt , wa_fsrpdet-cmttxt ,
        wa_fsrpdet-waers  , wa_fsrpdet-tsl_abn,
        wa_fsrpdet-tsl_crg, wa_fsrpdet-tsl_sld.
        wa_fsrpdet-ctanbr  = wa_flxttl-racct.
        wa_fsrpdet-waers   = moneda."w_t001-waers.
        wa_fsrpdet-cmttxt  = 'Arrastre de Saldos'.
        wa_fsrpdet-tsl_sld = tslvt.
        COLLECT wa_fsrpdet INTO it_fsrpdet.
        MOVE-CORRESPONDING wa_fsrpdet TO wa_fsrpdet0.
        COLLECT wa_fsrpdet0 INTO it_fsrpdet0.
      ENDLOOP.
    ENDIF.
  ENDIF.

* Libro mayor: Partidas individuales reales
  SELECT ryear docnr rldnr rbukrs rtcur racct hsl tsl drcrk poper gjahr budat belnr INTO TABLE it_grpdetail
  FROM faglflexa
  WHERE ryear EQ p_gjahr
  AND rldnr  EQ wa_lglcstr-rldnr
  AND racct  IN wa_grpcta_gral-hkont
  AND rbukrs EQ p_bukrs
  AND poper  IN s_month.

*** Tomando solo no compensados
  DATA: t_bsis TYPE TABLE OF bsis.

  IF p_prtab EQ 'X'.
    SELECT * FROM bsis INTO TABLE t_bsis
    FOR ALL ENTRIES IN it_grpdetail
    WHERE belnr EQ it_grpdetail-docnr
    AND   bukrs EQ it_grpdetail-rbukr
    AND   gjahr EQ it_grpdetail-ryear
    AND   hkont EQ it_grpdetail-racct.

*   Limpiar la tabla de los documentos que estan abiertos (PA) para dejar los compensado
*   en la tabla it_grpdetail
    LOOP AT it_grpdetail INTO wa_detail.
      READ TABLE t_bsis WITH KEY belnr = wa_detail-docnr
      bukrs = wa_detail-rbukr
      gjahr = wa_detail-ryear
      hkont = wa_detail-racct TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        DELETE table it_grpdetail from wa_detail.
      ENDIF.
    ENDLOOP.
  ENDIF.

  LOOP AT it_grpdetail INTO wa_detail.
    AT NEW racct.
      SELECT SINGLE txt50 INTO wa_fsrpdet-ctatxt FROM skat WHERE spras EQ sy-langu
      AND ktopl EQ t001-ktopl
      AND saknr EQ wa_detail-racct.
    ENDAT.
    AT NEW belnr.
      SELECT SINGLE blart bktxt INTO (wa_fsrpdet-doctyp,wa_fsrpdet-cmttxt) FROM bkpf WHERE bukrs EQ p_bukrs
      AND belnr EQ wa_detail-belnr
      AND gjahr EQ p_gjahr.
    ENDAT.
    wa_fsrpdet-docdat = wa_detail-budat.
    wa_fsrpdet-docnbr = wa_detail-belnr.
    wa_fsrpdet-ctanbr = wa_detail-racct.
    wa_fsrpdet-waers  = wa_detail-rtcur.

*   Tratamiento de Montos dependiendo del tipo de Moneda
*   que tiene asociado la cta a evaluar
    IF MONEDA EQ   wa_detail-rtcur.
      IF wa_detail-hsl GE 0.
        wa_fsrpdet-tsl_abn  = wa_detail-tsl.
      ELSE.
        wa_fsrpdet-tsl_crg = wa_detail-tsl.
      ENDIF.

    else.
*     Busco la Moneda Local 1 del documento,
*     para esto viajo a la configuracion de lal sociedad y
*     me tarigo su moneda
      SELECT SINGLE waers into wa_fsrpdet-ctanbr FROM t001
      WHERE bukrs EQ p_bukrs.
      IF wa_detail-hsl GE 0.
        wa_fsrpdet-tsl_abn  = wa_detail-hsl.
      ELSE.
        wa_fsrpdet-tsl_crg = wa_detail-hsl.
      ENDIF.
    endif.

    wa_fsrpdet-tsl_sld = wa_fsrpdet-tsl_abn + wa_fsrpdet-tsl_crg.
***** Valor Absoluto solicitado por Juan Carlos Marquez *****
    wa_fsrpdet0-tsl_abn = abs( wa_fsrpdet0-tsl_abn ).
    wa_fsrpdet0-tsl_crg = abs( wa_fsrpdet0-tsl_crg ).

    wa_fsrpdet-tsl_abn = abs( wa_fsrpdet-tsl_abn ).
    wa_fsrpdet-tsl_crg = abs( wa_fsrpdet-tsl_crg ).
*************************************************************
    COLLECT wa_fsrpdet INTO it_fsrpdet.
    MOVE-CORRESPONDING wa_fsrpdet TO wa_fsrpdet0.
    COLLECT wa_fsrpdet0 INTO it_fsrpdet0.
    CLEAR: wa_fsrpdet-tsl_abn,wa_fsrpdet-tsl_crg,wa_fsrpdet-tsl_sld.
  ENDLOOP.

ENDFORM.                    " GET_DATA_DETL

*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM print_alv.
  DATA: w_header          TYPE zst_hdrmay,
        lf_fm_name        TYPE rs38l_fnam,
        ls_composer_param TYPE ssfcompop,
        ls_control_param  TYPE ssfctrlop,
        a                 TYPE i.

  CASE zfitb_lglcstr-tp_info.
    WHEN 'G'.
      CLEAR w_header.
*      w_header-LAND1 = gp_land1.
      w_header-bukrs = p_bukrs.
      w_header-monat = s_month.
      w_header-gjahr = p_gjahr.
      w_header-nbrfl = p_folio.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = p_forms
        IMPORTING
          fm_name            = lf_fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      ls_composer_param-tdnewid = 'X'.

      CALL FUNCTION lf_fm_name
        EXPORTING
          control_parameters = ls_control_param
          output_options     = ls_composer_param
          header             = w_header
          items              = it_fsrpdet
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
    WHEN 'D' OR 'M'.
      CLEAR w_header.
*      w_header-LAND1 = gp_land1.
      w_header-bukrs = p_bukrs.
      w_header-monat = s_month.
      w_header-gjahr = p_gjahr.
      w_header-nbrfl = p_folio.
      CASE zfitb_lglcstr-tp_info.
        WHEN 'D'.
          w_header-lib01 = 'X'.
          w_header-lib02 = ''.
        WHEN 'M'.
          w_header-lib01 = ''.
          w_header-lib02 = 'X'.
      ENDCASE.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZSF_LIBMAY'
        IMPORTING
          fm_name            = lf_fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      ls_composer_param-tdnewid = 'X'.

      CALL FUNCTION lf_fm_name
        EXPORTING
          control_parameters = ls_control_param
          output_options     = ls_composer_param
          header             = w_header
          items              = it_fsrpdet
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
    WHEN 'B'.
      DATA: t_transito type ztb_libmay.

      SORT it_fsrpdet BY ctanbr.
      LOOP AT it_fsrpdet INTO w1_fsrpdet.
        AT NEW ctanbr.
          a = STRLEN( w1_fsrpdet-ctanbr ).
          a = a - 1.
          IF w1_fsrpdet-ctanbr+a(1) EQ '0'.
            CONCATENATE w1_fsrpdet-ctanbr(a) '0' INTO ctanbr0.
            CONCATENATE w1_fsrpdet-ctanbr(a) '1' INTO ctanbr1.
            CONCATENATE w1_fsrpdet-ctanbr(a) '2' INTO ctanbr2.
            READ TABLE ti_bnkcon INTO wa_bnkcon WITH KEY nrcta0 = ctanbr0.
            IF sy-subrc EQ 0.
              CONTINUE.
            ENDIF.
            LOOP AT it_fsrpdet INTO wa_fsrpdet WHERE ctanbr EQ ctanbr0
            OR ctanbr EQ ctanbr1
            OR ctanbr EQ ctanbr2.
              CLEAR wa_bnkcon.
              wa_bnkcon-nrcta0 = ctanbr0.
              wa_bnkcon-waers  = wa_fsrpdet-waers.
              CASE wa_fsrpdet-ctanbr.
                WHEN ctanbr0.
*                  wa_bnkcon-cta0sld = wa_fsrpdet-tsl_sld.
                WHEN ctanbr1.
                  wa_bnkcon-cta0sld = wa_fsrpdet-tsl_sld.
                  IF wa_fsrpdet-doctyp EQ 'SA'.
                    wa_bnkcon-cta1SA  = wa_fsrpdet-tsl_sld.
                  ENDIF.

                  IF wa_fsrpdet-doctyp EQ 'AB'.
                    wa_bnkcon-cta1AB  = wa_fsrpdet-tsl_sld.
                  ENDIF.

                  IF wa_fsrpdet-doctyp EQ 'DZ'.
                    wa_bnkcon-cta1dz  = wa_fsrpdet-tsl_sld.
                  ENDIF.
                  IF wa_fsrpdet-doctyp NE 'ZR'.
                    wa_bnkcon-cta1rst = wa_fsrpdet-tsl_sld.
                  ENDIF.
                  IF wa_fsrpdet-doctyp EQ 'ZR'.
                    wa_bnkcon-cta1zr  = wa_fsrpdet-tsl_sld.
                  ENDIF.
                  IF wa_fsrpdet-doctyp EQ 'KZ'.
                    wa_bnkcon-cta1kz  = wa_fsrpdet-tsl_sld.
                  ENDIF.
                  IF wa_fsrpdet-doctyp NE 'DZ' AND wa_fsrpdet-doctyp NE 'ZR' AND wa_fsrpdet-doctyp NE 'KZ'.
                    wa_bnkcon-cta1rs0 = wa_fsrpdet-tsl_sld.
                  ENDIF.
                  IF wa_fsrpdet-doctyp EQ 'DZ' OR wa_fsrpdet-doctyp EQ 'KZ'.
                    APPEND wa_fsrpdet TO t_transito.
                  ENDIF.


                WHEN ctanbr2.

                  wa_bnkcon-cta0sld = wa_fsrpdet-tsl_sld.
                  IF wa_fsrpdet-doctyp NE 'ZR'.
                    wa_bnkcon-cta2rst = wa_fsrpdet-tsl_sld.
                  ENDIF.

                  IF wa_fsrpdet-doctyp EQ 'SA'.
                    wa_bnkcon-cta2SA  = wa_fsrpdet-tsl_sld.
                  ENDIF.

                  IF wa_fsrpdet-doctyp EQ 'AB'.
                    wa_bnkcon-cta2AB  = wa_fsrpdet-tsl_sld.
                  ENDIF.

                  IF wa_fsrpdet-doctyp EQ 'KR'.
                    wa_bnkcon-cta2kR  = wa_fsrpdet-tsl_sld.
                  ENDIF.

                  IF wa_fsrpdet-doctyp EQ 'CI'.
                    wa_bnkcon-cta2CI  = wa_fsrpdet-tsl_sld.
                  ENDIF.

                  IF wa_fsrpdet-doctyp EQ 'KZ'.
                    wa_bnkcon-cta2kz  = wa_fsrpdet-tsl_sld.
                  ENDIF.
                  IF wa_fsrpdet-doctyp EQ 'ZR'.
                    wa_bnkcon-cta2zr  = wa_fsrpdet-tsl_sld.
                  ENDIF.
                  IF wa_fsrpdet-doctyp NE 'ZR' AND wa_fsrpdet-doctyp NE 'KZ'.
                    wa_bnkcon-cta2rs0 = wa_fsrpdet-tsl_sld.
                  ENDIF.

              ENDCASE.
              COLLECT wa_bnkcon INTO ti_bnkcon.
            ENDLOOP.
          ENDIF.
        ENDAT.
      ENDLOOP.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZSF_CONCIL'
        IMPORTING
          fm_name            = lf_fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      ls_composer_param-tdnewid = 'X'.

      CALL FUNCTION lf_fm_name
        EXPORTING
          control_parameters = ls_control_param
          output_options     = ls_composer_param
          items              = ti_bnkcon
          bukrs              = p_bukrs
          poper              = s_month-low
          gjahr              = p_gjahr
          trans              = t_transito
          MONSOC             = MONEDA
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.

  ENDCASE.
ENDFORM. " PRINT_ALV
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_BSAS
*&---------------------------------------------------------------------*

FORM BUSCAR_BSAS  TABLES   tabla STRUCTURE bsis using fecmax arrastre.

  select * from bsas appending corresponding fields of table tabla
  where hkont  IN wa_grpcta_gral-hkont
  AND bukrs  EQ p_bukrs
  and AUGDT  ge fecmax
  AND budat  Le fecmax
  and xstov  EQ ''.

ENDFORM.                    " BUSCAR_BSAS
