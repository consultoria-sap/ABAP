TABLES: KONA, TVGRT, KOTE902, TVBOT, KONP.

**ALV**
TYPE-POOLS: SLIS, ICON.

DATA: IT_FIELDCAT                 TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      WA_FIELDCAT                 TYPE SLIS_T_FIELDCAT_ALV WITH HEADER LINE,
      GD_TAB_GROUP                TYPE SLIS_T_SP_GROUP_ALV,
      GD_LAYOUT                   TYPE SLIS_LAYOUT_ALV,
      GD_REPID                    LIKE SY-REPID,
      GT_EVENTS                   TYPE SLIS_T_EVENT,
      GD_PRNTPARAMS               TYPE SLIS_PRINT_ALV,
      IT_SORTCAT                  TYPE SLIS_T_SORTINFO_ALV,
      TEXTO(120).


DATA: BEGIN OF DATOS OCCURS 0, "Estructura para archivo plano
  CADENA(300),
END OF DATOS.

" Definición de tabla interna donde se grabaran los datos leídos de la base de datos.
DATA: BEGIN OF LT_INTERNA OCCURS 0,
  KNUMA TYPE KONA-KNUMA,
  BONEM TYPE KONA-BONEM,
  BOTEXT TYPE KONA-BOTEXT,
  DATAB TYPE KONA-DATAB,
  DATBI TYPE KONA-DATBI,
  VKGRP TYPE KONA-VKGRP,
  KAPPL TYPE KONA-KAPPL,
  KOBOG TYPE KONA-KOBOG,
  BEZEI TYPE TVGRT-BEZEI,
  BONUS TYPE KOTE902-BONUS,
  VTEXT TYPE TVBOT-VTEXT,
  KBETR TYPE KONP-KBETR,
  KONWA TYPE KONP-KONWA,
END OF LT_INTERNA.


" Definición de variables que el usuario debe ingresar al programa.
SELECTION-SCREEN BEGIN OF BLOCK TEXT-000 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: DATAB FOR KONA-DATAB,
                DATBI FOR KONA-DATBI,
                VKGRP FOR KONA-VKGRP,
                BONEM FOR KONA-VKGRP.
PARAMETERS:   DIREC TYPE RLGRAP-FILENAME  DEFAULT 'D:\' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK TEXT-000.


START-OF-SELECTION.
  PERFORM DATOS.
  PERFORM CAMPOS_ALV.
  PERFORM ORDENAR_ALV.
  PERFORM LAYOUT.
  PERFORM ALV_REPORT.
  PERFORM GRABAR_ARCHIVO.
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
  SELECT BOTEXT DATAB DATBI VKGRP BONEM
    INTO (KONA-BOTEXT,KONA-DATAB,KONA-DATBI,KONA-VKGRP,KONA-BONEM)
    FROM KONA
    WHERE DATAB IN DATAB
    AND  DATBI IN DATBI
    AND  VKGRP IN VKGRP
    AND  BONEM IN BONEM.


  SELECT BONUS
    INTO  KOTE902-BONUS
    FROM  KOTE902
     WHERE KNUMA EQ KONA-KNUMA.


  SELECT KBETR KONWA
    INTO (KONP-KBETR, KONP-KONWA)
    FROM KONP
     WHERE KNUMH EQ KOTE902-KNUMH
      AND KSCHL EQ KOTE902-KSCHL
      AND KAPPL EQ KOTE902-KAPPL.


  IF SY-SUBRC = 0.
  ENDIF.


    SELECT VTEXT
      INTO TVBOT-VTEXT
      FROM TVBOT
      WHERE BONUS EQ KOTE902-BONUS
      AND SPRAS = 'S'.


    SELECT BEZEI
     INTO  TVGRT-BEZEI
      FROM  TVGRT
      WHERE  VKGRP EQ KONA-VKGRP
      AND SPRAS = 'S'.


    SELECT *
     INTO CORRESPONDING FIELDS OF LT_INTERNA
     FROM T6B2
     WHERE KAPPL EQ KONA-KAPPL
      AND KOBOG EQ KONA-KOBOG.
      LT_INTERNA-KNUMA  = KONA-KNUMA.
      LT_INTERNA-BONEM  = KONA-BONEM.
      LT_INTERNA-BOTEXT = KONA-BOTEXT.
      LT_INTERNA-DATAB  = KONA-DATAB.
      LT_INTERNA-DATBI  = KONA-DATBI.
      LT_INTERNA-VKGRP  = KONA-VKGRP.
      LT_INTERNA-KAPPL  = KONA-KAPPL.
      LT_INTERNA-KOBOG  = KONA-KOBOG.
      LT_INTERNA-BEZEI  = TVGRT-BEZEI.
      LT_INTERNA-BONUS  = KOTE902-BONUS.
      LT_INTERNA-VTEXT  = TVBOT-VTEXT.
      LT_INTERNA-KBETR  = KONP-KBETR.
      LT_INTERNA-KONWA  = KONP-KONWA.
      APPEND LT_INTERNA.
      CLEAR LT_INTERNA.
      ENDSELECT.
      ENDSELECT.
      ENDSELECT.
      ENDSELECT.
      ENDSELECT.
      ENDSELECT.
  ENDFORM.              "DATOS
  "DATOS
*&---------------------------------------------------------------------*
*&      Form  CAMPOS_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CAMPOS_ALV .

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'KNUMA' .
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Acuerdo Rappels'.
  IT_FIELDCAT-OUTPUTLEN = '16'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'BONEM'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Codigo Cliente'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'BOTEXT'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Denominacion Cliente'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'DATAB'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Fecha Inicio'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'DATBI'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Fecha Fin'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'VKGRP'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Codigo Ven-Cli'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'BEZEI'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Denominacion Ven-Cli'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'BONUS'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Grupo Rappels'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'VTEXT'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Denominacion'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'KBETR'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Valor'.
  IT_FIELDCAT-OUTPUTLEN = '16'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.

  CLEAR IT_FIELDCAT.
  IT_FIELDCAT-FIELDNAME = 'KONWA'.
  IT_FIELDCAT-TABNAME   = 'LT_INTERNA' .
  IT_FIELDCAT-KEY       = 'X'.
  IT_FIELDCAT-SELTEXT_M   = 'Unidad'.
  IT_FIELDCAT-OUTPUTLEN = '10'.
  APPEND IT_FIELDCAT TO WA_FIELDCAT.
ENDFORM.                    " CAMPOS_ALV
*&---------------------------------------------------------------------*
*&      Form  ORDENAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ORDENAR_ALV .
  SORT LT_INTERNA BY KNUMA.

  DATA: IT_SORT TYPE SLIS_SORTINFO_ALV.
  CLEAR IT_SORT.
  IT_SORT-SPOS = 1.
  IT_SORT-FIELDNAME = 'KNUMA'.
  IT_SORT-UP = 'X'.
  IT_SORT-SUBTOT = 'X'.
  APPEND IT_SORT TO IT_SORTCAT.
ENDFORM.                    " ORDENAR_ALV
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

* function
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
      I_GRID_TITLE            = 'BUSCAR DOCUMENTO'
      IT_SORT                 = IT_SORTCAT[]
      IS_LAYOUT               = GD_LAYOUT
      IT_FIELDCAT             = WA_FIELDCAT[]
      I_SAVE                  = 'X'
    TABLES
      T_OUTTAB                = LT_INTERNA
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.                    " ALV_REPORT
