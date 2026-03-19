*&---------------------------------------------------------------------*
*&  Include           ZMM_REGINFO_ALVF01
*&---------------------------------------------------------------------*
FORM ALV .
** ALV
CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'LIFNR'.
  wa_fieldcat-tabname = 'TI_TABLA'.
  wa_fieldcat-seltext_m = 'Cod.Pr.'.
  APPEND wa_fieldcat TO t_fieldcat.
CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'NAME1'.
  wa_fieldcat-tabname = 'TI_TABLA'.
  wa_fieldcat-seltext_m = 'Denom.Proveedor'.
  APPEND wa_fieldcat TO t_fieldcat.
CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-tabname = 'TI_TABLA'.
  wa_fieldcat-seltext_m = 'Cod.Mat'.
  APPEND wa_fieldcat TO t_fieldcat.
CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'MAKTX'.
  wa_fieldcat-tabname = 'TI_TABLA'.
  wa_fieldcat-seltext_m = 'Denom.Material'.
  APPEND wa_fieldcat TO t_fieldcat.
CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'INFNR'.
  wa_fieldcat-tabname = 'TI_TABLA'.
  wa_fieldcat-seltext_m = 'Reg.Info'.
  APPEND wa_fieldcat TO t_fieldcat.
CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = 'LT_LINES'.
  wa_fieldcat-tabname = 'TI_TABLA'.
  wa_fieldcat-seltext_m = 'Texto Cabecera'.
  APPEND wa_fieldcat TO t_fieldcat.

I_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
I_LAYOUT-info_fieldname = 'COLOR'.
I_LAYOUT-ZEBRA = 'X'.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
       I_CALLBACK_PROGRAM  = sy-repid
        IS_LAYOUT          = I_LAYOUT
        I_SAVE             = 'A'
        it_fieldcat        = t_fieldcat[]
  TABLES
       T_OUTTAB = TI_TABLA.

ENDFORM.                    " ALV
