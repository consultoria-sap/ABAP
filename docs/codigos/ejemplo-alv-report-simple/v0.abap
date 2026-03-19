* Fuente: https://foros.consultoria-sap.com/t/22292/2?u=sidv *
* Autor: farosales *

*&---------------------------------------------------------------------*
*& Report  ZDEMO_ALVGRID_EDIT                                          *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Example of a simple ALV Grid Report                                 *
*& ...................................                                 *
*&                                                                     *
*& The basic ALV grid, Enhanced to display specific fields as          *
*& editable depending on field value                                   *
*&---------------------------------------------------------------------*

REPORT  ZDEMO_ALVGRID_EDIT                 .

TABLES:     ekko.

TYPE-POOLS: slis.                                 "ALV Declarations
*Data Declaration
*----------------
TYPES: BEGIN OF t_ekko,
  ebeln TYPE ekpo-ebeln,
  ebelp TYPE ekpo-ebelp,
  statu TYPE ekpo-statu,
  aedat TYPE ekpo-aedat,
  matnr TYPE ekpo-matnr,
  menge TYPE ekpo-menge,
  meins TYPE ekpo-meins,
  netpr TYPE ekpo-netpr,
  peinh TYPE ekpo-peinh,
  field_style  TYPE lvc_t_styl, "FOR DISABLE
 END OF t_ekko.

DATA: it_ekko TYPE STANDARD TABLE OF t_ekko INITIAL SIZE 0,
      wa_ekko TYPE t_ekko.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE.
DATA: it_fieldcat TYPE lvc_t_fcat,     "slis_t_fieldcat_alv WITH HEADER LINE,
      wa_fieldcat TYPE lvc_s_fcat,

      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE lvc_s_layo,     "slis_layout_alv,
      gd_repid     LIKE sy-repid.


************************************************************************
*Start-of-selection.
START-OF-SELECTION.

  PERFORM data_retrieval.
  PERFORM set_specific_field_attributes.
  PERFORM build_fieldcatalog.
  PERFORM build_layout.
  PERFORM display_alv_report.


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       Build Fieldcatalog for ALV Report
*----------------------------------------------------------------------*
FORM build_fieldcatalog.

  wa_fieldcat-fieldname   = 'EBELN'.
  wa_fieldcat-scrtext_m   = 'Purchase Order'.
  wa_fieldcat-col_pos     = 0.
  wa_fieldcat-outputlen   = 10.
  wa_fieldcat-emphasize   = 'X'.
  wa_fieldcat-key         = 'X'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'EBELP'.
  wa_fieldcat-scrtext_m   = 'PO Item'.
  wa_fieldcat-col_pos     = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'STATU'.
  wa_fieldcat-scrtext_m   = 'Status'.
  wa_fieldcat-col_pos     = 2.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'AEDAT'.
  wa_fieldcat-scrtext_m   = 'Item change date'.
  wa_fieldcat-col_pos     = 3.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'MATNR'.
  wa_fieldcat-scrtext_m   = 'Material Number'.
  wa_fieldcat-col_pos     = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'MENGE'.
  wa_fieldcat-scrtext_m   = 'PO quantity'.
  wa_fieldcat-col_pos     = 5.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'MEINS'.
  wa_fieldcat-scrtext_m   = 'Order Unit'.
  wa_fieldcat-col_pos     = 6.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'NETPR'.
  wa_fieldcat-scrtext_m   = 'Net Price'.
  wa_fieldcat-edit        = 'X'. "sets whole column to be editable
  wa_fieldcat-col_pos     = 7.
  wa_fieldcat-outputlen   = 15.
  wa_fieldcat-datatype     = 'CURR'.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.

  wa_fieldcat-fieldname   = 'PEINH'.
  wa_fieldcat-scrtext_m   = 'Price Unit'.
  wa_fieldcat-col_pos     = 8.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR  wa_fieldcat.
ENDFORM.                    " BUILD_FIELDCATALOG


*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       Build layout for ALV grid report
*----------------------------------------------------------------------*
FORM build_layout.
* Set layout field for field attributes(i.e. input/output)
  gd_layout-stylefname = 'FIELD_STYLE'.
  gd_layout-zebra             = 'X'.
ENDFORM.                    " BUILD_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       Display report using ALV grid
*----------------------------------------------------------------------*
FORM display_alv_report.
  gd_repid = sy-repid.

*  call function 'REUSE_ALV_GRID_DISPLAY'
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
       EXPORTING
            i_callback_program      = gd_repid
*            i_callback_user_command = 'USER_COMMAND'
            is_layout_lvc               = gd_layout
            it_fieldcat_lvc             = it_fieldcat
            i_save                  = 'X'
       TABLES
            t_outtab                = it_ekko
       EXCEPTIONS
            program_error           = 1
            OTHERS                  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       Retrieve data form EKPO table and populate itab it_ekko
*----------------------------------------------------------------------*
FORM data_retrieval.
  SELECT ebeln ebelp statu aedat matnr menge meins netpr peinh
   UP TO 10 ROWS
    FROM ekpo
    INTO  CORRESPONDING FIELDS OF TABLE it_ekko.

ENDFORM.                    " DATA_RETRIEVAL


*&---------------------------------------------------------------------*
*&      Form  set_specific_field_attributes
*&---------------------------------------------------------------------*
*       populate FIELD_STYLE table with specific field attributes
*----------------------------------------------------------------------*
form set_specific_field_attributes .
  DATA ls_stylerow TYPE lvc_s_styl .
  DATA lt_styletab TYPE lvc_t_styl .

* Populate style variable (FIELD_STYLE) with style properties
*
* The NETPR field/column has been set to editable in the fieldcatalog...
* The following code sets it to be disabled(display only) if 'NETPR'
* is gt than 10.
  LOOP AT it_ekko INTO wa_ekko.
    IF wa_ekko-netpr GT 10.
      ls_stylerow-fieldname = 'NETPR' .
      ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
                                             "set field to disabled
      APPEND ls_stylerow  TO wa_ekko-field_style.
      MODIFY it_ekko FROM wa_ekko.
    ENDIF.
  ENDLOOP.

endform.                    " set_specific_field_attributes
