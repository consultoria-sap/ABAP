*&---------------------------------------------------------------------*
*& Report  ZSD_LISTADO_DE_CLIENTES
*&
*&---------------------------------------------------------------------*
*& http://foros.consultoria-sap.com/t/creacion-de-un-listado-de-clientes/13891/41
*&
*&---------------------------------------------------------------------*

REPORT  ZSD_LISTADO_DE_CLIENTES.

TABLES: KNA1, KNVV, KNVP, VBAK, VBAP,PA0001.


DATA: IT_FIELDCAT                 TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      WA_FIELDCAT                 TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      GD_TAB_GROUP                TYPE SLIS_T_SP_GROUP_ALV,
      GD_LAYOUT                   TYPE SLIS_LAYOUT_ALV,
      GD_REPID                    LIKE SY-REPID,
      GT_EVENTS                   TYPE SLIS_T_EVENT,
      GD_PRNTPARAMS               TYPE SLIS_PRINT_ALV,
      IT_SORTCAT                  TYPE SLIS_T_SORTINFO_ALV,
      TEXTO(120).

DATA: BEGIN OF LISTADO OCCURS 0,
  STCD1 TYPE KNA1-STCD1,
  ORT01 TYPE KNA1-ORT01,
  NAME1 TYPE KNA1-NAME1,
  VKBUR TYPE KNVV-VKBUR,
  VKGRP TYPE KNVV-VKGRP,
  PLTYP TYPE KNVV-PLTYP,
  KUNNR TYPE KNVP-KUNNR,
  PERNR TYPE KNVP-PERNR,
  PARVW TYPE KNVP-PARVW,
  SNAME TYPE PA0001-SNAME,

END OF LISTADO.

SELECTION-SCREEN BEGIN OF BLOCK TEXT-001 WITH FRAME TITLE TEXT-004.
PARAMETERS: VKBUR TYPE KNVV-VKBUR DEFAULT '008' OBLIGATORY,
            VKGRP TYPE KNVV-VKGRP DEFAULT '004' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK TEXT-001.


START-OF-SELECTION.
  PERFORM DATOS.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM DATOS.

  SELECT KUNNR VKBUR PLTYP VKGRP
   INTO (KNVV-KUNNR, KNVV-VKBUR, KNVV-PLTYP, KNVV-VKGRP)
    FROM KNVV
    WHERE VKBUR EQ VKBUR
      AND VKGRP EQ VKGRP.

    SELECT SINGLE PERNR
     INTO KNVP-PERNR
      FROM KNVP
       WHERE KUNNR EQ KNVV-KUNNR
        AND PARVW EQ 'VE'.

    IF SY-SUBRC NE 0.

      SELECT SINGLE SNAME
        INTO PA0001-SNAME
         FROM PA0001
          WHERE PERNR EQ KNVP-PERNR.

      SELECT SINGLE NAME1 ORT01 STCD1
        INTO (KNA1-NAME1, KNA1-ORT01, KNA1-STCD1)
         FROM KNA1
          WHERE KUNNR EQ KNVV-KUNNR.
      LISTADO-VKBUR = KNVV-VKBUR.
      LISTADO-VKGRP = KNVV-VKGRP.
      LISTADO-PLTYP = KNVV-PLTYP.
      LISTADO-KUNNR = KNVV-KUNNR.
      LISTADO-PERNR = KNVP-PERNR.
      LISTADO-PARVW = 'VE'.
      LISTADO-SNAME = PA0001-SNAME.
      LISTADO-NAME1 = KNA1-NAME1.
      LISTADO-ORT01 = KNA1-ORT01.
      LISTADO-STCD1 = KNA1-STCD1.
      APPEND LISTADO.
      CLEAR LISTADO.
    ENDIF.
  ENDSELECT.
  PERFORM CAMPOS_ALV.
  PERFORM ORDENAR_ALV.
  PERFORM LAYOUT.
  PERFORM ALV_REPORT.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CAMPOS_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM CAMPOS_ALV .

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'NAME1' .
  it_fieldcat-tabname   = 'LISTADO'.
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'NOM. CLIENTE'.
  IT_FIELDCAT-OUTPUTLEN = '16'.
  APPEND it_fieldcat to wa_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'KUNNR' .
  it_fieldcat-tabname   = 'LISTADO'.
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'COD. CLIENTE'.
  IT_FIELDCAT-OUTPUTLEN = '16'.
  APPEND it_fieldcat to wa_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'STCD1' .
  it_fieldcat-tabname   = 'LISTADO' .
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'NIT'.
  IT_FIELDCAT-OUTPUTLEN = '16'.
  APPEND it_fieldcat to wa_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'ORT01' .
  it_fieldcat-tabname   = 'LISTADO' .
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'CIUDAD'.
  IT_FIELDCAT-OUTPUTLEN = '16'.
  APPEND it_fieldcat to wa_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'VKBUR' .
  it_fieldcat-tabname   = 'LISTADO' .
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'OFI. VENTA'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND it_fieldcat to wa_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'VKGRP' .
  it_fieldcat-tabname   = 'LISTADO'.
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'GRUP. VENDEDOR'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND it_fieldcat to wa_fieldcat.


  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'PARVW' .
  it_fieldcat-tabname   = 'LISTADO'.
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'INTERL. VENDEDOR'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND it_fieldcat to wa_fieldcat.

  CLEAR it_fieldcat.
  it_fieldcat-fieldname = 'PLTYP' .
  it_fieldcat-tabname   = 'LISTADO'.
  it_fieldcat-key       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'LIST. PRECIOS'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND it_fieldcat to wa_fieldcat.

ENDFORM.      " CAMPOS_ALV
*&---------------------------------------------------------------------*
*&      Form  ORDENAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ORDENAR_ALV .
  SORT LISTADO BY NAME1.

  DATA: IT_sort TYPE slis_sortinfo_alv.

*  CLEAR IT_SORT.
*  IT_sort-spos = 1.
*  IT_sort-fieldname = 'CHECK'.
*  IT_sort-up = 'X'.
*  IT_sort-subtot = 'X'.
*  IT_SORT-EXPA = 'X'. " Sirve para que salgan los subtotales
*  APPEND IT_sort TO IT_SORTCAT.

  CLEAR IT_SORT.
  IT_sort-spos = 1.
  IT_sort-fieldname = 'NAME1'.
  IT_sort-up = 'X'.
  IT_sort-subtot = 'X'.
*  IT_SORT-EXPA = 'X'. " Sirve para que salgan los subtotales
  APPEND IT_sort TO IT_SORTCAT.
ENDFORM.                           " ORDENAR_ALV
*&---------------------------------------------------------------------*
*&      Form  LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LAYOUT .
  GD_LAYOUT-NO_INPUT           = 'X'.
  GD_LAYOUT-COLWIDTH_OPTIMIZE  = 'X'.
  GD_LAYOUT-TOTALS_TEXT        = 'TOTALS'(201).
  GD_LAYOUT-ZEBRA              = 'X'.
ENDFORM.                    " LAYOUT
*------------------------------------------------------------------*
*       FORM USER_COMMAND                                          *
*------------------------------------------------------------------*
*       --> R_UCOMM                                                *
*       --> RS_SELFIELD                                            *
*------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.
  RS_SELFIELD-REFRESH = 'X'.

* Check function code
  CASE R_UCOMM.
    WHEN '&IC1' OR 'PICK' .
      RS_SELFIELD-REFRESH = 'X'. "REFRESCAR PANTALLA
  ENDCASE.
  CLEAR R_UCOMM.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_REPORT .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = SY-REPID
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND'
      I_GRID_TITLE            = 'BUSCAR LISTADO'
      IT_SORT                 = IT_SORTCAT[]
      IS_LAYOUT               = GD_LAYOUT
      IT_FIELDCAT             = WA_FIELDCAT[]
      I_SAVE                  = 'X'
    TABLES
      T_OUTTAB                = LISTADO
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " ALV_REPORT
