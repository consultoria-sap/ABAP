*&---------------------------------------------------------------------*
*&      Form  EXTEND_MAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_SOLMAT  text
*      -->P_TEST  text
*----------------------------------------------------------------------*
FORM extend_mat  USING    p_it_solmat TYPE ty_solmat
                          p_test.
  DATA: bapi_head LIKE bapimathead,
        bapi_plantdata LIKE bapi_marc,
        bapi_plantdatax LIKE  bapi_marcx,
        bapi_storagelocationdata LIKE bapi_mard,
        bapi_storagelocationdatax LIKE bapi_mardx,
        bapi_valuationdata LIKE bapi_mbew,
        bapi_valuationdatax LIKE bapi_mbewx,
        bapi_return LIKE bapiret2.

  DATA: l_message_v1(50) TYPE c,
        l_message(50) TYPE c,
        l_docdata LIKE sodocchgi1,
        l_objcont LIKE soli OCCURS 0 WITH HEADER LINE,
        l_receiver LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
        l_tdname TYPE thead-tdname,
        l_tdid TYPE thead-tdid,
        l_tdobject TYPE thead-tdobject,
        ls_header LIKE thead,
        lt_lines  TYPE STANDARD TABLE OF tline WITH HEADER LINE,
        lv_matnr TYPE matnr.

  DATA:BEGIN OF it_ret OCCURS 0.
          INCLUDE STRUCTURE bapiret2.
  DATA END OF it_ret.

  CLEAR wa_gesmat.
  SELECT SINGLE *
    INTO wa_gesmat
    FROM zmmtb_gesmat
    WHERE zsolm = it_solmat-zsolm.

  bapi_head-material        = p_it_solmat-matnr.
  bapi_head-basic_view      = 'X'. " Vista de datos básicos
  bapi_head-sales_view      = 'X'. " Vista de Comercial
  bapi_head-purchase_view   = ''. " Vista de compras
  bapi_head-mrp_view        = 'X'.  " Vista de planificación de necesidades
  bapi_head-forecast_view   = ''.  " Vista de pronósticos
  bapi_head-work_sched_view = ''.  " Vista de preparación de trabajo
  bapi_head-prt_view        = ''.  " Vista medios auxiliares de fabricación
  bapi_head-storage_view    = 'X'. " Vista de almacén
  bapi_head-warehouse_view  = 'X'. " Vista de gestión de almacenes
  bapi_head-quality_view    = ''. " Vista de gestión de calidad
  bapi_head-account_view    = 'X'. " Vista de contabilidad
  bapi_head-cost_view       = ''.  " Vista de cálculo de coste

  IF p_it_solmat-werkd IS NOT INITIAL.
    bapi_plantdata-plant = p_it_solmat-werkd.
    bapi_plantdatax-plant = p_it_solmat-werkd.
  ENDIF.

  IF wa_gesmat-dismm IS NOT INITIAL.
    bapi_plantdata-mrp_type = wa_gesmat-dismm.
    bapi_plantdatax-mrp_type = 'X'.
  ENDIF.

  IF wa_gesmat-ekgrp IS NOT INITIAL.
    bapi_plantdata-pur_group = wa_gesmat-ekgrp.
    bapi_plantdatax-pur_group = 'X'.
  ENDIF.

  IF p_it_solmat-dispo IS NOT INITIAL.
    bapi_plantdata-mrp_ctrler = p_it_solmat-dispo.
    bapi_plantdatax-mrp_ctrler = 'X'.
  ENDIF.

  SELECT SINGLE lagpr
    INTO bapi_plantdata-stor_costs
    FROM t439l
    WHERE werks = p_it_solmat-werkd.

  bapi_plantdatax-stor_costs = 'X'.

  IF wa_gesmat-disls IS NOT INITIAL.
    bapi_plantdata-lotsizekey = wa_gesmat-disls.
    bapi_plantdatax-lotsizekey = 'X'.
  ENDIF.


  IF wa_gesmat-plifz IS NOT INITIAL.
    bapi_plantdata-plnd_delry = wa_gesmat-plifz.
    bapi_plantdatax-plnd_delry = 'X'.
  ENDIF.

  IF wa_gesmat-fhori IS NOT INITIAL.
    bapi_plantdata-sm_key = wa_gesmat-fhori.
    bapi_plantdatax-sm_key = 'X'.
  ENDIF.

  IF wa_gesmat-mtvfp IS NOT INITIAL.
    bapi_plantdata-availcheck = wa_gesmat-mtvfp.
    bapi_plantdatax-availcheck = 'X'.
  ENDIF.

*** CAMPO DE ALMACEN PROPUESTO PARA APROVISIONAMIENTO EXTERNO
  IF wa_gesmat-lgfsb IS NOT INITIAL.
    bapi_plantdata-sloc_exprc = wa_gesmat-lgfsb.
    bapi_plantdatax-sloc_exprc = 'X'.
  ENDIF.
* FIN MOD.
  IF wa_gesmat-prctr IS NOT INITIAL.
    bapi_plantdata-profit_ctr = wa_gesmat-prctr.
    bapi_plantdatax-profit_ctr = 'X'.
  ENDIF.

  bapi_storagelocationdata-plant = p_it_solmat-werkd.
  bapi_storagelocationdatax-plant = p_it_solmat-werkd.

  bapi_storagelocationdata-stge_loc = p_it_solmat-lgord.
  bapi_storagelocationdatax-stge_loc = p_it_solmat-lgord.

  bapi_storagelocationdata-stge_bin  = wa_gesmat-lgpbe.
  bapi_storagelocationdatax-stge_bin = 'X'.


  SELECT SINGLE bwkey
    INTO bapi_valuationdata-val_area
    FROM t001w
    WHERE werks = p_it_solmat-werkd.

  bapi_valuationdata-moving_pr = p_it_solmat-verpr.
  bapi_valuationdata-val_class = wa_gesmat-bklas.
  bapi_valuationdata-vm_p_stock = wa_gesmat-qklas.
  bapi_valuationdata-pr_ctrl_py = 'V'.
  bapi_valuationdata-pr_ctrl_pp = 'V'.

  bapi_valuationdatax-val_area = bapi_valuationdata-val_area.
  bapi_valuationdatax-moving_pr = 'X'.
  bapi_valuationdatax-val_class = 'X'.
  bapi_valuationdatax-vm_p_stock = 'X'.
  bapi_valuationdatax-pr_ctrl_py = 'X'.
  bapi_valuationdatax-pr_ctrl_pp = 'X'.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata             = bapi_head
      plantdata            = bapi_plantdata
      plantdatax           = bapi_plantdatax
      storagelocationdata  = bapi_storagelocationdata
      storagelocationdatax = bapi_storagelocationdatax
      valuationdata        = bapi_valuationdata
      valuationdatax       = bapi_valuationdatax
    IMPORTING
      return               = bapi_return.

  APPEND bapi_return TO it_ret.

  CLEAR wa_gsmlog.
  READ TABLE it_ret WITH KEY type = 'S'.
  IF sy-subrc EQ 0.
    IF p_test EQ ''.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

      CLEAR: it_text, it_text[].

      l_tdname = p_it_solmat-zsolm.
      l_tdid = 'ZSLM'.
      l_tdobject = 'ZSOLMAT'.

      "Texto Largo ESP
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = l_tdid
          language                = 'S'
          name                    = l_tdname
          object                  = l_tdobject
        TABLES
          lines                   = it_text
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc = 0.
        CLEAR: ls_header, lt_lines[].

        ls_header-tdobject  = 'MATERIAL'.
        ls_header-tdname    = bapi_head-material.
        ls_header-tdid      = 'BEST'. " 'GRUN'.
        ls_header-tdspras   = 'S'.

        LOOP AT it_text.
          lt_lines-tdline = it_text.
          APPEND lt_lines.
        ENDLOOP.

        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
            client          = sy-mandt
            header          = ls_header
            savemode_direct = 'X'
          TABLES
            lines           = lt_lines
          EXCEPTIONS
            OTHERS          = 1.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'DELETE_TEXT'
            EXPORTING
              client          = sy-mandt
              id              = l_tdid
              language        = 'S'
              name            = l_tdname
              object          = l_tdobject
              savemode_direct = 'X'
            EXCEPTIONS
              not_found       = 1
              OTHERS          = 2.
        ENDIF.
      ENDIF.

      CLEAR: it_text, it_text[].

      "Texto Largo ENG
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = l_tdid
          language                = 'E'
          name                    = l_tdname
          object                  = l_tdobject
        TABLES
          lines                   = it_text
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc = 0.
        CLEAR: ls_header, lt_lines[].

        ls_header-tdobject  = 'MATERIAL'.
        ls_header-tdname    = bapi_head-material.
        ls_header-tdid      = 'BEST'.  " 'GRUN'.
        ls_header-tdspras   = 'E'.

        LOOP AT it_text.
          lt_lines-tdline = it_text.
          APPEND lt_lines.
        ENDLOOP.

        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
            client          = sy-mandt
            header          = ls_header
            savemode_direct = 'X'
          TABLES
            lines           = lt_lines
          EXCEPTIONS
            OTHERS          = 1.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'DELETE_TEXT'
            EXPORTING
              client          = sy-mandt
              id              = l_tdid
              language        = 'E'
              name            = l_tdname
              object          = l_tdobject
              savemode_direct = 'X'
            EXCEPTIONS
              not_found       = 1
              OTHERS          = 2.
        ENDIF.
      ENDIF.

      CLEAR: it_text, it_text[].
      l_tdobject = 'ZSOLMIN'.

      "Texto Inspección ESP
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = l_tdid
          language                = 'S'
          name                    = l_tdname
          object                  = l_tdobject
        TABLES
          lines                   = it_text
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.
      IF sy-subrc = 0.
        CLEAR: ls_header, lt_lines[].

        ls_header-tdobject  = 'MATERIAL'.
        ls_header-tdname    = bapi_head-material.
        ls_header-tdid      = 'PRUE'.
        ls_header-tdspras   = 'S'.

        LOOP AT it_text.
          lt_lines-tdline = it_text.
          APPEND lt_lines.
        ENDLOOP.

        CALL FUNCTION 'SAVE_TEXT'
          EXPORTING
            client          = sy-mandt
            header          = ls_header
            savemode_direct = 'X'
          TABLES
            lines           = lt_lines
          EXCEPTIONS
            OTHERS          = 1.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'DELETE_TEXT'
            EXPORTING
              client          = sy-mandt
              id              = l_tdid
              language        = 'S'
              name            = l_tdname
              object          = l_tdobject
              savemode_direct = 'X'
            EXCEPTIONS
              not_found       = 1
              OTHERS          = 2.
        ENDIF.
      ENDIF.

      UPDATE zmmtb_solmat
      SET zestd = 'F'
      WHERE zsolm = p_it_solmat-zsolm.

      UPDATE zmmtb_gesmat
      SET zejec = 'X'
      WHERE zsolm = p_it_solmat-zsolm.

      CLEAR: l_objcont, l_objcont[].
      WRITE 'Estimado usuario' TO l_objcont-line.
      APPEND l_objcont.

      CLEAR l_objcont.
      WRITE 'Su solicitud ha sido procesada en el sistema SAP'
      TO l_objcont-line.
      APPEND l_objcont.

      CLEAR l_objcont.
      CONCATENATE 'Solicitud:'
                  p_it_solmat-zsolm
      INTO l_objcont-line SEPARATED BY space.
      APPEND l_objcont.

      CLEAR l_objcont.
      WRITE 'Extendido' TO l_objcont-line.
      APPEND l_objcont.

      CLEAR l_objcont.
      lv_matnr = p_it_solmat-matnr.
      PERFORM quitar_ceros CHANGING lv_matnr.
      CONCATENATE 'Material:'
                  lv_matnr "p_it_solmat-matnr
      INTO l_objcont-line SEPARATED BY space.
      APPEND l_objcont.

      CLEAR l_objcont.
      WRITE 'Muchas gracias' TO l_objcont-line.
      APPEND l_objcont.

      CLEAR: l_receiver, l_receiver[].
      SELECT SINGLE adr6~smtp_addr
        INTO l_receiver-receiver
        FROM adr6
        INNER JOIN usr21
        ON adr6~persnumber = usr21~persnumber
        AND adr6~addrnumber = usr21~addrnumber
        WHERE usr21~bname = p_it_solmat-bname.

      MOVE: 'X'      TO l_receiver-express,
            'U'      TO l_receiver-rec_type.
      APPEND l_receiver.

      CLEAR: l_docdata.
      CONCATENATE 'Solicitud'
                  lv_matnr "p_it_solmat-zsolm
                  ': Material Extendido'
      INTO l_docdata-obj_descr
      SEPARATED BY space.

      PERFORM send_mail TABLES  l_objcont
                                l_receiver
                        USING   l_docdata.
    ENDIF.
    DELETE it_gsmlog WHERE zsolm = p_it_solmat-zsolm.
  ELSE.
    LOOP AT it_ret INTO bapi_return WHERE type <> 'S'.
      CLEAR wa_gsmlog.
      wa_gsmlog-zsolm = p_it_solmat-zsolm.
      IF bapi_return-type EQ 'W' OR bapi_return-type EQ 'I'.
        wa_gsmlog-id = icon_yellow_light.
      ELSE.
        wa_gsmlog-id = icon_red_light.
      ENDIF.
      wa_gsmlog-datum = sy-datum.
      wa_gsmlog-uzeit = sy-uzeit.
      wa_gsmlog-bname = sy-uname.
      wa_gsmlog-zmesg = bapi_return-message.
      l_message_v1 = bapi_return-message_v1.
      PERFORM replace_field_by_desc USING l_message_v1
                                    CHANGING l_message.
      IF l_message IS NOT INITIAL.
        REPLACE FIRST OCCURRENCE OF l_message_v1
        IN wa_gsmlog-zmesg WITH l_message.
      ENDIF.
      APPEND wa_gsmlog TO it_gsmlog .
*      MODIFY zmmtb_gsmlog FROM wa_gsmlog.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " EXTEND_MAT
