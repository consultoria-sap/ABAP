*&---------------------------------------------------------------------*
*&      Form  set_filepath
*&---------------------------------------------------------------------*
* Este FORM sirve para el explorador en el que se selecciona el archivo
*----------------------------------------------------------------------*
form set_filepath  changing po_ruta type rlgrap-filename.

  constants: c_ext_exl   type string     value '*.XLS'.

  data: lt_filetable type filetable,
        lx_filetable type file_table,
        wl_sel_text  type string,
        lv_rc type i.

  clear po_ruta.

  wl_sel_text = text-s01.

  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      window_title            = wl_sel_text
      default_extension       = c_ext_exl
    changing
      file_table              = lt_filetable
      rc                      = lv_rc
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
    read table lt_filetable into lx_filetable index 1.
    check sy-subrc eq 0.
    po_ruta = lx_filetable-filename.
  endif.


endform.                    " SET_FILEPATH

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_EXCEL_IT
*&---------------------------------------------------------------------*
form upload_excel_it using    pi_ruta type rlgrap-filename
                     changing to_file type type_t_datos.


  types: begin of type_excel,
       matnr(18) type c, "Material
       extwg(1) type c,
  end of type_excel.

  data: tl_exc type standard table of type_excel.
  data: it_raw type truxs_t_text_data.


  field-symbols: <fs> type type_excel,
                 <fo> type line of type_t_datos.

  refresh: to_file, tl_exc.

  call function 'TEXT_CONVERT_XLS_TO_SAP'
    exporting
*     I_FIELD_SEPERATOR    =
*     i_line_header        = 'X'
      i_tab_raw_data       = it_raw       " WORK TABLE
      i_filename           = pi_ruta
    tables
      i_tab_converted_data = tl_exc[]    "ACTUAL DATA
    exceptions
      conversion_failed    = 1
      others               = 2.

  if ( sy-subrc <> 0 ).
    message text-e02  type 'I' display like 'E'.
  else.

    delete  tl_exc index 1.                    "eliminar la cabecera

    loop at tl_exc assigning <fs>.

      append initial line to to_file assigning <fo>. "ME QUITA LA PRIMER FILA DE LA CABECERA DEL EXCEL

      perform conversion_sap_format using <fs>-matnr changing <fo>-matnr. "AGREGO LOS CAMPOS
      perform conversion_sap_format using <fs>-extwg changing <fo>-extwg. "AGREGO LOS CAMPOS

  endloop.


data: crit type extwg.
clear wa_criticidad.
  loop at to_file into wa_criticidad.

call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
 exporting
  input = wa_criticidad-extwg
 importing
  output = crit.


wa_bapimathead-material = wa_criticidad-matnr.
wa_bapimathead-basic_view = 'X'.

wa_check_update-extmatlgrp = 'X'.
wa_bapi_mara-extmatlgrp = crit.

call function 'BAPI_MATERIAL_SAVEDATA'
exporting
headdata = wa_bapimathead
clientdata = wa_bapi_mara
clientdatax = wa_check_update
importing
return = status_bapi.

  if status_bapi-type = 'S'.
      call function 'BAPI_TRANSACTION_COMMIT'.
  endif.
wa_criticidad-extwg = crit.
 modify to_file from wa_criticidad transporting extwg.
  endloop.


endif.

endform.                    " UPLOAD_EXCEL_IT
*&---------------------------------------------------------------------*
*&      Form  CARGAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form cargar_alv.

  perform init_fieldcat.
  perform init_layout.
  perform mostrar_alv_01.

endform.                    " CARGAR_ALV

*&---------------------------------------------------------------------*
*&      Form  init_fieldcat
*&---------------------------------------------------------------------*
*       Informacion de cada columna del ALV
*----------------------------------------------------------------------*
form init_fieldcat.

  refresh: gt_fieldcat.

  gt_fieldcat-tabname       = 'TI_DATA'.
  gt_fieldcat-fieldname     = 'MATNR'.
  gt_fieldcat-ddictxt       = 'L'.
  gt_fieldcat-seltext_l     = 'Material'.
  append gt_fieldcat. clear gt_fieldcat.

    gt_fieldcat-tabname       = 'TI_DATA'.
  gt_fieldcat-fieldname     = 'EXTWG'.
  gt_fieldcat-ddictxt       = 'L'.
  gt_fieldcat-seltext_l     = 'Criticidad'.
  append gt_fieldcat. clear gt_fieldcat.


endform.                    " init_fieldcat



*&---------------------------------------------------------------------*
*&      Form  init_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form init_layout.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra             = 'X'.
endform.                    " init_layout


*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_ALV_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form mostrar_alv_01.

  call function 'REUSE_ALV_GRID_DISPLAY'
     exporting
        i_callback_program             = g_repid
*        i_callback_user_command        = 'USER_COMMAND_01'
*        i_callback_pf_status_set       = 'SET_PF_STATUS_01'
*        i_structure_name               = 'T_OUTTAB'
        is_layout                      = gs_layout
        it_fieldcat                    = gt_fieldcat[]
*        it_sort                        = gt_sort[]
*        it_excluding                   = gt_exclude[]
*        I_DEFAULT                      = 'X'
        i_save                         = ' '           "Grabar Variante
         is_variant                     = ls_vari
         it_events                      = gt_events[]
*        IT_EVENT_EXIT                  =
*        IS_PRINT                       =
*        IS_REPREP_ID                   =
*        I_SCREEN_START_COLUMN          = 0
*        I_SCREEN_START_LINE            = 0
*        I_SCREEN_END_COLUMN            = 0
*        I_SCREEN_END_LINE              = 0
*     IMPORTING
*        E_EXIT_CAUSED_BY_CALLER        =
*        ES_EXIT_CAUSED_BY_USER         =
     tables
        t_outtab                       = ti_data
     exceptions
        program_error                  = 1
        others                         = 2.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " MOSTRAR_ALV_01


*---------------------------------------------------------------------*
*       FORM USER_COMMAND_01  Process Call Back Events (Begin)         *
*---------------------------------------------------------------------*
form user_command_01 using ucomm    like sy-ucomm
                        selfield type slis_selfield.

endform.                    "user_command_01
*&---------------------------------------------------------------------*
*       FORM SET_PF_STATUS_01
*&---------------------------------------------------------------------*
form set_pf_status_01 using lt_cua_exclude type slis_t_extab.

  data: lf_gui_status  type gui_status.

  set pf-status 'ZZSTANDARD'.

endform.                    "set_pf_status_01
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_SAP_FORMAT
*&---------------------------------------------------------------------*
form conversion_sap_format  using    pi_output
                            changing po_output.

  call function 'CONVERSION_EXIT_ALPHA_INPUT'
    exporting
      input  = pi_output
    importing
      output = po_output.

endform.                    " CONVERSION_SAP_FORMAT
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_SAP_UNIT
*&---------------------------------------------------------------------*
form conversion_sap_unit  using    pi_output
                          changing po_output.

      call function 'CONVERSION_EXIT_CUNIT_INPUT'
        exporting
          input          = pi_output
          language       = sy-langu
        importing
          output         = po_output
        exceptions
          unit_not_found = 1.

      if sy-subrc <> 0.
        clear po_output.
      endif.

endform.                    " CONVERSION_SAP_FORMAT
*&---------------------------------------------------------------------*
*&      Form  CONVERSION_SAP_NUM
*&---------------------------------------------------------------------*
form conversion_sap_num  using    pi_output
                          changing po_output.

      call function 'MOVE_CHAR_TO_NUM'
        exporting
          chr             = pi_output
        importing
          num             = po_output
        exceptions
          convt_no_number = 1
          convt_overflow  = 2
          others          = 3.

      if sy-subrc <> 0.
        clear po_output.
      endif.

endform.                    " CONVERSION_SAP_FORMAT
