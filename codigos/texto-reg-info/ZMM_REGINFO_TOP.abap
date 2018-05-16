*&---------------------------------------------------------------------*
*&  Include           ZMM_REGINFO_TOP
*&---------------------------------------------------------------------*
** ALV
TYPE-POOLS: SLIS.

*DATA PARA EL ALV
  DATA: t_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.
  DATA: i_layout TYPE slis_layout_alv.
  DATA: wa_fieldcat TYPE slis_fieldcat_alv.


** bapi
DATA: LV_TABIX  LIKE SY-TABIX,
        LT_WMDVSX LIKE BAPIWMDVS OCCURS 0 WITH HEADER LINE,
        LT_WMDVEX LIKE BAPIWMDVE OCCURS 0 WITH HEADER LINE.

  LV_TABIX = SY-TABIX.

  CLEAR: LT_WMDVSX, LT_WMDVEX.
  REFRESH: LT_WMDVSX, LT_WMDVEX.

** bapi

  DATA: lc_tabix  TYPE sy-tabix,
        lc_id     TYPE thead-tdid,
        lc_object TYPE thead-tdobject,
        lc_name   TYPE thead-tdname,
        lt_lines  TYPE TABLE OF tline WITH HEADER LINE.

DATA: var TYPE string.

***********************************************************************
** Tablas
***********************************************************************
TABLES:  eina, makt, lfa1.

************************************************************************
*Variables globales
************************************************************************
DATA:
  g_material    LIKE MCHB-matnr.

************************************************************************
*Constantes
************************************************************************
*CONSTANTS:

************************************************************************
*Estructuras
************************************************************************
DATA:
  BEGIN OF st_tabla,
    infnr     LIKE eina-infnr,
    lifnr     LIKE lfa1-lifnr,
    name1     LIKE lfa1-name1,
    matnr     LIKE makt-matnr,
    maktx     LIKE makt-maktx,
    lt_lines  TYPE string,
    color(4)  TYPE c,
  END OF st_tabla.

DATA:
  BEGIN OF st_tablaaux,
    lifnr   LIKE lfa1-lifnr,
    name1   LIKE lfa1-name1,
  END OF st_tablaaux.

DATA:
  BEGIN OF st_tablaaux1,
    matnr     LIKE makt-matnr,
    maktx     LIKE makt-maktx,
  END OF st_tablaaux1.

************************************************************************
*Tablas internas
************************************************************************
* Tabla de vuelos: primera forma de declaración de tablas internas
DATA:
  BEGIN OF ti_tabla occurs 0,
    infnr     LIKE eina-infnr,
    lifnr     LIKE lfa1-lifnr,
    name1     LIKE lfa1-name1,
    matnr     LIKE makt-matnr,
    maktx     LIKE makt-maktx,
    lt_lines  TYPE string,
        color(4)  TYPE c,
  END OF ti_tabla.

DATA:
  BEGIN OF ti_tablaaux OCCURS 0,
    lifnr   LIKE lfa1-lifnr,
    name1   LIKE lfa1-name1,
  END OF ti_tablaaux.

DATA:
  BEGIN OF ti_tablaaux1 OCCURS 0,
    matnr     LIKE makt-matnr,
    maktx     LIKE makt-maktx,
  END OF ti_tablaaux1.
